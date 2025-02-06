// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/constants/initail_store.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';

class MachineStatus {
  static final List<Map<String, dynamic>> questions = [
    {'label': 'ใช้งาน', 'value': 0},
    {'label': 'ปิดการใช้งาน', 'value': 1},
  ];
}

class InventoryPosition {
  static List<Map<String, dynamic>> position = List.generate(
    60,
    (index) => {'label': 'ช่องที่ ${index + 1}', 'value': index + 1},
  );

  static Future<List<Map<String, dynamic>>> getAvailablePositions(
      BuildContext context) async {
    try {
      final existingPositions = await DioHelper.instance.dio.get('/inventory');
      if (existingPositions.data['data'].isNotEmpty) {
        return position
            .where((position) => !existingPositions.data['data']
                .map((item) => item['position'])
                .contains(position['value']))
            .toList();
      } else {
        return [];
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return [];
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
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMachines(
      BuildContext context) async {
    try {
      final machineData = await DioHelper.instance.dio.get('/machine');
      if (machineData.data['data'].isNotEmpty &&
          machineData.data['data'] is List) {
        return List<Map<String, dynamic>>.from(machineData.data['data']
            .map((item) => Map<String, dynamic>.from(item)));
      }
      return [];
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return [];
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
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getInventory(
      BuildContext context) async {
    try {
      final inventory = await DioHelper.instance.dio.get('/inventory');
      final inventoryValue = await DioHelper.instance.dio.get('/inventory/exist');
      if (inventory.data['data'].isNotEmpty &&
          inventory.data['data'] is List &&
          inventoryValue.data['data'].isNotEmpty &&
          inventoryValue.data['data'] is List) {
        final finaldata = inventory.data['data']
            .where((inventory) => !inventoryValue.data['data']
                .map((row) => row['inventoryId'])
                .contains(inventory['id']))
            .toList();

        return List<Map<String, dynamic>>.from(
            finaldata.map((item) => Map<String, dynamic>.from(item)));
      }
      return [];
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return [];
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
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAvailableDrug(
      BuildContext context) async {
    try {
      final drugData = await DioHelper.instance.dio.get('/drugs');
      final drugExit = await DioHelper.instance.dio.get('/drugs/exist');
      if (drugData.data['data'].isNotEmpty &&
          drugData.data['data'] is List &&
          drugExit.data['data'].isNotEmpty &&
          drugExit.data['data'] is List) {
        final finaldata = drugData.data['data']
            .where((drug) => !drugExit.data['data']
                .map((row) => row['drugId'])
                .contains(drug['id']))
            .toList();

        return List<Map<String, dynamic>>.from(
            finaldata.map((item) => Map<String, dynamic>.from(item)));
      }
      return [];
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return [];
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
      return [];
    }
  }
}
