// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vending_standalone/src/api/dio_helper.dart';
// import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/blocs/order/order_bloc.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/style.dart';
// import 'package:vending_standalone/src/models/order/order_model.dart';
import 'package:vending_standalone/src/services/RabbitMQ.dart';

class PrescriptionOrderCardWidget extends StatelessWidget {
  final RabbitMQService rabbitMQ;
  const PrescriptionOrderCardWidget({super.key, required this.rabbitMQ});

  @override
  Widget build(BuildContext context) {
    // final dioHelper = DioHelper();

    // void showPrescriptionModal(
    //     BuildContext context, Prescription prescription) {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         backgroundColor: Colors.white,
    //         shape:
    //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //         title: Text('รายการยา (HN: ${prescription.hn})'),
    //         content: SizedBox(
    //           width: double.maxFinite,
    //           child: ListView.builder(
    //             shrinkWrap: true,
    //             itemCount: prescription.order.length,
    //             itemBuilder: (context, index) {
    //               final order = prescription.order[index];
    //               return ListTile(
    //                 leading: CircleAvatar(
    //                   backgroundColor: Colors.blue.shade100,
    //                   child: Text('${index + 1}'),
    //                 ),
    //                 title: Text(order.drugName),
    //                 subtitle: Text('จำนวน: ${order.qty} ${order.unit}'),
    //                 trailing: Icon(
    //                   order.status == 'complete'
    //                       ? Icons.check_circle
    //                       : Icons.pending,
    //                   color: order.status == 'complete'
    //                       ? Colors.green
    //                       : Colors.orange,
    //                 ),
    //               );
    //             },
    //           ),
    //         ),
    //         actions: [
    //           TextButton(
    //             child: const Text(
    //               'ปิด',
    //               style: TextStyle(
    //                 fontSize: 24.0,
    //               ),
    //             ),
    //             onPressed: () => Navigator.of(context).pop(),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }

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
                                          Text(
                                            'Quantity: ${order.qty} ${order.unit}',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              color: ColorsTheme.primary,
                                            ),
                                          ),
                                          const Text(
                                            '|',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: ColorsTheme.primary,
                                            ),
                                          ),
                                          Text(
                                            'Position: ${order.position}',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              color: ColorsTheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomGap.smallHeightGap,
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 8.0),
                                        decoration: BoxDecoration(
                                          color: order.drugPriority == 1
                                              ? Colors.white
                                              : order.drugPriority == 2
                                                  ? Colors.yellow
                                                  : Colors.pink,
                                          border: Border.all(
                                              color: order.drugPriority == 1
                                                  ? ColorsTheme.grey
                                                  : order.drugPriority == 2
                                                      ? Colors.yellow
                                                      : Colors.pink,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          order.drugPriority == 1
                                              ? 'Normal'
                                              : order.drugPriority == 2
                                                  ? 'HAD'
                                                  : 'Narcotic',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: order.drugPriority == 1
                                                  ? Colors.black
                                                  : order.drugPriority == 2
                                                      ? Colors.black
                                                      : Colors.white),
                                        ),
                                      ),
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
                                  //     final response = await dioHelper.dio.get(
                                  //         '/dispense/order/status/complete/${order.id}/${order.prescriptionId}');
                                  //     rabbitMQ.acknowledgeMessage();
                                  //     await dioHelper.fetchOrder(context);

                                  //     if (response.data['data'] != null) {
                                  //       final prescription =
                                  //           Prescription.fromJson(
                                  //               response.data['data']);

                                  //       showPrescriptionModal(
                                  //           context, prescription);
                                  //     }
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
