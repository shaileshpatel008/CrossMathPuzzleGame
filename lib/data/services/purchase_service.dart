import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../app/constants/iap_config.dart';
import '../../app/constants/storage_keys.dart';
import 'progress_service.dart';
import 'storage_service.dart';

enum PurchaseEventType { success, pending, failed, cancelled, restored, nothingToRestore, unavailable }

class PurchaseEvent {
  const PurchaseEvent(this.type, {this.productId, this.message, this.restoredIds = const []});
  final PurchaseEventType type;
  final String? productId;
  final String? message;
  final List<String> restoredIds;
}

/// Google Play Billing via `in_app_purchase`.
///
/// Entitlements:
///  * removeAds = remove_ads OR starter_pack (non-consumables)
///  * vip       = any active vip_* subscription
/// Consumable hint packs are credited once per purchase ID.
///
/// NOTE: for extra safety you can verify `verificationData` on your own
/// server before delivering (see [_verify]).
class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find();

  final InAppPurchase _iap = InAppPurchase.instance;
  StorageService get _s => StorageService.to;

  final storeAvailable = false.obs;
  final productsLoaded = false.obs;
  final products = <String, ProductDetails>{}.obs;
  final removeAdsOwned = false.obs;
  final vipActive = false.obs;
  final vipProductId = ''.obs;
  final busy = false.obs;

  final _events = StreamController<PurchaseEvent>.broadcast();
  Stream<PurchaseEvent> get events => _events.stream;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  Set<String>? _restoreCollector;
  final Set<String> _delivered = {};

  bool get adsRemoved => removeAdsOwned.value || vipActive.value;
  bool get isVip => vipActive.value;

  Future<PurchaseService> init() async {
    removeAdsOwned.value = _s.readBool(StorageKeys.removeAds);
    vipActive.value = _s.readBool(StorageKeys.vipActive);
    vipProductId.value = _s.readString(StorageKeys.vipProduct) ?? '';
    _delivered.addAll(_s.readStringList(StorageKeys.deliveredPurchaseIds));
    _sub = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) {
        debugPrint('purchaseStream error: $e');
      },
    );
    unawaited(_bootstrap());
    return this;
  }

  Future<void> _bootstrap() async {
    try {
      storeAvailable.value = await _iap.isAvailable();
      if (!storeAvailable.value) return;
      await loadProducts();
      await _restore(userInitiated: false);
    } catch (e) {
      debugPrint('Store bootstrap failed: $e');
    }
  }

  /// Recurring price per subscription (the trial entry's own price reads "Free").
  final Map<String, String> _recurringPrice = {};

  /// Subscription ids whose chosen offer starts with a free trial for this user.
  final Map<String, bool> _freeTrial = {};

  Future<void> loadProducts() async {
    final res = await _iap.queryProductDetails(IapIds.all);
    final chosen = <String, ProductDetails>{};
    final rank = <String, int>{};
    for (final p in res.productDetails) {
      if (p is GooglePlayProductDetails && p.subscriptionIndex != null) {
        // Google Play returns one entry per base plan / offer of a subscription, and
        // only the offers this user is eligible for. Prefer the free-trial offer, then
        // the plain base plan; always display the recurring (after-trial) price.
        final offer = p.productDetails.subscriptionOfferDetails![p.subscriptionIndex!];
        final phases = offer.pricingPhases;
        _recurringPrice[p.id] = phases.last.formattedPrice;
        final isTrial = offer.offerId != null && phases.length > 1 && phases.first.priceAmountMicros == 0;
        final r = isTrial ? 2 : (offer.offerId == null ? 1 : 0);
        if (r > (rank[p.id] ?? -1)) {
          rank[p.id] = r;
          chosen[p.id] = p;
          _freeTrial[p.id] = isTrial;
        }
      } else {
        chosen[p.id] = p;
        // App Store: the introductory free trial is configured in App Store Connect.
        if (p.id == IapIds.vipYearly) _freeTrial[p.id] = true;
      }
    }
    products.assignAll(chosen);
    productsLoaded.value = true;
    if (res.notFoundIDs.isNotEmpty) debugPrint('IAP not found: ${res.notFoundIDs}');
  }

  String price(String id) => _recurringPrice[id] ?? products[id]?.price ?? IapIds.fallbackPrices[id] ?? '';

  /// Whether buying [id] starts a free trial for this user (true while the store is loading,
  /// so the paywall matches the design; Play only offers the trial to eligible users).
  bool hasFreeTrial(String id) => _freeTrial[id] ?? (id == IapIds.vipYearly && !productsLoaded.value);

  /// Starts a purchase. Results arrive on [events].
  Future<bool> buy(String id) async {
    if (!storeAvailable.value) {
      storeAvailable.value = await _iap.isAvailable();
      if (storeAvailable.value && products.isEmpty) await loadProducts();
    }
    final pd = products[id];
    if (!storeAvailable.value || pd == null) {
      _events.add(
        const PurchaseEvent(
          PurchaseEventType.unavailable,
          message: 'Google Play is not available right now. Check your connection and try again.',
        ),
      );
      return false;
    }
    busy.value = true;
    try {
      final param = PurchaseParam(productDetails: pd);
      final ok = IapIds.consumables.contains(id)
          ? await _iap.buyConsumable(purchaseParam: param)
          : await _iap.buyNonConsumable(purchaseParam: param);
      if (!ok) busy.value = false;
      return ok;
    } catch (e) {
      busy.value = false;
      _events.add(PurchaseEvent(PurchaseEventType.failed, productId: id, message: '$e'));
      return false;
    }
  }

  Future<void> restore() => _restore(userInitiated: true);

  Future<void> _restore({required bool userInitiated}) async {
    if (!storeAvailable.value) {
      storeAvailable.value = await _iap.isAvailable();
      if (!storeAvailable.value) {
        if (userInitiated) {
          _events.add(
            const PurchaseEvent(
              PurchaseEventType.unavailable,
              message: 'Google Play is not available right now.',
            ),
          );
        }
        return;
      }
    }
    _restoreCollector = <String>{};
    try {
      await _iap.restorePurchases();
      // Restored purchases are delivered asynchronously on the purchase stream.
      await Future<void>.delayed(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('restore failed: $e');
      _restoreCollector = null;
      return;
    }
    final found = _restoreCollector ?? <String>{};
    _restoreCollector = null;
    // Subscriptions that are no longer returned have expired or were cancelled.
    final activeVip = found.where(IapIds.subscriptions.contains).toList();
    _setVip(activeVip.isNotEmpty, activeVip.isNotEmpty ? activeVip.first : '');
    if (found.any(IapIds.nonConsumables.contains)) _setRemoveAds(true);
    if (userInitiated) {
      _events.add(
        found.isEmpty
            ? const PurchaseEvent(PurchaseEventType.nothingToRestore)
            : PurchaseEvent(PurchaseEventType.restored, restoredIds: found.toList()),
      );
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _events.add(PurchaseEvent(PurchaseEventType.pending, productId: p.productID));
        case PurchaseStatus.canceled:
          busy.value = false;
          _events.add(PurchaseEvent(PurchaseEventType.cancelled, productId: p.productID));
        case PurchaseStatus.error:
          busy.value = false;
          _events.add(
            PurchaseEvent(PurchaseEventType.failed, productId: p.productID, message: p.error?.message),
          );
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (await _verify(p)) {
            final restored = p.status == PurchaseStatus.restored;
            _deliver(p, restored: restored);
            if (restored) {
              _restoreCollector?.add(p.productID);
            } else {
              busy.value = false;
              _events.add(PurchaseEvent(PurchaseEventType.success, productId: p.productID));
            }
          } else {
            busy.value = false;
            _events.add(
              PurchaseEvent(
                PurchaseEventType.failed,
                productId: p.productID,
                message: 'Purchase could not be verified.',
              ),
            );
          }
      }
      if (p.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(p); // acknowledges the purchase with Google Play
        } catch (e) {
          debugPrint('completePurchase failed: $e');
        }
      }
    }
  }

  /// Hook for server-side receipt validation. Returns true by default.
  Future<bool> _verify(PurchaseDetails p) async => IapIds.all.contains(p.productID);

  void _deliver(PurchaseDetails p, {required bool restored}) {
    final id = p.productID;
    if (IapIds.subscriptions.contains(id)) {
      _setVip(true, id);
    } else if (IapIds.nonConsumables.contains(id)) {
      _setRemoveAds(true);
      if (id == IapIds.starterPack && !restored) _creditOnce(p, IapIds.hintAmounts[id]!);
    } else if (IapIds.consumables.contains(id) && !restored) {
      _creditOnce(p, IapIds.hintAmounts[id]!);
    }
  }

  void _creditOnce(PurchaseDetails p, int hints) {
    final key = p.purchaseID ?? '${p.productID}-${p.transactionDate}';
    if (_delivered.contains(key)) return;
    _delivered.add(key);
    _s.write(StorageKeys.deliveredPurchaseIds, _delivered.toList());
    ProgressService.to.addHints(hints);
  }

  void _setRemoveAds(bool v) {
    removeAdsOwned.value = v;
    _s.write(StorageKeys.removeAds, v);
  }

  void _setVip(bool v, String product) {
    vipActive.value = v;
    vipProductId.value = product;
    _s.write(StorageKeys.vipActive, v);
    _s.write(StorageKeys.vipProduct, product);
  }

  @override
  void onClose() {
    _sub?.cancel();
    _events.close();
    super.onClose();
  }
}
