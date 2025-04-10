import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class VendingMachine {
  static final VendingMachine _instance = VendingMachine._internal();

  late SerialPort ttyS1;
  late SerialPort ttyS2;

  // Factory constructor
  factory VendingMachine() {
    return _instance;
  }

  // Private named constructor
  VendingMachine._internal();

  /// Connect both serial ports with default or provided baud rates.
  void connectPort({int baudRatettyS1 = 57600, int baudRateS2 = 9600}) {
    try {
      ttyS1 = SerialPort("/dev/ttyS1");
      ttyS2 = SerialPort("/dev/ttyS2");

      if (!ttyS1.isOpen) ttyS1.openReadWrite();
      if (!ttyS2.isOpen) ttyS2.openReadWrite();

      ttyS1.config = SerialPortConfig()
        ..baudRate = baudRatettyS1
        ..bits = 8
        ..parity = 0
        ..stopBits = 1
        ..xonXoff = 0;

      ttyS2.config = SerialPortConfig()
        ..baudRate = baudRateS2
        ..bits = 8
        ..parity = 0
        ..stopBits = 1
        ..xonXoff = 0;
    } catch (error) {
      if (kDebugMode) {
        print("Error opening serial ports: $error");
      }
    }
  }

  /// Write a string command to ttyS2.
  void writeSerialttyS2(String command) {
    try {
      List<int> cmdBytes = command.codeUnits;
      ttyS2.write(Uint8List.fromList(cmdBytes));
    } catch (error) {
      if (kDebugMode) {
        print("Error writing to ttyS2: $error");
      }
    }
  }

  /// Stream data from ttyS1.
  Stream<Uint8List> upcomingDatattyS1() {
    return SerialPortReader(ttyS1, timeout: 10000).stream.map((data) => data);
  }

  /// Stream data from ttyS2.
  Stream<Uint8List> upcomingDatattyS2() {
    return SerialPortReader(ttyS2, timeout: 500).stream.map((data) => data);
  }

  /// Close both serial ports.
  Future<void> disconnectPort() async {
    try {
      ttyS1.close();
      ttyS2.close();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (error) {
      if (kDebugMode) {
        print("Error disconnecting ports: $error");
      }
    }
  }
}
