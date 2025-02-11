// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/blocs/drug/drug_bloc.dart';
import 'package:vending_standalone/src/configs/routes.dart' as custom_route;
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/initail_store.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/models/drugs/drug_model.dart';
import 'package:vending_standalone/src/screens/add_drug.dart';
import 'package:vending_standalone/src/widgets/manage_user_widget/image_file.dart';
import 'package:vending_standalone/src/widgets/md_widget/app_bar.dart';
import 'package:vending_standalone/src/widgets/md_widget/floating_button.dart';
import 'package:vending_standalone/src/widgets/utils/no_data.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';
import 'package:vending_standalone/src/widgets/utils/search_widget.dart';

class ManageDrugScreen extends StatefulWidget {
  const ManageDrugScreen({super.key});

  @override
  State<ManageDrugScreen> createState() => _ManageDrugScreenState();
}

class _ManageDrugScreenState extends State<ManageDrugScreen> {
  late TextEditingController searchController;
  List<Drugs> filteredDrug = [];
  late bool loading = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    final drugList = context.read<DrugBloc>().state.drugList;

    setState(() {
      filteredDrug = drugList.where((drug) {
        final drugName = drug.drugName.toLowerCase();
        final drugUnit = drug.unit.toLowerCase();
        return drugName.contains(query) || drugUnit.contains(query);
      }).toList();
    });
  }

  Future<bool> deleteDrug(String id, String name) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'ยืนยันการลบ',
            style: TextStyle(
              fontSize: 27.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'คุณต้องการลบ "ยา $name" หรือไม่?',
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'ยกเลิก',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'ลบ',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.red,
                ),
              ),
              onPressed: () async {
                try {
                  final response =
                      await DioHelper.instance.dio.delete('/drugs/$id');
                  if (response.data['data'].isNotEmpty) {
                    await DioHelper.instance.fetchDrugs(context);
                    ScaffoldMessage.show(
                        context,
                        Icons.check_circle_outline_rounded,
                        'ยา $name ถูกลบแล้ว',
                        's');
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).pop(false);
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
              },
            ),
          ],
        );
      },
    );

    return shouldDelete ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'จัดการยา',
        isBottom: false,
      ),
      body: Container(
        color: Colors.white,
        child: !loading
            ? Column(
                children: [
                  SearchWidget(
                    searchController: searchController,
                    onSearchChanged: _onSearchChanged,
                    text: 'ค้นหายา...',
                    isNumber: false,
                  ),
                  CustomGap.smallHeightGap,
                  Expanded(
                    child: BlocBuilder<DrugBloc, DrugState>(
                      builder: (context, state) {
                        final drugList = filteredDrug.isNotEmpty ||
                                searchController.text.isNotEmpty
                            ? filteredDrug
                            : state.drugList;
                        if (drugList.isNotEmpty) {
                          return ListView.builder(
                            itemCount: drugList.length,
                            itemBuilder: (context, index) {
                              final drug = drugList[index];
                              return Dismissible(
                                key: Key(drug.id),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async =>
                                    await deleteDrug(
                                        drug.drugCode, drug.drugName),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddDrugScreen(
                                                titleText: 'แก้ไขยา',
                                                drug: drug,
                                              ),
                                            ),
                                          );
                                        },
                                        splashColor: ColorsTheme.primary
                                            .withValues(alpha: 0.3),
                                        title: Text(
                                          drug.drugName,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Lot: ${drug.drugLot}',
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                                CustomGap.smallWidthGap,
                                                const Text(
                                                  '|',
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                CustomGap.smallWidthGap,
                                                Text(
                                                  'Expire: ${DateFormat('dd/MM/yyyy').format(drug.drugExpire)}',
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                            CustomGap.smallHeightGap,
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                      color: ColorsTheme.grey,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    drug.unit,
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                    ),
                                                  ),
                                                ),
                                                CustomGap.smallWidthGap_1,
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: drug.drugPriority ==
                                                            1
                                                        ? Colors.transparent
                                                        : drug.drugPriority == 2
                                                            ? Colors.yellow
                                                            : Colors.pink,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                      color: drug.drugPriority ==
                                                              1
                                                          ? ColorsTheme.grey
                                                          : drug.drugPriority ==
                                                                  2
                                                              ? Colors.yellow
                                                              : Colors.pink,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    drug.drugPriority == 1
                                                        ? 'ยาทั่วไป'
                                                        : drug.drugPriority == 2
                                                            ? 'ยา HAD'
                                                            : 'ยา Narcotic',
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: drug.drugPriority ==
                                                              1
                                                          ? Colors.black
                                                          : drug.drugPriority ==
                                                                  2
                                                              ? Colors.black
                                                              : Colors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        leading: SizedBox(
                                          width: 100.0,
                                          child: Center(
                                            child:
                                                ImageNetwork(file: drug.picture!),
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.navigate_next,
                                          size: 36.0,
                                        ),
                                      ),
                                      Divider(
                                        thickness: 1.0,
                                        color: Colors.grey[300],
                                        height: 7.0,
                                        indent: 130.0,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const NoData(
                            icon: Icons.medical_information,
                            text: 'ไม่พบข้อมูลยา',
                          );
                        }
                      },
                    ),
                  ),
                ],
              )
            : const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    CustomGap.mediumHeightGap,
                    Text(
                      'Loading...',
                      style: TextStyle(fontSize: 24.0),
                    )
                  ],
                ),
              ),
      ),
      floatingActionButton: const FloatingButton(
        text: 'เพิ่มยา',
        icon: Icons.add,
        route: custom_route.Routes.adddrug,
      ),
    );
  }
}
