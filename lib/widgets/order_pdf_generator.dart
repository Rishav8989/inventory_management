import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> generatePdf(Map<RecordModel, int> cartItems, double totalCost) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(30),
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Rishav Inventory', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('123 Company Address, City, State, ZIP', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Email: betusenger@gmail.com', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Phone: +1 123-456-7890', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(width: 50),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text('ORDER INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
              pw.Text('Invoice No: INV-${DateTime.now().millisecondsSinceEpoch}'),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(150),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FixedColumnWidth(80),
              3: const pw.FixedColumnWidth(80),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                ],
              ),
              ...cartItems.entries.map((entry) {
                final item = entry.key;
                final quantity = entry.value;
                final price = item.getDoubleValue('item_sales_price');
                final itemTotal = price * quantity;
                return pw.TableRow(children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.getStringValue('product_name'))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$quantity', textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${price.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${itemTotal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                ]);
              }),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide()),
                ),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${totalCost.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 14)),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text('https://rishavwiki.netlify.app/', style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      );
    },
  ));

  // Request storage permission
  if (await Permission.storage.request().isGranted) {
    final output = await getExternalStorageDirectory();
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final filePath = '${downloadsDir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF saved to: $filePath');
  } else {
    print('Storage permission denied');
  }

  // Optionally print or share the PDF
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
