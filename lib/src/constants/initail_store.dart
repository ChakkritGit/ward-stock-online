// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_standalone/src/models/users/user_local_model.dart';
import 'package:vending_standalone/src/configs/routes.dart' as custom_route;

class StoredLocal {
  static final StoredLocal instance = StoredLocal._privateConstructor();

  StoredLocal._privateConstructor();

  Future<String?> get storeUserData async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    return userData;
  }

  Future<void> saveUserData(UserLocal user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(user.toMap());
    await prefs.setString('userData', jsonString);
  }

  Future<UserLocal?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('userData');

    if (jsonString != null) {
      Map<String, dynamic> userMap = jsonDecode(jsonString);
      return UserLocal.fromMap(userMap);
    }
    return null;
  }

  Future<void> handleUnauthorized(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');

    Navigator.pushNamedAndRemoveUntil(
      context,
      custom_route.Routes.login,
      (route) => false,
    );
  }
}
