import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_standalone/src/services/serialport.dart';

class Dispense {
  static Dispense? _instance;
  final VendingMachine vending;
  late SharedPreferences prefs;
  List<int> writedata = [];
  int running = 1;

  // Private named constructor
  Dispense._internal({required this.vending}) {
    initializeSharedPreferences();
  }

  // Singleton factory constructor
  factory Dispense({required VendingMachine vending}) {
    _instance ??= Dispense._internal(vending: vending);
    return _instance!;
  }

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    running = prefs.getInt('running') ?? 1;
  }

  Future<bool> sendToMachine(int dispenseQty, int position) async {
    Completer<bool> completer = Completer<bool>();
    String progress = 'ready';
    bool isDispense = false;
    int floor = -1;
    int qty = dispenseQty;

    try {
      vending.writeSerialttyS2('# 1 1 3 1 6');
      isDispense = true;

      vending.upcomingDatattyS1().listen(
        (data) async {
          List<String> listenData =
              data.map((e) => e.toRadixString(16)).toList();
          String response = listenData.join(',');

          if (response == 'fa,fb,41,0,40') {
            if (writedata.isEmpty) {
              vending.ttyS1
                  .write(Uint8List.fromList([0xfa, 0xfb, 0x42, 0x00, 0x43]));
            } else {
              vending.ttyS1.write(Uint8List.fromList(writedata));
              qty = qty - 1;
            }
          } else if (response.startsWith('fa,fb,4,4')) {
            writedata = [];
            if (progress == 'dispensing') {
              if (qty <= 0) {
                progress = 'liftDown';
                await Future.delayed(const Duration(seconds: 1));
                vending.writeSerialttyS2("# 1 1 1 -1 2");
              } else {
                writeSerialttyS1(position);
              }
            }
          } else {
            if (writedata.isEmpty) {
              vending.ttyS1
                  .write(Uint8List.fromList([0xfa, 0xfb, 0x42, 0x00, 0x43]));
            }
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print("Error in ttyS1 stream: $error");
          }
        },
      );
    } catch (error) {
      if (kDebugMode) {
        print("SerialPortError: $error");
      }
      completer.completeError(error);
      rethrow;
    }

    try {
      vending.upcomingDatattyS2().listen(
        (data) async {
          List<String> response = data.map((e) => e.toRadixString(16)).toList();

          if (isDispense) {
            switch (response.join(',')) {
              case '26,31,d,a,32,d,a,33,d,a,31,d,a,37,d,a':
                vending.writeSerialttyS2('# 1 1 5 10 17');
                progress = 'doorOpened';
                break;
              case '26,31,d,a,32,d,a,35,d,a,31,d,a,39,d,a':
                switch (position) {
                  case <= 10:
                    floor = 1400;
                  case <= 20:
                    floor = 1210;
                  case <= 30:
                    floor = 1010;
                  case <= 40:
                    floor = 790;
                  case <= 50:
                    floor = 580;
                  case <= 60:
                    floor = 360;
                  default:
                    floor = 20;
                }
                vending.writeSerialttyS2(
                    '# 1 1 1 ${floor.toString()} ${floor + 3}');
                progress = 'liftUp';
                break;
              case '26,31,d,a,32,d,a,31,d,a,31,d,a,35,d,a':
                if (progress == 'liftUp') {
                  progress = 'dispensing';
                  writeSerialttyS1(position);
                } else {
                  vending.writeSerialttyS2('# 1 1 6 10 18');
                  progress = 'doorClosed';
                }
                break;
              case '26,31,d,a,32,d,a,36,d,a,31,d,a,31,30,d,a':
                progress = 'rackUnlocked';
                vending.writeSerialttyS2('# 1 1 3 0 5');
                break;
              case '26,31,d,a,32,d,a,33,d,a,30,d,a,36,d,a':
                await Future.delayed(const Duration(milliseconds: 200));
                completer.complete(true);
                qty = 0;
                floor = 20;
                progress = 'ready';
                isDispense = false;
                break;
              default:
            }
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print("Error in ttyS1 stream: $error");
          }
        },
      );
    } catch (error) {
      if (kDebugMode) {
        print("SerialPortError: $error");
      }
      await Future.delayed(const Duration(milliseconds: 500));
      completer.complete(false);
    }
    return completer.future;
  }

  Future<bool> manuallyResetMachine() async {
    Completer<bool> completer = Completer<bool>();
    String progress = 'ready';
    bool isDispense = false;

    try {
      isDispense = true;
      progress = 'liftDown';
      vending.writeSerialttyS2("# 1 1 1 -1 2");

      vending.upcomingDatattyS2().listen(
        (data) async {
          List<String> response = data.map((e) => e.toRadixString(16)).toList();

          if (isDispense) {
            switch (response.join(',')) {
              case '26,31,d,a,32,d,a,31,d,a,31,d,a,35,d,a':
                if (progress == 'liftDown') {
                  vending.writeSerialttyS2('# 1 1 6 10 18');
                  progress = 'doorClosed';
                }
                break;
              case '26,31,d,a,32,d,a,36,d,a,31,d,a,31,30,d,a':
                completer.complete(true);
                progress = 'ready';
                isDispense = false;
                break;
              default:
            }
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print("Error in ttyS1 stream: $error");
          }
        },
      );
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      completer.completeError(error);
      rethrow;
    }
    return completer.future;
  }

  void writeSerialttyS1(int slot) {
    running = running == 255 ? 1 : running + 1;
    prefs.setInt('running', running);
    List<int> commands = [
      0xfa,
      0xfb,
      0x06,
      0x05,
      running,
      0x00,
      0x00,
      0x00,
      slot
    ];
    int checksum = 0;
    for (var element in commands) {
      if (element == 0xfa) {
        checksum = 0xfa;
      } else {
        checksum = checksum ^ element;
      }
    }
    commands.add(checksum);
    writedata = commands;
  }
}
