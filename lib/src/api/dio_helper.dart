// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vending_standalone/src/blocs/order/order_bloc.dart';
import 'package:vending_standalone/src/blocs/users/user_bloc.dart';
import 'package:vending_standalone/src/constants/env.dart';
import 'package:vending_standalone/src/constants/initail_store.dart';
import 'package:vending_standalone/src/models/order/order_model.dart';
import 'package:vending_standalone/src/models/users/user_local_model.dart';
import 'package:vending_standalone/src/models/users/user_model.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';

class DioHelper {
  static final DioHelper instance = DioHelper._internal();
  late Dio dio;

  factory DioHelper() => instance;

  DioHelper._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 1),
      ),
    );
  }

  Future<void> initializeDio() async {
    try {
      UserLocal? userData = await StoredLocal.instance.getUserData();
      final token = userData?.token;

      if (token != null) {
        dio.options.headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
      } else {
        throw Exception('User token not found');
      }
    } catch (error) {
      throw Exception('Failed to initialize Dio: $error');
    }
  }

  Future getUsers(BuildContext context) async {
    try {
      final response = await dio.get('/users');
      List<Users> users = parseUsers(response.data['data']);
      context.read<UserBloc>().add(UserList(userList: users));
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          ScaffoldMessage.show(
              context,
              Icons.error_outline_rounded,
              '${error.response?.statusCode} - ${error.response?.data['message']}',
              'e');
          if (kDebugMode) {
            print('Error Message: ${error.response?.data}');
          }
        } else {
          if (kDebugMode) {
            print('DioError: ${error.message}');
          }
        }
      } else {
        if (kDebugMode) {
          print('General error: $error');
        }
      }
    }
  }

  Future getOrder(BuildContext context) async {
    try {
      final response = await dio.get('/dispense/prescription/order');
      if (response.data['data'] != null) {
        final prescription = Prescription.fromJson(response.data['data']);
        context.read<OrderBloc>().add(OrderList(orderList: [prescription]));
      } else {
        context.read<OrderBloc>().add(const OrderList(orderList: []));
      }
    } catch (error) {
      if (error is DioException) {
        if (kDebugMode) {
          print(error.response?.data['message']);
        }
      } else {
        if (kDebugMode) {
          print(error);
        }
      }
    }
  }
}
