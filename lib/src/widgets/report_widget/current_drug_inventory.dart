import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vending_standalone/src/blocs/inventory/inventory_bloc.dart';
import 'package:vending_standalone/src/models/stocks/stocks.dart';

class CurrentDrugInventoryReport extends StatelessWidget {
  const CurrentDrugInventoryReport({super.key});

  // Future<Uint8List> loadPdfFromAssets() async {
  //   final ByteData data = await rootBundle.load(assetPath);
  //   return data.buffer.asUint8List();
  // }

  Future<Uint8List> generatePdf(List<Stocks> drugData) async {
    final pdf = pw.Document();

    final fontData =
        await rootBundle.load("lib/src/assets/fonts/Anuphan-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text("รายการยาคงเหลือ",
                  style: pw.TextStyle(
                      font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                headers: ["ตำแหน่ง", "ชื่อยา", "จำนวน", "Min", "Max"],
                data: drugData
                    .map((e) => [
                          e.inventoryPosition,
                          e.drugName,
                          e.inventoryQty,
                          e.inventoryMin,
                          e.inventoryMAX
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(
                    font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: ttf, fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final List<Stocks> drugData = context.read<InventoryBloc>().state.stockList;
    return PdfPreview(
      build: (format) async => generatePdf(drugData),
    );
  }
}



  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder<Uint8List>(
  //     future: loadPdfFromAssets(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       return PdfPreview(
  //         build: (format) async => snapshot.data!,
  //       );
  //     },
  //   );
  // }
