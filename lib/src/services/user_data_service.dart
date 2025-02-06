import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vending_standalone/src/blocs/users/user_bloc.dart';
import 'package:vending_standalone/src/models/users/user_local_model.dart';

class UserDataService {
  List<Map<String, dynamic>> _userData = [];
  List<Map<String, dynamic>> get userData => _userData;

  Future<void> loadUserData(UserLocal? userLocal) async {
    if (userLocal != null) {
      _userData = [userLocal.toMap()];
    } else {
      _userData = [];
    }
  }

  void updateUserBloc(BuildContext context) {
    if (_userData.isNotEmpty) {
      context.read<UserBloc>().add(
            UserData(
              userData:
                  _userData.map((items) => UserLocal.fromMap(items)).toList(),
            ),
          );
    }
  }
}
