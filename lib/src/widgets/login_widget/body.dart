// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/env.dart';
import 'package:vending_standalone/src/constants/initail_store.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/configs/routes.dart' as custom_route;
import 'package:vending_standalone/src/models/users/user_local_model.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';
import 'package:vending_standalone/src/widgets/login_widget/login_button.dart';
import 'package:dio/dio.dart';

class LoginBodyWidget extends StatefulWidget {
  const LoginBodyWidget({super.key});

  @override
  State<LoginBodyWidget> createState() => _LoginBodyWidgetState();
}

class _LoginBodyWidgetState extends State<LoginBodyWidget> {
  final dio = Dio();
  late TextEditingController userName;
  late TextEditingController userPassword;
  bool isHidden = false;
  bool isLoading = false;

  void login() async {
    if (userName.text.isEmpty || userPassword.text.isEmpty) {
      ScaffoldMessage.show(context, Icons.warning_amber_rounded,
          'กรุณาป้อนชื่อผู้ใช้และรหัสผ่าน', 'w');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await dio.post(
        '${Env.baseUrl}/auth/login',
        data: {
          'username': userName.text,
          'password': userPassword.text,
        },
      );

      final responseData = response.data['data'];

      UserLocal user = UserLocal.fromMap(responseData);

      StoredLocal storage = StoredLocal.instance;
      await storage.saveUserData(user);

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        isLoading = false;
      });

      Navigator.pushNamedAndRemoveUntil(
        context,
        custom_route.Routes.home,
        (route) => false,
      );

      userName.clear();
      userPassword.clear();
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';

      if (error is DioException) {
        if (error.response != null && error.response!.data != null) {
          errorMessage = error.response!.data['message'] ?? errorMessage;
        } else {
          errorMessage = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้';
        }
      } else {
        errorMessage = error.toString();
      }

      ScaffoldMessage.show(
        context,
        Icons.error_outline,
        errorMessage,
        'e',
      );

      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  @override
  void initState() {
    userName = TextEditingController();
    userPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    userName.dispose();
    userPassword.dispose();
    super.dispose();
  }

  void showPass() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              style: CustomInputStyle.inputStyle,
              controller: userName,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                iconColor: ColorsTheme.grey,
                border: InputBorder.none,
                hintText: "ชื่อผู้ใช้",
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              style: CustomInputStyle.inputStyle,
              controller: userPassword,
              obscureText: !isHidden,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock),
                iconColor: ColorsTheme.grey,
                border: InputBorder.none,
                hintText: "รหัสผ่าน",
                hintStyle: CustomInputStyle.inputHintStyle,
                suffixIcon: IconButton(
                  alignment: Alignment.center,
                  color: ColorsTheme.grey,
                  onPressed: showPass,
                  icon: Icon(
                    !isHidden ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
          ),
          CustomGap.smallHeightGap,
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            decoration: isLoading
                ? CustomInputStyle.buttonBoxdecorationDisable
                : CustomInputStyle.buttonBoxdecoration,
            child: LoginButton(
              isLoading: isLoading,
              onPressed: login,
            ),
          )
        ],
      ),
    );
  }
}
