// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vending_standalone/src/services/dispense.dart';
import 'package:vending_standalone/src/services/serialport.dart';
import 'package:vending_standalone/src/widgets/md_widget/app_bar.dart';

class DispenseScreen extends StatefulWidget {
  const DispenseScreen({super.key});

  @override
  State<DispenseScreen> createState() => _DispenseScreenState();
}

class _DispenseScreenState extends State<DispenseScreen> {
  late VendingMachine vending;

  @override
  void initState() {
    super.initState();
    try {
      vending = VendingMachine();
      vending.connectPort();
    } catch (error) {
      if (kDebugMode) {
        print("SerialPortError: $error");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dispense = Dispense(vending: vending);

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'เลือกช่องจ่าย',
        isBottom: false,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: 60,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () {
                  _showBottomSheet(context, index, dispense);
                },
                child: Text("${index + 1}"),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, int index, Dispense dispense) {
    int count = 1;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ช่องที่ ${index + 1}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            if (count > 1) count--;
                          });
                        },
                        icon: const Icon(Icons.remove_circle),
                      ),
                      Text('$count', style: const TextStyle(fontSize: 24)),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            if (count < 10) count++;
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return const AlertDialog(
                            content: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 16),
                                Text("กำลังจ่ายยา..."),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        await dispense.sendToMachine(count, index);
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }

                      Navigator.pop(context);
                    },
                    child: const Text('ยืนยันการจ่าย'),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
