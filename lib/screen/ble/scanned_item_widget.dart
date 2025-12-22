import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/ble/ble_scan.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/widget/my_widget.dart';
import 'package:universal_ble/universal_ble.dart';

class ScannedItemWidget extends StatelessWidget {
  final BleDevice bleDevice;
  final VoidCallback? onTap;

  const ScannedItemWidget({super.key, required this.bleDevice, this.onTap});

  @override
  Widget build(BuildContext context) {
    String? name = bleDevice.name;
    List<ManufacturerData> rawManufacturerData = bleDevice.manufacturerDataList;
    ManufacturerData? manufacturerData;
    if (rawManufacturerData.isNotEmpty) {
      manufacturerData = rawManufacturerData.first;
    }
    if (name == null || name.isEmpty) name = 'N/A';

    if (name.contains(advNameController.text) == false) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: ListTile(
          title: Text('$name (${bleDevice.rssi})'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bleDevice.deviceId),
              Visibility(
                visible: manufacturerData != null,
                child: Text(manufacturerData.toString()),
                // child: manufacturerData?.companyId == 0xffff
                //     ? const Text("Distance")
                //     : Text(""),
              ),
              bleDevice.paired == true
                  ? const Text("Paired", style: TextStyle(color: Colors.green))
                  : const Text(
                      "Not Paired",
                      style: TextStyle(color: Colors.red),
                    ),
              if (manufacturerData?.companyId == 0xffff)
                // Text(
                //   "Dist : ${manufacturerData?.payload.buffer.asByteData(63, 2).getUint16(0, Endian.big)} cm",
                // ),
                myDist(
                  manufacturerData!.payload.buffer
                      .asByteData(63, 2)
                      .getUint16(0, Endian.big)
                      .toString(),
                ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        ),
      ),
    );
  }
}

extension on ByteBuffer {
  void operator [](int other) {}
}
