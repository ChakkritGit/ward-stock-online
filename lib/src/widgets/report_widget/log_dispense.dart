import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:vending_standalone/src/widgets/md_widget/app_bar.dart';

class LogDispense extends StatelessWidget {
  const LogDispense({super.key});

  Future<Uint8List> loadPdfFromAssets() async {
    final ByteData data =
        await rootBundle.load('lib/src/assets/pdf/log_dispense.pdf');
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'รายงานการจ่ายยาย้อนหลัง',
        isBottom: false,
      ),
      body: FutureBuilder<Uint8List>(
        future: loadPdfFromAssets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return PdfPreview(
            build: (format) async => snapshot.data!,
          );
        },
      ),
    );
  }
}
