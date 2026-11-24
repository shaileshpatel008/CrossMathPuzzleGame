import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Tracks whether the device has a network connection (for ads / store).
class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();

  final online = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<ConnectivityService> init() async {
    final c = Connectivity();
    try {
      _apply(await c.checkConnectivity());
    } catch (_) {}
    _sub = c.onConnectivityChanged.listen(_apply);
    return this;
  }

  void _apply(List<ConnectivityResult> r) {
    online.value = r.any((e) => e != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
