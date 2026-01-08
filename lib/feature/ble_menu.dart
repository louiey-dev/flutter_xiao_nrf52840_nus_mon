import 'dart:ffi';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/feature/calendar.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/universal_ble_win/peripheral_details/peripheral_detail_page.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/utils.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/widget/my_widget.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
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

  TimeOfDay pickedTime = TimeOfDay.now();

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

                    String cmd =
                        '00010006${index.toRadixString(16).padLeft(2, '0')}';
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
          Row(
            children: [
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  String cmd = '00050004';
                  _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
                },
                child: const Text("RTC Get"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  await initializeDateFormatting('ko_KR');
                  final selectedDate = await showDialog<DateTime>(
                    context: context,
                    builder: (BuildContext context) {
                      DateTime? pickedDate;
                      DateTime focusedDay = DateTime.now();
                      // TimeOfDay pickedTime = TimeOfDay.now();
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('날짜 및 시간 선택'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TableCalendar(
                                    firstDay: DateTime(2020),
                                    lastDay: DateTime(2030),
                                    focusedDay: focusedDay,
                                    headerStyle: const HeaderStyle(
                                      formatButtonVisible: false,
                                    ),
                                    selectedDayPredicate: (day) =>
                                        isSameDay(pickedDate, day),
                                    onDaySelected: (selected, focused) {
                                      setState(() {
                                        pickedDate = selected;
                                        focusedDay = focused;
                                      });
                                    },
                                    locale: 'ko_KR',
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '시간: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final TimeOfDay? time =
                                              await showTimePicker(
                                                context: context,
                                                initialTime: pickedTime,
                                              );
                                          if (time != null) {
                                            setState(() {
                                              pickedTime = time;
                                            });
                                          }
                                        },
                                        child: Text(
                                          pickedTime.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: pickedDate == null
                                    ? null
                                    : () {
                                        final DateTime finalDateTime = DateTime(
                                          pickedDate!.year,
                                          pickedDate!.month,
                                          pickedDate!.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );
                                        Navigator.of(
                                          context,
                                        ).pop(finalDateTime);
                                      },
                                child: const Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  if (selectedDate != null) {
                    myUtils.log(
                      '선택된 날짜: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)}',
                    );
                    // send date time data to prepheral device
                    List<int> m = [];
                    m.add(selectedDate.year - 2000);
                    m.add(selectedDate.month);
                    m.add(selectedDate.day);
                    m.add(selectedDate.weekday);
                    m.add(selectedDate.hour);
                    m.add(selectedDate.minute);
                    m.add(0);
                    String cmd =
                        '00060009${m[0].toRadixString(16).padLeft(2, '0')}${m[1].toRadixString(16).padLeft(2, '0')}${m[2].toRadixString(16).padLeft(2, '0')}${m[3].toRadixString(16).padLeft(2, '0')}';
                    cmd +=
                        '${m[4].toRadixString(16).padLeft(2, '0')}${m[5].toRadixString(16).padLeft(2, '0')}${m[6].toRadixString(16).padLeft(2, '0')}';
                    _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
                    myUtils.log(cmd);
                  }
                },
                child: const Text("RTC Set"),
              ),
              const SizedBox(width: 20),
              _soundMenu(),
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

  _soundMenu() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            String cmd = '00070008';
            cmd += int.parse('262').toRadixString(16).padLeft(4, '0');
            cmd += int.parse('500').toRadixString(16).padLeft(4, '0');
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
            myUtils.log(cmd);
          },
          child: Text("DO"),
        ),
        ElevatedButton(
          onPressed: () {
            String cmd = '00070008';
            cmd += int.parse('294').toRadixString(16).padLeft(4, '0');
            cmd += int.parse('500').toRadixString(16).padLeft(4, '0');
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
            myUtils.log(cmd);
          },
          child: Text("RE"),
        ),
        ElevatedButton(
          onPressed: () {
            String cmd = '00070008';
            cmd += int.parse('330').toRadixString(16).padLeft(4, '0');
            cmd += int.parse('500').toRadixString(16).padLeft(4, '0');
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
            myUtils.log(cmd);
          },
          child: Text("MI"),
        ),
        ElevatedButton(
          onPressed: () {
            String cmd = '00070008';
            cmd += int.parse('349').toRadixString(16).padLeft(4, '0');
            cmd += int.parse('500').toRadixString(16).padLeft(4, '0');
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
            myUtils.log(cmd);
          },
          child: Text("PA"),
        ),
        ElevatedButton(
          onPressed: () {
            String cmd = '00070008';
            cmd += int.parse('392').toRadixString(16).padLeft(4, '0');
            cmd += int.parse('500').toRadixString(16).padLeft(4, '0');
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
            myUtils.log(cmd);
          },
          child: Text("SOL"),
        ),
        ElevatedButton(
          onPressed: () {
            String cmd = '00070008';
            cmd += int.parse('440').toRadixString(16).padLeft(4, '0');
            cmd += int.parse('500').toRadixString(16).padLeft(4, '0');
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
            myUtils.log(cmd);
          },
          child: Text("RA"),
        ),
        ElevatedButton(
          onPressed: () {
            String cmd = '00070008';
            cmd += int.parse('494').toRadixString(16).padLeft(4, '0');
            cmd += int.parse('500').toRadixString(16).padLeft(4, '0');
            _writeToBle(Uint8List.fromList(hex.decode(cmd)), false);
            myUtils.log(cmd);
          },
          child: Text("SI"),
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
