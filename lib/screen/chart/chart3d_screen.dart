import 'dart:collection';

import 'package:ditredi/ditredi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/feature/sensor_data.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/universal_ble_win/peripheral_details/peripheral_detail_page.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../../utils.dart';

class Chart3dScreen extends StatefulWidget {
  const Chart3dScreen({super.key});

  @override
  State<Chart3dScreen> createState() => _Chart3dScreenState();
}

class _Chart3dScreenState extends State<Chart3dScreen> {
  // Controller to handle rotation and zoom of the 3D view
  final _controller = DiTreDiController(
    rotationX: -20,
    rotationY: 30,
    userScale: 2, // Zoom in a bit
  );

  // A buffer to store historical points (The "Trail")
  final int _historyLimit = 150;
  final Queue<vector.Vector3> _history = Queue();

  // Current Sensor Value
  vector.Vector3 _currentVector = vector.Vector3.zero();

  // To prevent duplicate history entries during rebuilds
  SensorData? _lastProcessedData;

  // Scale factor to make small sensor values visible (e.g. 0.006 * 500 = 3.0)
  static const double _dataScale = 200.0;

  @override
  void initState() {
    super.initState();
    // Initialize with a zero point
    _history.add(vector.Vector3.zero());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorData>(
      stream: PeripheralDetailPage.sensorDataStream.stream,
      builder: (context, snapshot) {
        // Process new data if available and not already processed
        if (snapshot.hasData && snapshot.data != _lastProcessedData) {
          _lastProcessedData = snapshot.data!;
          final data = snapshot.data!;

          // Map sensor data to 3D vector
          // Swapping Y and Z is common in 3D charts to make 'Z' the up-axis
          final newPoint = vector.Vector3(
            data.accX * _dataScale,
            data.accZ * _dataScale,
            data.accY * _dataScale,
          );

          _currentVector = newPoint;
          myUtils.log('Current Vector: $_currentVector');
          _history.add(newPoint);
          if (_history.length > _historyLimit) {
            _history.removeFirst();
          }
        }

        return Stack(
          children: [
            Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  setState(() {
                    // Adjust zoom sensitivity (0.005 is a common factor for smooth scroll)
                    final double newScale =
                        _controller.userScale -
                        (pointerSignal.scrollDelta.dy * 0.005);
                    _controller.userScale = newScale.clamp(0.1, 10.0);
                  });
                }
              },
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _controller.rotationX += details.delta.dy;
                    _controller.rotationY += details.delta.dx;
                  });
                },
                child: DiTreDi(
                  controller: _controller,
                  // The list of 3D figures to draw
                  figures: [
                    // 1. Draw the Axis Lines (Reference Frame)
                    Line3D(
                      vector.Vector3(0, 0, 0),
                      vector.Vector3(10, 0, 0),
                      width: 2,
                      color: Colors.red,
                    ), // X Axis
                    Line3D(
                      vector.Vector3(0, 0, 0),
                      vector.Vector3(0, 10, 0),
                      width: 2,
                      color: Colors.green,
                    ), // Z Axis (Up)
                    Line3D(
                      vector.Vector3(0, 0, 0),
                      vector.Vector3(0, 0, 10),
                      width: 2,
                      color: Colors.blue,
                    ), // Y Axis
                    // 2. Draw the History Trail (Grey Points)
                    ..._history.map((e) => Point3D(e, color: Colors.grey)),

                    // 3. Draw the Car (Voxel style)
                    ..._buildVoxelCar(_currentVector),
                    // 4. Draw a Line from Origin to Current Value (Visualizes the Vector)
                    Line3D(
                      vector.Vector3.zero(),
                      _currentVector,
                      width: 3,
                      color: Colors.yellowAccent,
                    ),
                  ],
                  config: const DiTreDiConfig(
                    supportZIndex:
                        true, // Ensures points behave correctly in 3D depth
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () {
                      setState(() {
                        _controller.userScale += 0.5;
                      });
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () {
                      setState(() {
                        _controller.userScale = (_controller.userScale - 0.5)
                            .clamp(0.1, 10.0);
                      });
                    },
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Model3D> _buildVoxelCar(vector.Vector3 pos) {
    const double size = 0.6;
    return [
      // Chassis (3 blocks long along X)
      Cube3D(size, pos, color: Colors.blue),
      Cube3D(
        size,
        vector.Vector3(pos.x + size, pos.y, pos.z),
        color: Colors.blue,
      ),
      Cube3D(
        size,
        vector.Vector3(pos.x - size, pos.y, pos.z),
        color: Colors.blue,
      ),

      // Roof (1 block on top)
      Cube3D(
        size,
        vector.Vector3(pos.x, pos.y + size, pos.z),
        color: Colors.lightBlueAccent,
      ),

      // Wheels (4 small blocks)
      Cube3D(
        size * 0.4,
        vector.Vector3(pos.x + size, pos.y - size * 0.5, pos.z + size * 0.5),
        color: Colors.black,
      ),
      Cube3D(
        size * 0.4,
        vector.Vector3(pos.x + size, pos.y - size * 0.5, pos.z - size * 0.5),
        color: Colors.black,
      ),
      Cube3D(
        size * 0.4,
        vector.Vector3(pos.x - size, pos.y - size * 0.5, pos.z + size * 0.5),
        color: Colors.black,
      ),
      Cube3D(
        size * 0.4,
        vector.Vector3(pos.x - size, pos.y - size * 0.5, pos.z - size * 0.5),
        color: Colors.black,
      ),
    ];
  }
}
