// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/env.dart';
import 'package:vending_standalone/src/constants/security_questions.dart';
import 'package:vending_standalone/src/constants/style.dart';
// import 'package:vending_standalone/src/database/db_helper.dart';
import 'package:vending_standalone/src/models/users/user_model.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';
// import 'package:vending_standalone/src/widgets/md_widget/custom_divider.dart';
import 'package:vending_standalone/src/widgets/md_widget/label_text.dart';
// ignore: depend_on_referenced_packages

class AddUserForm extends StatefulWidget {
  final Users? user;
  const AddUserForm({super.key, this.user});

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  late TextEditingController displayName;
  late TextEditingController userName;
  late TextEditingController userPassword;
  // late TextEditingController answer;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageNetwork;
  late String? selectedRole = widget.user?.role ?? 'USER';
  bool isHidden = false;
  int? selectedQuestion = 1;
  int? selectedStatus = 0;
  var uuid = const Uuid();

  @override
  void initState() {
    displayName = TextEditingController(text: widget.user?.display);
    userName = TextEditingController(text: widget.user?.username);
    userPassword = TextEditingController();
    // answer = TextEditingController(text: widget.user?.answer);

    if (widget.user != null) {
      _imageNetwork = widget.user!.picture!;
      // selectedQuestion = widget.user?.question;
      selectedStatus = widget.user!.status ? 0 : 1;
    }
    super.initState();
  }

  @override
  void dispose() {
    displayName.dispose();
    userName.dispose();
    userPassword.dispose();
    // answer.dispose();
    super.dispose();
  }

  void showPass() {
    setState(() {
      isHidden = !isHidden;
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      if (kDebugMode) {
        print('Picked image path: ${pickedFile.path}');
      }
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  Future handleSubmit(BuildContext context) async {
    String? imagePath = _imageFile?.path;

    if (imagePath != null &&
        displayName.text.isNotEmpty &&
        userName.text.isNotEmpty &&
        userPassword.text.isNotEmpty) {
      try {
        FormData formData = FormData.fromMap({
          'username': userName.text,
          'password': userPassword.text,
          'display': displayName.text,
          'role': selectedRole,
          'image': await MultipartFile.fromFile(
            _imageFile!.path,
            filename: _imageFile!.path.split('/').last,
          ),
        });

        final response = await DioHelper().dio.post(
              '/users',
              data: formData,
              options: Options(headers: {
                'Content-Type': 'multipart/form-data',
              }),
            );

        ScaffoldMessage.show(
            context, Icons.check_circle_outline_rounded, 'User are saved', 's');
        await DioHelper.instance.getUsers(context);
        if (response.statusCode == 201) Navigator.of(context).pop();
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
    } else {
      ScaffoldMessage.show(
          context, Icons.warning_amber_rounded, 'กรุณากรอกข้อมุลให้ครบ', 'w');
    }
  }

  Future handleSubmitEdit(BuildContext context) async {
    String? imagePath = _imageFile?.path;

    if (imagePath != null &&
        displayName.text.isNotEmpty &&
        selectedStatus != null) {
      // var resulst = await DatabaseHelper.instance.updateUser(
      //   context,
      //   {
      //     'displayName': displayName.text,
      //     'userRole': selectedRole,
      //     'userImage': imagePath,
      //     'question': selectedQuestion,
      //     'answer': answer.text,
      //     'userStatus': selectedStatus,
      //     'updatedAt': DateTime.now().toIso8601String(),
      //   },
      //   widget.user!.id,
      // );

      // if (resulst) Navigator.of(context).pop();
    } else {
      ScaffoldMessage.show(
          context, Icons.warning_amber_rounded, 'กรุณากรอกข้อมุลให้ครบ', 'w');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'ชื่อ'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: displayName,
              style: CustomInputStyle.inputStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          widget.user == null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: CustomPadding.paddingAll_10,
                            child: CustomLabel(text: 'ชื่อผู้ใช้'),
                          ),
                          Container(
                            height: CustomInputStyle.inputHeight,
                            margin: CustomMargin.marginSymmetricVertical_1,
                            padding: CustomPadding.paddingSymmetricInput,
                            decoration: CustomInputStyle.inputBoxdecoration,
                            child: TextFormField(
                              controller: userName,
                              style: CustomInputStyle.inputStyle,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintStyle: CustomInputStyle.inputHintStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: CustomPadding.paddingAll_10,
                            child: CustomLabel(text: 'รหัสผ่าน'),
                          ),
                          Container(
                            height: CustomInputStyle.inputHeight,
                            margin: CustomMargin.marginSymmetricVertical_1,
                            padding: CustomPadding.paddingSymmetricInput,
                            decoration: CustomInputStyle.inputBoxdecoration,
                            child: TextFormField(
                              controller: userPassword,
                              style: CustomInputStyle.inputStyle,
                              obscureText: !isHidden,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: CustomInputStyle.inputHintStyle,
                                suffixIcon: IconButton(
                                  alignment: Alignment.center,
                                  color: ColorsTheme.grey,
                                  onPressed: showPass,
                                  icon: Icon(
                                    !isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'สิทธิ์'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Checkbox(
                        activeColor: ColorsTheme.primary,
                        focusColor: ColorsTheme.primary,
                        value: selectedRole == 'SUPER',
                        onChanged: (bool? isChecked) {
                          setState(() {
                            selectedRole = 'SUPER';
                          });
                        },
                      ),
                    ),
                    CustomGap.smallWidthGap,
                    const Text(
                      'SUPER',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
                CustomGap.mediumWidthGap,
                Row(
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Checkbox(
                        activeColor: ColorsTheme.primary,
                        focusColor: ColorsTheme.primary,
                        value: selectedRole == 'ADMIN',
                        onChanged: (bool? isChecked) {
                          setState(() {
                            selectedRole = 'ADMIN';
                          });
                        },
                      ),
                    ),
                    CustomGap.smallWidthGap,
                    const Text(
                      'ADMIN',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
                CustomGap.mediumWidthGap,
                Row(
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Checkbox(
                        activeColor: ColorsTheme.primary,
                        focusColor: ColorsTheme.primary,
                        value: selectedRole == 'USER',
                        onChanged: (bool? isChecked) {
                          setState(() {
                            selectedRole = 'USER';
                          });
                        },
                      ),
                    ),
                    CustomGap.smallWidthGap,
                    const Text(
                      'USER',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          widget.user != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomGap.smallHeightGap,
                    const Padding(
                      padding: CustomPadding.paddingAll_10,
                      child: CustomLabel(text: 'สถานะการใช้งาน'),
                    ),
                    Container(
                      height: CustomInputStyle.inputHeight,
                      margin: CustomMargin.marginSymmetricVertical_1,
                      padding: CustomPadding.paddingSymmetricInput,
                      decoration: CustomInputStyle.inputBoxdecoration,
                      child: DropdownButton<int>(
                        dropdownColor: Colors.white,
                        value: selectedStatus,
                        hint: const Text('เลือกสถานะ'),
                        items: SecurityUserStatus.status.map((question) {
                          return DropdownMenuItem<int>(
                            value: question['value'],
                            child: Text(
                              question['label'],
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    )
                  ],
                )
              : Container(),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'รูปภาพ'),
          ),
          GestureDetector(
            onTap: pickImage,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          width: 300.0,
                          height: 300.0,
                          fit: BoxFit.cover,
                        )
                      : (_imageNetwork != null
                          ? Image.network(
                              '${Env.imageUrl}$_imageNetwork',
                              width: 300.0,
                              height: 300.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.image,
                                size: 52.0,
                                color: ColorsTheme.grey,
                              ),
                            )
                          : Image.asset(
                              'lib/src/assets/images/user_placeholder.png',
                              width: 300.0,
                              height: 300.0,
                              fit: BoxFit.contain,
                            )),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                          alpha: 0.5), // Semi-transparent background
                      borderRadius: const BorderRadius.only(
                        bottomLeft:
                            Radius.circular(16.0), // Match border radius
                        bottomRight:
                            Radius.circular(16.0), // Match border radius
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'เลือกรูปภาพ', // "Pick Image" in Thai
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // CustomGap.mediumHeightGap,
          // const CustomDivider(text: "คำถามป้องกันการลืมรหัสผ่าน"),
          // CustomGap.mediumHeightGap,
          // const Padding(
          //   padding: CustomPadding.paddingAll_10,
          //   child: CustomLabel(text: 'คำถาม'),
          // ),
          // Container(
          //   height: CustomInputStyle.inputHeight,
          //   margin: CustomMargin.marginSymmetricVertical_1,
          //   padding: CustomPadding.paddingSymmetricInput,
          //   decoration: CustomInputStyle.inputBoxdecoration,
          //   child: DropdownButton<int>(
          //     dropdownColor: Colors.white,
          //     value: selectedQuestion,
          //     hint: const Text('เลือกคำถาม'),
          //     items: SecurityQuestions.questions.map((question) {
          //       return DropdownMenuItem<int>(
          //         value: question['value'],
          //         child: Text(
          //           question['label'],
          //           style: const TextStyle(fontSize: 20.0),
          //         ),
          //       );
          //     }).toList(),
          //     onChanged: (value) {
          //       setState(() {
          //         selectedQuestion = value;
          //       });
          //     },
          //     isExpanded: true,
          //     underline: const SizedBox(),
          //   ),
          // ),
          // CustomGap.smallHeightGap,
          // const Padding(
          //   padding: CustomPadding.paddingAll_10,
          //   child: CustomLabel(text: 'คำตอบ'),
          // ),
          // Container(
          //   height: CustomInputStyle.inputHeight,
          //   margin: CustomMargin.marginSymmetricVertical_1,
          //   padding: CustomPadding.paddingSymmetricInput,
          //   decoration: CustomInputStyle.inputBoxdecoration,
          //   child: TextFormField(
          //     controller: answer,
          //     style: CustomInputStyle.inputStyle,
          //     decoration: const InputDecoration(
          //       border: InputBorder.none,
          //       hintStyle: CustomInputStyle.inputHintStyle,
          //     ),
          //   ),
          // ),
          CustomGap.mediumHeightGap,
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            decoration: CustomInputStyle.buttonBoxdecoration,
            child: TextButton(
              onPressed: () => widget.user != null
                  ? handleSubmitEdit(context)
                  : handleSubmit(context),
              child: const Text(
                "บันทึก",
                style: CustomInputStyle.textButtonStyle,
              ),
            ),
          )
        ],
      ),
    );
  }
}
