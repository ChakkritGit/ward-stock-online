// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/constants/security_questions.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/models/machine/machine_model.dart';
import 'package:vending_standalone/src/widgets/md_widget/label_text.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';

class AddMachineForm extends StatefulWidget {
  final Machines? machine;
  const AddMachineForm({super.key, this.machine});

  @override
  State<AddMachineForm> createState() => _AddMachineFormState();
}

class _AddMachineFormState extends State<AddMachineForm> {
  late TextEditingController machineName;
  late TextEditingController capacity;
  late TextEditingController location;
  bool? selectedStatus = false;
  bool isLoading = false;

  @override
  void initState() {
    machineName = TextEditingController(text: widget.machine?.machineName);
    capacity = TextEditingController(text: widget.machine?.capacity.toString());
    location = TextEditingController(text: widget.machine?.location);

    if (widget.machine != null) {
      selectedStatus = widget.machine?.status;
    }
    super.initState();
  }

  @override
  void dispose() {
    machineName.dispose();
    capacity.dispose();
    location.dispose();
    super.dispose();
  }

  Future handleSubmit(BuildContext context) async {
    if (machineName.text.isNotEmpty &&
        capacity.text.isNotEmpty &&
        location.text.isNotEmpty) {
      try {
        setState(() {
          isLoading = true;
        });
        final body = {
          'machineName': machineName.text,
          'capacity': int.tryParse(capacity.text),
          'location': location.text
        };
        final response = await DioHelper().dio.post('/machine', data: body);

        ScaffoldMessage.show(context, Icons.check_circle_outline_rounded,
            'Machine are saved', 's');
        await DioHelper.instance.fetchMachine(context);
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
    if (machineName.text.isNotEmpty &&
        capacity.text.isNotEmpty &&
        location.text.isNotEmpty &&
        selectedStatus != null) {
      try {
        setState(() {
          isLoading = true;
        });
        final body = {
          'machineName': machineName.text,
          'capacity': int.tryParse(capacity.text),
          'location': location.text,
          'status': selectedStatus
        };
        final response = await DioHelper().dio.patch('/machine/$id', data: body);

        ScaffoldMessage.show(context, Icons.check_circle_outline_rounded,
            'Machine are edited', 's');
        await DioHelper.instance.fetchMachine(context);
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
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'ชื่อเครื่อง'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: machineName,
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
            child: CustomLabel(text: 'ความจุของเครื่อง'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: capacity,
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
            child: CustomLabel(text: 'ตำแหน่งเครื่อง'),
          ),
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: location,
              style: CustomInputStyle.inputStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          widget.machine != null
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
                        value: selectedStatus! ? 1 : 0,
                        hint: const Text('เลือกสถานะ'),
                        items: SecurityUserStatus.status.map((question) {
                          return DropdownMenuItem<int>(
                            value: question['value'] ? 1 : 0,
                            child: Text(
                              question['label'],
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value == 1 ? true : false;
                          });
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    )
                  ],
                )
              : Container(),
          CustomGap.mediumHeightGap,
          !isLoading
              ? Container(
                  width: CustomInputStyle.inputWidth,
                  height: CustomInputStyle.inputHeight,
                  decoration: CustomInputStyle.buttonBoxdecoration,
                  child: TextButton(
                    onPressed: () => widget.machine != null
                        ? handleSubmitEdit(context, widget.machine!.id)
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
