import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vending_standalone/src/models/users/user_local_model.dart';

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
}
