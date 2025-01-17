// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/blocs/order/order_bloc.dart';
import 'package:vending_standalone/src/blocs/users/user_bloc.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/initail_store.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/models/order/order_model.dart';
import 'package:vending_standalone/src/models/users/user_local_model.dart';
import 'package:vending_standalone/src/services/RabbitMQ.dart';
import 'package:vending_standalone/src/services/serialport.dart';
import 'package:vending_standalone/src/services/user_data_service.dart';
import 'package:vending_standalone/src/widgets/home_widget/app_bar.dart';
import 'package:vending_standalone/src/widgets/home_widget/menu_list.dart';
import 'package:dio/dio.dart';
import 'package:vending_standalone/src/widgets/home_widget/prescription_order.dart';
import 'package:vending_standalone/src/widgets/utils/scaffold_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dioHelper = DioHelper();
  final VendingMachine vending = VendingMachine();
  late RabbitMQService rabbitMQ =
      RabbitMQService(vending: vending, context: context);

  final UserDataService userDataService = UserDataService();
  String buffer = '';
  late bool loading = false;

  void handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final String key = event.data.logicalKey.keyLabel;
      if (key == 'Enter') {
        setState(() {
          if (kDebugMode) {
            print('Buffer: $buffer');
          }
          if (buffer.length <= 1) {
            handleScannedData(buffer);
          } else {
            handleAck(buffer);
          }
          buffer = '';
        });
      } else {
        if (key != 'Shift Left') {
          setState(() {
            buffer += key;
          });
        }
      }
    }
  }

  Future handleAck(String qrText) async {
    try {
      var state = context.read<OrderBloc>().state.orderList;
      await dioHelper.dio
          .get('/dispense/order/status/complete/$qrText/${state[0].id}');
      rabbitMQ.acknowledgeMessage();
      await dioHelper.getOrder(context);
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            '${error.response?.data['message']}',
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
  }

  Future handleScannedData(String qrText) async {
    try {
      var state = context.read<OrderBloc>().state.orderList;
      if (state.isEmpty) {
        setState(() {
          loading = true;
        });
      }
      final response = await dioHelper.dio.get('/dispense/$qrText');
      final prescription = Prescription.fromJson(response.data['data']);
      context.read<OrderBloc>().add(OrderList(orderList: [prescription]));
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          ScaffoldMessage.show(
            context,
            Icons.error_outline_rounded,
            '${error.response?.data['message']}',
            'e',
          );
          if (kDebugMode) {
            print('Error Message: ${error.response?.data['message']}');
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
        loading = false;
      });
    }
  }

  Future initialData() async {
    await rabbitMQ.listenToQueue("vdOrder");
    UserLocal? userData = await StoredLocal.instance.getUserData();
    if (userData != null) {
      setState(() {
        loading = true;
      });
      await dioHelper.initializeDio();
      await userDataService.loadUserData(userData);
      userDataService.updateUserBloc(context);

      await dioHelper.getUsers(context);
      await dioHelper.getOrder(context);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    vending.connectPort();
    initialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const HomeAppBar(),
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: handleKeyEvent,
          child: Container(
            color: ColorsTheme.primary,
            child: Column(
              children: [
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state.userData.isNotEmpty) {
                      final user = state.userData[0];
                      return user.role == 'SUPER' || user.role == 'ADMIN'
                          ? const MenuList()
                          : Container();
                    }
                    return Container();
                  },
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35.0),
                        topRight: Radius.circular(35.0),
                      ),
                    ),
                    child: !loading
                        ? PrescriptionOrderCardWidget(
                            rabbitMQ: rabbitMQ,
                          )
                        : const Column(
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
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 30.0,
          children: [
            Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.large(
                  heroTag: 'uniqueTag1',
                  backgroundColor: ColorsTheme.primary,
                  onPressed: () async {
                    try {
                      await rabbitMQ.deleteAndRecreateQueue('vdOrder');
                      var response = await dioHelper.dio
                          .get('/dispense/prescription/order/clear');
                      await dioHelper.getOrder(context);
                      ScaffoldMessage.show(
                        context,
                        Icons.check_circle_outline_rounded,
                        response.data['data'],
                        's',
                      );
                    } catch (error) {
                      if (kDebugMode) {
                        print(error);
                      }
                      ScaffoldMessage.show(
                        context,
                        Icons.error_outline_rounded,
                        'เกิดข้อผิดพลาด!',
                        'e',
                      );
                    }
                  },
                  child: const Icon(
                    Icons.restore_page_outlined,
                    size: 54.0,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'รีเซ็ตรายการ',
                  style: TextStyle(fontSize: 20.0),
                )
              ],
            ),
            Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.large(
                  heroTag: 'uniqueTag2',
                  backgroundColor: ColorsTheme.error,
                  onPressed: () async {
                    try {
                      final resetSuccess =
                          await rabbitMQ.rejectMessageManually();
                      ScaffoldMessage.show(
                        context,
                        Icons.check_circle_outline_rounded,
                        resetSuccess,
                        's',
                      );
                    } catch (error) {
                      if (kDebugMode) {
                        print(error);
                      }
                      ScaffoldMessage.show(
                        context,
                        Icons.error_outline_rounded,
                        'เกิดข้อผิดพลาด!',
                        'e',
                      );
                    }
                  },
                  child: const Icon(
                    Icons.running_with_errors_outlined,
                    size: 54.0,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'รีเซ็ตเครื่อง',
                  style: TextStyle(fontSize: 20.0),
                )
              ],
            )
          ],
        ));
  }
}
