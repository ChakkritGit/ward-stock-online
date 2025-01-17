// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/blocs/order/order_bloc.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/services/RabbitMQ.dart';

class PrescriptionOrderCardWidget extends StatelessWidget {
  final RabbitMQService rabbitMQ;
  const PrescriptionOrderCardWidget({super.key, required this.rabbitMQ});

  @override
  Widget build(BuildContext context) {
    // final dioHelper = DioHelper();
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state.orderList.isNotEmpty) {
          return ListView.builder(
            itemCount: state.orderList.length,
            itemBuilder: (context, index) {
              final prescription = state.orderList[index];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Prescription
                    Text(
                      prescription.patientName,
                      style: const TextStyle(
                        fontSize: 27.0,
                        fontWeight: FontWeight.bold,
                        color: ColorsTheme.primary,
                      ),
                    ),
                    CustomGap.smallHeightGap,
                    Text(
                      'No: ${prescription.id}',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'HN: ${prescription.hn}',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    const SizedBox(height: 5),
                    if (prescription.wardDesc != null)
                      Text(
                        'Ward: ${prescription.wardDesc}',
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    const SizedBox(height: 5),
                    if (prescription.priorityDesc != null)
                      Text(
                        'Priority: ${prescription.priorityDesc}',
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    const Divider(),

                    ...prescription.order.map((order) => order.status !=
                            'complete'
                        ? Card(
                            color: Colors.white,
                            elevation: 4.0,
                            margin: const EdgeInsets.only(top: 13.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 15.0,
                                right: 25.0,
                                bottom: 15.0,
                                left: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Drug: ${order.drugName}',
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      CustomGap.smallHeightGap,
                                      Row(
                                        spacing: 10.0,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: ColorsTheme.primary,
                                              border: Border.all(
                                                  color: ColorsTheme.primary,
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Text(
                                              'Quantity: ${order.qty} ${order.unit}',
                                              style: const TextStyle(
                                                  fontSize: 18.0),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: ColorsTheme.primary,
                                              border: Border.all(
                                                  color: ColorsTheme.primary,
                                                  width: 2.0),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Text(
                                              'Position: ${order.position}',
                                              style: const TextStyle(
                                                  fontSize: 18.0),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),

                                  SizedBox(
                                      width: 125.0,
                                      child: order.status == 'pending'
                                          ? const Column(
                                              spacing: 15.0,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.orange,
                                                    strokeWidth: 3.0,
                                                  ),
                                                ),
                                                Text(
                                                  'กำลังจัด',
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                  ),
                                                )
                                              ],
                                            )
                                          : order.status == 'receive'
                                              ? const Column(
                                                  spacing: 15.0,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 38.0,
                                                    ),
                                                    Text(
                                                      'จัดเสร็จแล้ว',
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : order.status == 'error'
                                                  ? const Column(
                                                      spacing: 15.0,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.error,
                                                          color: Colors.red,
                                                          size: 38.0,
                                                        ),
                                                        Text(
                                                          'ผิดพลาด',
                                                          style: TextStyle(
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  : const Center(
                                                      child: Text(
                                                        'รอจัด',
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    )),
                                  // IconButton(
                                  //   onPressed: () async {
                                  //     await dioHelper.dio.get(
                                  //         '/dispense/order/status/complete/${order.id}/${order.prescriptionId}');
                                  //     rabbitMQ.acknowledgeMessage();
                                  //     await dioHelper.getOrder(context);
                                  //   },
                                  //   icon: const Icon(
                                  //     Icons.check,
                                  //     size: 32.0,
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                          )
                        : Container()),
                  ],
                ),
              );
            },
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/src/assets/images/scan.png',
                width: 480.0,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'กรุณาสแกนใบสั่งยา',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 38.0,
                  fontWeight: FontWeight.bold,
                  color: ColorsTheme.primary,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
