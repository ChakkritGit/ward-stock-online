// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/models/inventory/inventory.dart';
import 'package:vending_standalone/src/models/machine/machine_model.dart';
import 'package:vending_standalone/src/widgets/md_widget/label_text.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';

class AddInventoryForm extends StatefulWidget {
  final List<Map<String, dynamic>> availablePositions;
  final List<Machines> machines;
  final Inventories? inventory;
  const AddInventoryForm(
      {super.key,
      required this.machines,
      required this.availablePositions,
      this.inventory});

  @override
  State<AddInventoryForm> createState() => _AddInventoryFormState();
}

class _AddInventoryFormState extends State<AddInventoryForm> {
  int? selectedPosition;
  String? selectedMachineId;

  late TextEditingController inventoryMin;
  late TextEditingController inventoryMAX;
  bool isLoading = false;

  Future handleSubmit(BuildContext context) async {
    if (selectedPosition != null &&
        selectedMachineId != null &&
        inventoryMin.text.isNotEmpty &&
        inventoryMAX.text.isNotEmpty) {
      try {
        final body = {
          'position': selectedPosition,
          'min': int.tryParse(inventoryMin.text),
          'max': int.tryParse(inventoryMAX.text),
          'machineId': selectedMachineId
        };
        final response = await DioHelper().dio.post('/inventory', data: body);

        ScaffoldMessage.show(context, Icons.check_circle_outline_rounded,
            'Inventory are saved', 's');
        await DioHelper.instance.fetchInventory(context);
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
    if (inventoryMin.text.isNotEmpty &&
        inventoryMAX.text.isNotEmpty) {
      try {
        final body = {
          'min': int.tryParse(inventoryMin.text),
          'max': int.tryParse(inventoryMAX.text)
        };
        final response = await DioHelper().dio.patch('/inventory/$id', data: body);

        ScaffoldMessage.show(context, Icons.check_circle_outline_rounded,
            'Inventory are edited', 's');
        await DioHelper.instance.fetchInventory(context);
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
    // inventoryQty = TextEditingController();
    inventoryMin =
        TextEditingController(text: widget.inventory?.min.toString());
    inventoryMAX =
        TextEditingController(text: widget.inventory?.max.toString());
    super.initState();
  }

  @override
  void dispose() {
    // inventoryQty.dispose();
    inventoryMin.dispose();
    inventoryMAX.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.inventory != null
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: CustomPadding.paddingAll_10,
                      child: CustomLabel(text: 'ตำแหน่ง'),
                    ),
                    Container(
                      height: CustomInputStyle.inputHeight,
                      margin: CustomMargin.marginSymmetricVertical_1,
                      padding: CustomPadding.paddingSymmetricInput,
                      decoration: CustomInputStyle.inputBoxdecoration,
                      child: DropdownButton<int>(
                        dropdownColor: Colors.white,
                        value: selectedPosition,
                        hint: const Text(
                          'เลือกตำแหน่ง',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        items: widget.availablePositions.map((position) {
                          return DropdownMenuItem<int>(
                            value: position['value'],
                            child: Text(
                              position['label'],
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPosition = value;
                          });
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),
                    CustomGap.smallHeightGap,
                  ],
                ),
          const Padding(
            padding: CustomPadding.paddingAll_10,
            child: CustomLabel(text: 'Min'),
          ),
          Container(
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: inventoryMin,
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
            child: CustomLabel(text: 'Max'),
          ),
          Container(
            height: CustomInputStyle.inputHeight,
            margin: CustomMargin.marginSymmetricVertical_1,
            padding: CustomPadding.paddingSymmetricInput,
            decoration: CustomInputStyle.inputBoxdecoration,
            child: TextFormField(
              controller: inventoryMAX,
              keyboardType: TextInputType.number,
              style: CustomInputStyle.inputStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: CustomInputStyle.inputHintStyle,
              ),
            ),
          ),
          widget.inventory != null
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomGap.smallHeightGap,
                    const Padding(
                      padding: CustomPadding.paddingAll_10,
                      child: CustomLabel(text: 'เลือกเครื่อง'),
                    ),
                    Container(
                      height: CustomInputStyle.inputHeight,
                      margin: CustomMargin.marginSymmetricVertical_1,
                      padding: CustomPadding.paddingSymmetricInput,
                      decoration: CustomInputStyle.inputBoxdecoration,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        hint: const Text(
                          'เลือกเครื่อง',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        value: selectedMachineId,
                        items: widget.machines.map((machine) {
                          return DropdownMenuItem<String>(
                            value: machine.id,
                            child: Text(
                              machine.machineName,
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMachineId = value;
                          });
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),
                  ],
                ),
          CustomGap.mediumHeightGap,
          Container(
            width: CustomInputStyle.inputWidth,
            height: CustomInputStyle.inputHeight,
            decoration: CustomInputStyle.buttonBoxdecoration,
            child: TextButton(
              onPressed: () => widget.inventory != null
                  ? handleSubmitEdit(context, widget.inventory!.id)
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
