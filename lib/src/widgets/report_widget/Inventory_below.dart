// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:vending_standalone/src/api/dio_helper.dart';
import 'package:vending_standalone/src/constants/initail_store.dart';
import 'package:vending_standalone/src/models/stocks/stocks.dart';
import 'package:vending_standalone/src/widgets/md_widget/app_bar.dart';
import 'package:pdf/widgets.dart' as pw;

class InventoryBelow extends StatefulWidget {
  const InventoryBelow({super.key});

  @override
  InventoryBelowState createState() => InventoryBelowState();
}

class InventoryBelowState extends State<InventoryBelow> {
  List<Stocks> drugData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDrugBelow();
  }

  Future<void> fetchDrugBelow() async {
    try {
      final response =
          await DioHelper.instance.dio.get('/reports/below-min-max');
      if (response.data['data'].isNotEmpty) {
        List<Stocks> machineList = (response.data['data'] as List)
            .map((map) => Stocks.fromMap(map as Map<String, dynamic>))
            .toList();

        setState(() {
          drugData = machineList;
          isLoading = true;
        });
      } else {
        setState(() {
          drugData = [];
          isLoading = false;
        });
      }
    } catch (error) {
      if (error is DioException) {
        if (error.response != null) {
          if (error.response?.statusCode == 401) {
            await StoredLocal.instance.handleUnauthorized(context);
            return;
          }
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
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Uint8List> generatePdf(List<Stocks> drugData) async {
    final pdf = pw.Document();

    final fontData =
        await rootBundle.load("lib/src/assets/fonts/Anuphan-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final fontDataBold =
        await rootBundle.load("lib/src/assets/fonts/Anuphan-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontDataBold);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        margin: const pw.EdgeInsets.all(30.0),
        header: (context) => pw.Center(
          child: pw.Text(
            "รายงานยาที่ต้องเติม",
            style: pw.TextStyle(
              font: ttf,
              fontSize: 24,
            ),
          ),
        ),
        build: (pw.Context context) => [
          pw.Column(
            children: [
              pw.SizedBox(height: 10),
              // ignore: deprecated_member_use
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey700),
                    children: [
                      buildHeaderCell('ตำแหน่ง', ttfBold),
                      buildHeaderCell('ชื่อยา', ttfBold),
                      buildHeaderCell('จำนวน', ttfBold),
                      buildHeaderCell('Min', ttfBold),
                      buildHeaderCell('Max', ttfBold),
                    ],
                  ),
                  ...drugData.map((e) {
                    return pw.TableRow(
                      children: [
                        buildCell(e.inventoryPosition.toString(),
                            pw.Alignment.center, ttf),
                        buildCell(e.drugName, pw.Alignment.centerLeft, ttf),
                        buildCell(e.inventoryQty.toString(),
                            pw.Alignment.center, ttf),
                        buildCell(e.inventoryMin.toString(),
                            pw.Alignment.center, ttf),
                        buildCell(e.inventoryMAX.toString(),
                            pw.Alignment.center, ttf),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text(
                    '*หมายเหตุ',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red500,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    'สามารถเพิ่มเติมรายละเอียดได้',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Ward Stock - Report Example',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget buildCell(String text, pw.Alignment alignment, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: ttf, fontSize: 14),
        textAlign: alignment == pw.Alignment.center
            ? pw.TextAlign.center
            : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget buildHeaderCell(String text, pw.Font ttfBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttfBold,
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'รายงานยาที่ต้องเติม',
        isBottom: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              build: (format) async => generatePdf(drugData),
            ),
    );
  }
}
