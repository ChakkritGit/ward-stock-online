// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:async';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/blocs/users/user_bloc.dart';
import 'package:vending_standalone/src/constants/env.dart';
import 'package:vending_standalone/src/models/rabbit/rabbit_model.dart';
import 'package:vending_standalone/src/services/dispense.dart';
import 'package:vending_standalone/src/services/serialport.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';

class RabbitMQService {
  final VendingMachine vending;
  final dioHelper = DioHelper();
  final BuildContext context;
  late Consumer consumer;
  late Client client;
  late AmqpMessage? newMessage;
  late String ackMessage;

  late SharedPreferences prefs;
  List<int> writedata = [];
  String progress = 'ready';
  int running = 1;

  RabbitMQService({required this.vending, required this.context}) {
    client = Client(
      settings: ConnectionSettings(
        host: Env.server,
        port: Env.port,
        authProvider: const PlainAuthenticator(Env.rabbitUser, Env.rabbitPass),
      ),
    );
  }

  Future<void> listenToQueue(String queueName) async {
    try {
      Channel channel = await client.channel();
      await channel.qos(0, 1);
      Queue queue = await channel.queue(queueName, durable: true);

      if (kDebugMode) {
        print("Listening to queue: $queueName");
      }

      consumer = await queue.consume(noAck: false);

      consumer.listen((AmqpMessage message) async {
        newMessage = message;
        ackMessage = message.payloadAsString;

        if (!vending.ttyS1.isOpen && !vending.ttyS2.isOpen) {
          vending.connectPort();
        }

        await Future.delayed(const Duration(seconds: 1));

        try {
          handleMessage(message.payloadAsString);
        } catch (error) {
          if (kDebugMode) {
            print("Error processing message: $error");
          }
          message.reject(true);
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error connecting to RabbitMQ: $error");
      }
    }
  }

  void handleMessage(String message) async {
    final Dispense dispense = Dispense(vending: vending);
    final userData = context.read<UserBloc>().state.userData;

    try {
      Map<String, dynamic> jsonData = jsonDecode(message);
      OrderRabbit order = OrderRabbit.fromMap(jsonData);

      if ((order.priority == 2 || order.priority == 3) &&
          (userData[0].role == 'ADMIN' || userData[0].role == 'USER')) {
        Completer<bool> completer = Completer<bool>();

        Future.microtask(() async {
          bool? isConfirmed = await showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              TextEditingController usernameController =
                  TextEditingController();
              TextEditingController passwordController =
                  TextEditingController();

              return AlertDialog(
                title: const Text("ยืนยันตัวตน"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("ปฏิเสธ"),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        final response = await DioHelper.instance.dio
                            .post('/auth/verify-drug', data: {
                          "username": usernameController.text,
                          "password": passwordController.text
                        });

                        if (response.data['data'].isNotEmpty &&
                            response.data['data'] == 'OVERRIDDEN') {
                          Navigator.of(context).pop(true);
                        } else {
                          Navigator.of(context).pop(false);
                        }
                      } catch (error) {
                        if (kDebugMode) {
                          print('Error verifying user: $error');
                        }
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: const Text("อนุญาต"),
                  ),
                ],
              );
            },
          );

          completer.complete(isConfirmed ?? false);
        });

        bool isConfirmed = await completer.future;

        if (!isConfirmed) {
          newMessage!.reject(true);
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            'การอนุมัติถูกปฏิเสธ',
            'e',
          );
          return;
        }
      }

      await dioHelper.dio
          .get('/dispense/order/status/pending/${order.id}/${order.presId}');
      await dioHelper.fetchOrder(context);

      var dispensed = await dispense.sendToMachine(order.qty, order.position);
      if (kDebugMode) {
        print(dispensed);
      }

      if (dispensed) {
        await dioHelper.dio
            .get('/dispense/order/status/receive/${order.id}/${order.presId}');
      } else {
        await dioHelper.dio
            .get('/dispense/order/status/error/${order.id}/${order.presId}');
      }

      await dioHelper.fetchOrder(context);
      await vending.disconnectPort();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void acknowledgeMessage() {
    try {
      if (newMessage != null) {
        newMessage!.ack();
        if (kDebugMode) {
          print("acknowledged message: $ackMessage");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error acknowledging message: $e");
      }
    }
  }

  Future<void> deleteAndRecreateQueue(String queueName) async {
    try {
      Channel channel = await client.channel();
      Queue queue = await channel.queue(queueName, durable: true);

      await queue.delete();
      if (kDebugMode) {
        print("Deleted queue: $queueName");
      }

      await listenToQueue(queueName);
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting and recreating queue: $e");
      }
    }
  }

  Future<String> rejectMessageManually() async {
    final Dispense dispense = Dispense(vending: vending);
    try {
      if (newMessage != null) {
        await dispense.manuallyResetMachine();
        Map<String, dynamic> jsonData = jsonDecode(ackMessage);
        OrderRabbit order = OrderRabbit.fromMap(jsonData);
        await dioHelper.dio
            .get('/dispense/order/status/ready/${order.id}/${order.presId}');
        await dioHelper.fetchOrder(context);
        newMessage!.reject(true);
        if (kDebugMode) {
          print("manually reject message: $ackMessage");
        }
      }
      return 'รีเซ็ตสำเร็จ';
    } catch (e) {
      if (kDebugMode) {
        print("Error manually reject message: $e");
      }
      return 'รีเซ็ตไม่สำเร็จ';
    }
  }

  void closeConnection() {
    client.close();
  }
}
