import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/constants/app_constants.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';
import 'data/services/ads_service.dart';
import 'data/services/audio_service.dart';
import 'data/services/connectivity_service.dart';
import 'data/services/haptics_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/progress_service.dart';
import 'data/services/purchase_service.dart';
import 'data/services/settings_service.dart';
import 'data/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await initServices();
  runApp(const CrossMathApp());
}

/// Global services, created once and kept for the app lifetime.
Future<void> initServices() async {
  await Get.putAsync(() => StorageService().init(), permanent: true);
  Get.put(SettingsService().init(), permanent: true);
  Get.put(ProgressService().init(), permanent: true);
  Get.put(HapticsService(), permanent: true);
  await Get.putAsync(() => ConnectivityService().init(), permanent: true);
  await Get.putAsync(() => PurchaseService().init(), permanent: true);
  Get.put(AdsService(), permanent: true);
  await Get.putAsync(() => AudioService().init(), permanent: true);
  await Get.putAsync(() => NotificationService().init(), permanent: true);
}

class CrossMathApp extends StatelessWidget {
  const CrossMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialBinding: InitialBinding(),
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      builder: (context, child) => MediaQuery(
        // Keep the board readable but don't let huge system fonts break layouts.
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.2)),
        child: child!,
      ),
    );
  }
}
