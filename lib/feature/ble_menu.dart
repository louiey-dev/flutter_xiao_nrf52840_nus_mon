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

  double _currentSliderValue = 0.0;

  TextEditingController prdController = TextEditingController();

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

                    String cmd = '00010006${index.toString().padLeft(2, '0')}';
                    cmd += _selectedLeds[index] ? '01' : '00';
                    _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
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
              myWIDTH(20),
              _discreteSlider(),
              myWIDTH(10),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: prdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'in msec',
                    labelText: 'prd time',
                    prefixIcon: Icon(Icons.timer),
                  ),
                ),
              ),
              myWIDTH(10),
              ElevatedButton(
                onPressed: () {
                  int prd = int.parse(prdController.text);
                  String cmd =
                      '00040006${prd.toRadixString(16).padLeft(4, '0')}';
                  _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
                },
                child: const Text('Set'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _discreteSlider() {
    return Row(
      children: [
        const Text('PWM LED Width', style: TextStyle(fontSize: 16)),
        // const SizedBox(width: 10),
        Slider(
          value: _currentSliderValue,
          min: 0,
          max: 5000000, // 5 seconds
          divisions: 100,
          label: _currentSliderValue.round().toString(),
          onChanged: (double value) {
            setState(() {
              _currentSliderValue = value;
            });
          },
        ),
        // const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            String cmd =
                '00030008${_currentSliderValue.toInt().toRadixString(16).padLeft(8, '0')}';
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
          },
          child: const Text("Set"),
        ),
      ],
    );
  }

  Future<void> _writeToBle(Uint8List data, bool withResponse) async {
    final characteristic = PeripheralDetailPage.globalSelectedCharacteristic;
    if (characteristic != null) {
      try {
        await characteristic.write(data, withResponse: withResponse);
        myUtils.log("Wrote to BLE: $data");
      } catch (e) {
        myUtils.log("Error writing to BLE: $e");
      }
    } else {
      myUtils.log("No BLE Characteristic selected in Detail Page");
      myUtils.showSnackbarError(
        context,
        "No BLE Characteristic selected in Detail Page",
      );
    }
  }
}
