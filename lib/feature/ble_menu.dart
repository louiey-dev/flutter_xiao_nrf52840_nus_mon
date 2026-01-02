import 'dart:ffi';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/universal_ble_win/peripheral_details/peripheral_detail_page.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/utils.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/widget/my_widget.dart';
import 'package:universal_ble/universal_ble.dart';

class BleMenu extends StatefulWidget {
  const BleMenu({super.key});

  @override
  State<BleMenu> createState() => _BleMenuState();
}

class _BleMenuState extends State<BleMenu> {
  final List<bool> _selectedLeds = <bool>[false, false, false];
  List<Widget> rgbLeds = <Widget>[
    Text(
      'RED',
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
    Text(
      'GREEN',
      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
    ),
    Text(
      'BLUE',
      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          myHEIGHT(10),
          Row(
            children: [
              myWIDTH(10),
              const Text(
                "LED Control",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              myWIDTH(10),
              ToggleButtons(
                direction: Axis.horizontal,
                onPressed: (int index) {
                  // All buttons are selectable.
                  setState(() {
                    _selectedLeds[index] = !_selectedLeds[index];

                    String cmd = '0001${index.toString().padLeft(2, '0')}';
                    cmd += _selectedLeds[index] ? '01' : '00';
                    _writeToBle(Uint8List.fromList(hex.decode(cmd)));
                  });

                  for (int i = 0; i < _selectedLeds.length; i++) {
                    if (_selectedLeds[i] == true) {
                      myUtils.log("Selected ${rgbLeds[i].toString()}");
                    }
                  }
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                // selectedColor: Colors.black,
                fillColor: Colors.yellow,
                color: Colors.green[400],
                constraints: const BoxConstraints(
                  minHeight: 30.0,
                  minWidth: 60.0,
                ),
                isSelected: _selectedLeds,
                children: rgbLeds,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _writeToBle(Uint8List data) async {
    final characteristic = PeripheralDetailPage.globalSelectedCharacteristic;
    if (characteristic != null) {
      try {
        await characteristic.write(data, withResponse: true);
        myUtils.log("Wrote to BLE: $data");
      } catch (e) {
        myUtils.log("Error writing to BLE: $e");
      }
    } else {
      myUtils.log("No BLE Characteristic selected in Detail Page");
    }
  }
}
