import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/universal_ble_win/universal_ble_app.dart';

class BleScreen extends StatefulWidget {
  const BleScreen({super.key});

  @override
  State<BleScreen> createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  bool? hasPermission;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final result = await initializeApp();
    if (mounted) {
      setState(() => hasPermission = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasPermission == null) {
      return Center(child: CircularProgressIndicator());
    }
    return UniversalBleApp(hasPermission: hasPermission!);
  }
}
