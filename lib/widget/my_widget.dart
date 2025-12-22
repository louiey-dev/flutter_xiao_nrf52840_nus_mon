import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/feature/wifi_menu.dart';

double distanceValue = 0.0;

Widget myWIDTH(double width) {
  return SizedBox(width: width);
}

Widget myHEIGHT(double height) {
  return SizedBox(height: height);
}

Widget myDist(String distance) {
  distanceValue = double.parse(distance);
  distanceValue = distanceValue / 100.0;

  sendUdp(distanceValue.toString());

  return Text("$distanceValue m");
}

Future<void> sendUdp(String str) async {
  // 0은 OS가 임의의 송신 포트를 배정
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final targetAddress = InternetAddress(ipController.text); // 목적지 IP
  final targetPort = int.tryParse(portController.text) ?? 5000; // 목적지 포트

  final data = utf8.encode(str);
  final written = socket.send(
    data,
    targetAddress,
    targetPort,
  ); // 전송[web:28][web:32]

  socket.close();
}
