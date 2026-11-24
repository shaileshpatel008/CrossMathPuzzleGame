import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/iap_config.dart';
import '../../data/services/purchase_service.dart';
import '../purchase/purchase_flow_controller.dart';

class VipController extends GetxController {
  final plan = IapIds.vipYearly.obs;
  PurchaseService get iap => PurchaseService.to;

  void subscribe() => PurchaseFlowController.to.buy(plan.value);
  void restore() => PurchaseFlowController.to.restore();
  void manage() =>
      launchUrl(Uri.parse(AppConstants.manageSubscriptionsUrl), mode: LaunchMode.externalApplication);
}
