import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vending_standalone/src/blocs/inventory/inventory_bloc.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/models/stocks/stocks.dart';
import 'package:vending_standalone/src/screens/add_stock.dart';
import 'package:vending_standalone/src/widgets/manage_user_widget/image_file.dart';
import 'package:vending_standalone/src/widgets/md_widget/app_bar.dart';
import 'package:vending_standalone/src/widgets/utils/no_data.dart';
import 'package:vending_standalone/src/widgets/utils/search_widget.dart';

class ManageStockScreen extends StatefulWidget {
  const ManageStockScreen({super.key});

  @override
  State<ManageStockScreen> createState() => _ManageStockScreenState();
}

class _ManageStockScreenState extends State<ManageStockScreen> {
  late TextEditingController searchController;
  List<Stocks> filteredStock = [];

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
    final query = searchController.text;
    final stockList = context.read<InventoryBloc>().state.stockList;

    setState(() {
      filteredStock = stockList.where((inv) {
        final inventoryPosition = inv.inventoryPosition.toString();
        final drugName = inv.drugName.toLowerCase();
        return inventoryPosition.contains(query) ||
            drugName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'เติมยา',
        isBottom: false,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SearchWidget(
              searchController: searchController,
              onSearchChanged: _onSearchChanged,
              text: 'ค้นหายา...',
              isNumber: false,
            ),
            CustomGap.smallHeightGap,
            Expanded(
              child: BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  final stockList = filteredStock.isNotEmpty ||
                          searchController.text.isNotEmpty
                      ? filteredStock
                      : state.stockList;
                  if (stockList.isNotEmpty) {
                    return ListView.builder(
                      itemCount: stockList.length,
                      itemBuilder: (context, index) {
                        final stock = stockList[index];

                        bool isLowQty =
                            stock.inventoryQty <= stock.inventoryMin;
                        bool isOutOfStock = stock.inventoryQty == 0;

                        return Material(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddStock(
                                        titleText:
                                            '${stock.drugName} ช่องที่ ${stock.inventoryPosition}',
                                        stock: stock,
                                      ),
                                    ),
                                  );
                                },
                                splashColor:
                                    ColorsTheme.primary.withValues(alpha: 0.3),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ช่องว่างระหว่างชื่อยาและจำนวนคงเหลือ
                                    Text(
                                      stock.drugName,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    CustomGap.smallHeightGap,
                                    // แสดงจำนวนคงเหลือพร้อมสีเตือน
                                    Row(
                                      spacing: 10.0,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 8.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: isOutOfStock
                                                  ? Colors.red
                                                  : isLowQty
                                                      ? Colors.orange
                                                      : Colors
                                                          .grey, // กรอบเปลี่ยนสี
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Text(
                                            'จำนวนคงเหลือ ${stock.inventoryQty.toString()}',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: isOutOfStock
                                                  ? Colors
                                                      .red // แสดงสีแดงถ้าหมด
                                                  : isLowQty
                                                      ? Colors
                                                          .orange // แสดงสีส้มถ้าต่ำกว่า minQty
                                                      : Colors.black,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 8.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: stock.drugPriority == 1
                                                ? Colors.transparent
                                                : stock.drugPriority == 2
                                                    ? Colors.yellow
                                                    : Colors.pink,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: stock.drugPriority == 1
                                                  ? ColorsTheme.grey
                                                  : stock.drugPriority == 2
                                                      ? Colors.yellow
                                                      : Colors.pink,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            stock.drugPriority == 1
                                                ? 'ยาทั่วไป'
                                                : stock.drugPriority == 2
                                                    ? 'ยา HAD'
                                                    : 'ยา Narcotic',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: stock.drugPriority == 1
                                                  ? Colors.black
                                                  : stock.drugPriority == 2
                                                      ? Colors.black
                                                      : Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ช่องว่างระหว่างจำนวนคงเหลือและข้อมูล min/max
                                    CustomGap.smallHeightGap,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Min ${stock.inventoryMin.toString()}',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        CustomGap.smallWidthGap,
                                        Text(
                                          'Max ${stock.inventoryMAX.toString()}',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                leading: SizedBox(
                                    width: 100.0,
                                    child: Center(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            child: ImageNetwork(
                                                file: stock.drugImage),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                    alpha:
                                                        0.5), // Semi-transparent background
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                      8.0), // Match border radius
                                                  bottomRight: Radius.circular(
                                                      8.0), // Match border radius
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Text(
                                                stock.inventoryPosition
                                                    .toString(), // "Pick Image" in Thai
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                trailing: const Icon(
                                  Icons.navigate_next,
                                  size: 36.0,
                                ),
                              ),
                              Divider(
                                thickness: 1.0,
                                color: Colors.grey[300],
                                height: 7.0,
                                indent: 125.0,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const NoData(
                      icon: Icons.grid_view_sharp,
                      text: 'ไม่พบข้อมูลยา',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
