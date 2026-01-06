import 'dart:typed_data';

class SensorData {
  final double accX;
  final double accY;
  final double accZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;

  SensorData({
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
  });

  // Factory constructor to parse the raw bytes
  factory SensorData.fromBytes(List<int> bytes) {
    // 1. Create a ByteData view for easier parsing
    final buffer = Uint8List.fromList(bytes).buffer;
    final data = ByteData.view(buffer);

    // 2. Define the sensitivity (Scale Factor)
    // This depends on your sensor settings!
    // Example: For MPU6050 at +/- 2G range, sensitivity is 16384 LSB/g
    const double accScale = 16384.0;
    // Example: For Gyro at +/- 250dps, sensitivity is 131 LSB/dps
    const double gyroScale = 131.0;

    return SensorData(
      // Read 2 bytes at offset 0, Little Endian, convert to double
      accX: data.getInt16(0, Endian.little) / accScale,
      // Read 2 bytes at offset 2...
      accY: data.getInt16(2, Endian.little) / accScale,
      accZ: data.getInt16(4, Endian.little) / accScale,

      gyroX: data.getInt16(6, Endian.little) / gyroScale,
      gyroY: data.getInt16(8, Endian.little) / gyroScale,
      gyroZ: data.getInt16(10, Endian.little) / gyroScale,
    );
  }
}
