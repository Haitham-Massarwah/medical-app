import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Opens the OS print dialog (lists installed printers on Windows).
class PrintService {
  PrintService._();

  /// Generic text document — uses built-in PDF fonts (Latin / numbers; avoid RTL in body for reliability).
  static Future<void> printDocument({
    required String title,
    required List<String> lines,
    String footer = 'Medical Appointments — Demo print',
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              ...lines.map(
                (l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(l, style: const pw.TextStyle(fontSize: 11)),
                ),
              ),
              pw.Spacer(),
              pw.Text(footer, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(
      name: title.replaceAll(RegExp(r'[^\w\-]+'), '_'),
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  /// Simple payment / deposit receipt block.
  static Future<void> printDepositReceipt({
    required String receiptNo,
    required String amount,
    required String currency,
    String? notes,
    String? method,
  }) async {
    final lines = <String>[
      'Receipt No: $receiptNo',
      'Amount: $amount $currency',
      if (method != null && method.isNotEmpty) 'Method: $method',
      if (notes != null && notes.isNotEmpty) 'Notes: $notes',
      'Date: ${DateTime.now().toIso8601String()}',
    ];
    await printDocument(title: 'Payment receipt', lines: lines);
  }
}
