// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vending_standalone/src/blocs/drug/drug_bloc.dart';
import 'package:vending_standalone/src/blocs/inventory/inventory_bloc.dart';
import 'package:vending_standalone/src/blocs/machine/machine_bloc.dart';
import 'package:vending_standalone/src/blocs/order/order_bloc.dart';
import 'package:vending_standalone/src/blocs/users/user_bloc.dart';
import 'package:vending_standalone/src/constants/env.dart';
import 'package:vending_standalone/src/constants/initail_store.dart';
import 'package:vending_standalone/src/models/drugs/drug_list_model.dart';
import 'package:vending_standalone/src/models/drugs/drug_model.dart';
import 'package:vending_standalone/src/models/inventory/inventory.dart';
import 'package:vending_standalone/src/models/machine/machine_model.dart';
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

  Future<void> initializeDio(UserLocal? userData) async {
    try {
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

  Future<void> fetchUsers(BuildContext context) async {
    try {
      final response = await dio.get('/users');
      List<Users> users = parseUsers(response.data['data']);
      context.read<UserBloc>().add(UserList(userList: users));
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return;
          }
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            '${error.response?.statusCode} - ${error.response?.data['message']}',
            'e',
          );
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

  Future<void> fetchOrder(BuildContext context) async {
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
        if (error.response?.statusCode == 401) {
          await StoredLocal.instance.handleUnauthorized(context);
          return;
        }
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

  Future<void> fetchDrugs(BuildContext context) async {
    try {
      final response = await DioHelper.instance.dio.get('/drugs');
      if (response.data['data'].isNotEmpty) {
        List<Drugs> drugList = (response.data['data'] as List)
            .map((map) => Drugs.fromMap(map as Map<String, dynamic>))
            .toList()
            .cast<Drugs>();

        context.read<DrugBloc>().add(DrugList(drugList: drugList));
      } else {
        context.read<DrugBloc>().add(const DrugList(drugList: []));
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return;
          }
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            '${error.response?.statusCode} - ${error.response?.data['message']}',
            'e',
          );
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

  Future<void> fetchInventory(BuildContext context) async {
    try {
      final response = await DioHelper.instance.dio.get('/inventory');
      if (response.data['data'].isNotEmpty) {
        List<Inventories> inventoryList = (response.data['data'] as List)
            .map((map) => Inventories.fromMap(map as Map<String, dynamic>))
            .toList()
            .cast<Inventories>();

        context
            .read<InventoryBloc>()
            .add(InventoryList(inventoryList: inventoryList));
      } else {
        context
            .read<InventoryBloc>()
            .add(const InventoryList(inventoryList: []));
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return;
          }
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            '${error.response?.statusCode} - ${error.response?.data['message']}',
            'e',
          );
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

  Future<void> fetchMachine(BuildContext context) async {
    try {
      final response = await DioHelper.instance.dio.get('/machine');
      if (response.data['data'].isNotEmpty) {
        List<Machines> machineList = (response.data['data'] as List)
            .map((map) => Machines.fromMap(map as Map<String, dynamic>))
            .toList()
            .cast<Machines>();

        context.read<MachineBloc>().add(MachineList(machineList: machineList));
      } else {
        context.read<MachineBloc>().add(const MachineList(machineList: []));
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return;
          }
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            '${error.response?.statusCode} - ${error.response?.data['message']}',
            'e',
          );
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

  Future<void> fetchGroupInventory(BuildContext context) async {
    try {
      final response = await DioHelper.instance.dio.get('/group-inventory');
      if (response.data['data'].isNotEmpty) {
        List<DrugGroup> machineList = (response.data['data'] as List)
            .map((map) => DrugGroup.fromMap(map as Map<String, dynamic>))
            .toList()
            .cast<DrugGroup>();

        context.read<DrugBloc>().add(DrugInventoryList(drugInventoryList: machineList));
      } else {
        context.read<DrugBloc>().add(const DrugInventoryList(drugInventoryList: []));
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return;
          }
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            '${error.response?.statusCode} - ${error.response?.data['message']}',
            'e',
          );
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
}
