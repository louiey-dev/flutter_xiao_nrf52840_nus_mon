import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/universal_ble_win/data/storage_service.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/universal_ble_win/home/permission_screen.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/universal_ble_win/home/scanner_screen.dart';
import 'package:universal_ble/universal_ble.dart';

/// Initializes the app services and checks permissions.
/// Returns whether the app has the required permissions.
Future<bool> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  // await UniversalBle.setLogLevel(BleLogLevel.verbose);
  // UniversalBle does not have a hasPermissions method.
  return true;
}

class UniversalBleApp extends StatelessWidget {
  final bool hasPermission;
  final Locale? locale;
  final Widget Function(BuildContext, Widget?)? builder;

  const UniversalBleApp({
    super.key,
    required this.hasPermission,
    this.locale,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return hasPermission ? ScannerScreen() : const PermissionScreen();
  }
}
