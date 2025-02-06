// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/env.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/models/drugs/drug_model.dart';
import 'package:vending_standalone/src/widgets/md_widget/label_text.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';

class AddDrugForm extends StatefulWidget {
  final Drugs? drug;
  const AddDrugForm({super.key, this.drug});

  @override
  State<AddDrugForm> createState() => _AddDrugFormState();
}

class _AddDrugFormState extends State<AddDrugForm> {
  final ImagePicker _picker = ImagePicker();
  late int? selectedPriority = widget.drug?.drugPriority ?? 1;
  late TextEditingController drugCode;
  late TextEditingController drugName;
  late TextEditingController drugUnit;
  late TextEditingController weight;
  late TextEditingController drugLot;
  late TextEditingController drugExpire;
  File? _imageFile;
  String? _imageNetwork;
  var uuid = const Uuid();
  bool isLoading = false;

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

    if (drugName.text.isNotEmpty &&
        drugUnit.text.isNotEmpty &&
        drugLot.text.isNotEmpty &&
        drugExpire.text.isNotEmpty) {
      try {
        setState(() {
          isLoading = true;
        });
        FormData formData = FormData.fromMap(imagePath != null
            ? {
                'drugCode': drugCode.text,
                'drugName': drugName.text,
                'unit': drugUnit.text,
                'weight': weight.text,
                'drugLot': drugLot.text,
                'drugExpire': drugExpire.text,
                'drugPriority': selectedPriority,
                'image': await MultipartFile.fromFile(
                  _imageFile!.path,
                  filename: _imageFile!.path.split('/').last,
                )
              }
            : {
                'drugCode': drugCode.text,
                'drugName': drugName.text,
                'unit': drugUnit.text,
                'weight': weight.text,
                'drugLot': drugLot.text,
                'drugExpire': drugExpire.text,
                'drugPriority': selectedPriority
              });

        final response = await DioHelper().dio.post(
              '/drugs',
              data: formData,
              options: Options(headers: {
                'Content-Type': 'multipart/form-data',
              }),
            );

        ScaffoldMessage.show(
            context, Icons.check_circle_outline_rounded, 'Drug are saved', 's');
        await DioHelper.instance.fetchDrugs(context);
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
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessage.show(
          context, Icons.warning_amber_rounded, 'กรุณากรอกข้อมุลให้ครบ', 'w');
    }
  }

  Future handleSubmitEdit(BuildContext context, String id) async {
    String? imagePath = _imageFile?.path;

    if (drugName.text.isNotEmpty &&
        drugUnit.text.isNotEmpty &&
        drugLot.text.isNotEmpty &&
        drugExpire.text.isNotEmpty) {
      try {
        setState(() {
          isLoading = true;
        });
        FormData formData = FormData.fromMap(imagePath != null
            ? {
                'drugCode': drugCode.text,
                'drugName': drugName.text,
                'unit': drugUnit.text,
                'weight': weight.text,
                'drugLot': drugLot.text,
                'drugExpire': drugExpire.text,
                'drugPriority': selectedPriority,
                'image': await MultipartFile.fromFile(
                  _imageFile!.path,
                  filename: _imageFile!.path.split('/').last,
                )
              }
            : {
                'drugCode': drugCode.text,
                'drugName': drugName.text,
                'unit': drugUnit.text,
                'weight': weight.text,
                'drugLot': drugLot.text,
                'drugExpire': drugExpire.text,
                'drugPriority': selectedPriority
              });

        final response = await DioHelper().dio.patch(
              '/drugs/$id',
              data: formData,
              options: Options(headers: {
                'Content-Type': 'multipart/form-data',
              }),
            );

        ScaffoldMessage.show(
            context, Icons.check_circle_outline_rounded, 'Drug are saved', 's');
        await DioHelper.instance.fetchDrugs(context);
        if (response.statusCode == 200) Navigator.of(context).pop();
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
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessage.show(
          context, Icons.warning_amber_rounded, 'กรุณากรอกข้อมุลให้ครบ', 'w');
    }
  }

  @override
  void initState() {
    drugCode = TextEditingController(text: widget.drug?.drugCode);
    drugName = TextEditingController(text: widget.drug?.drugName);
    drugUnit = TextEditingController(text: widget.drug?.unit);
    weight = TextEditingController(text: widget.drug?.weight.toString());
    drugLot = TextEditingController(
        text: widget.drug?.drugLot != null
            ? DateFormat('dd/MM/yyyy').format(widget.drug!.drugLot)
            : '');
    drugExpire = TextEditingController(
        text: widget.drug?.drugExpire != null
            ? DateFormat('dd/MM/yyyy').format(widget.drug!.drugExpire)
            : '');

    if (widget.drug != null) {
      _imageNetwork = widget.drug!.picture!;
    }
    super.initState();
  }

  @override
  void dispose() {
    drugCode.dispose();
    drugName.dispose();
    drugUnit.dispose();
    weight.dispose();
    drugLot.dispose();
    drugExpire.dispose();
    super.dispose();
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
            child: CustomLabel(text: 'รูปภาพ'),
          ),
          Center(
            child: GestureDetector(
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
          ),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'รหัสยา'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: drugCode,
              style: CustomInputStyle.inputStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'ชื่อยา'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: drugName,
              style: CustomInputStyle.inputStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'หน่วย'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: drugUnit,
              style: CustomInputStyle.inputStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'น้ำหนัก'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: weight,
              keyboardType: TextInputType.number,
              style: CustomInputStyle.inputStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'ล็อต'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: drugLot.text.isNotEmpty
                      ? DateFormat('dd/MM/yyyy').parse(drugLot.text)
                      : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('th', 'TH'),
                );

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                  drugLot.text = formattedDate;
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: drugLot,
                  style: CustomInputStyle.inputStyle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'เลือกวันหมดอายุ',
                    hintStyle: CustomInputStyle.inputHintStyle,
                  ),
                ),
              ),
            ),
          ),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'วันหมดอายุ'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: drugExpire.text.isNotEmpty
                      ? DateFormat('dd/MM/yyyy').parse(drugExpire.text)
                      : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('th', 'TH'),
                );

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                  drugExpire.text = formattedDate;
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: drugExpire,
                  style: CustomInputStyle.inputStyle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'เลือกวันหมดอายุ',
                    hintStyle: CustomInputStyle.inputHintStyle,
                  ),
                ),
              ),
            ),
          ),
          CustomGap.smallHeightGap,
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'ยาที่มีความสำคัญ'),
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
                        value: selectedPriority == 1,
                        onChanged: (bool? isChecked) {
                          setState(() {
                            selectedPriority = 1;
                          });
                        },
                      ),
                    ),
                    CustomGap.smallWidthGap,
                    const Text(
                      'Normal',
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
                        value: selectedPriority == 2,
                        onChanged: (bool? isChecked) {
                          setState(() {
                            selectedPriority = 2;
                          });
                        },
                      ),
                    ),
                    CustomGap.smallWidthGap,
                    const Text(
                      'HAD',
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
                        value: selectedPriority == 3,
                        onChanged: (bool? isChecked) {
                          setState(() {
                            selectedPriority = 3;
                          });
                        },
                      ),
                    ),
                    CustomGap.smallWidthGap,
                    const Text(
                      'Narcotic',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomGap.mediumHeightGap,
          !isLoading
              ? Container(
                  width: CustomInputStyle.inputWidth,
                  height: CustomInputStyle.inputHeight,
                  decoration: CustomInputStyle.buttonBoxdecoration,
                  child: TextButton(
                    onPressed: () => widget.drug != null
                        ? handleSubmitEdit(context, widget.drug!.drugCode)
                        : handleSubmit(context),
                    child: const Text(
                      "บันทึก",
                      style: CustomInputStyle.textButtonStyle,
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
