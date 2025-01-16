// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:async';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/constants/env.dart';
import 'package:vending_standalone/src/models/rabbit/rabbit_model.dart';
import 'package:vending_standalone/src/services/dispense.dart';
import 'package:vending_standalone/src/services/serialport.dart';

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

        if (kDebugMode) {
          print("Received message: ${message.payloadAsString}");
        }

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
    try {
      Map<String, dynamic> jsonData = jsonDecode(message);
      OrderRabbit order = OrderRabbit.fromMap(jsonData);

      await dioHelper.dio
          .get('/dispense/order/status/pending/${order.id}/${order.presId}');

      await Future.delayed(const Duration(milliseconds: 700));

      await dioHelper.getOrder(context);

      final dispensed = await dispense.sendToMachine(order.qty, order.position);

      if (dispensed) {
        await dioHelper.dio
            .get('/dispense/order/status/receive/${order.id}/${order.presId}');
        await Future.delayed(const Duration(milliseconds: 500));
        await dioHelper.getOrder(context);
        await vending.disconnectPort();
      } else {
        await dioHelper.dio
            .get('/dispense/order/status/error/${order.id}/${order.presId}');
        await Future.delayed(const Duration(milliseconds: 500));
        await dioHelper.getOrder(context);
        await vending.disconnectPort();
      }
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
        newMessage!.reject(true);
        if (kDebugMode) {
          print("manually reject message: $ackMessage");
        }
      }
      return ackMessage;
    } catch (e) {
      if (kDebugMode) {
        print("Error manually reject message: $e");
      }
      return ackMessage;
    }
  }

  void closeConnection() {
    client.close();
  }
}
