// lib/pages/inventory/order_summary_page.dart
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:get/get.dart'; // Import GetX

class OrderSummaryPage extends StatefulWidget {
  final Map<RecordModel, int> cartItems;
  final Future<void> Function() onConfirmOrder;
  final List<RecordModel> inventoryItems; // Receive inventory items

  const OrderSummaryPage({
    super.key,
    required this.cartItems,
    required this.onConfirmOrder,
    required this.inventoryItems, // Receive inventory items
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  bool _orderPlaced = false; // Track if order is placed

  Future<void> _printPdf(double totalCost) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30), // Add margins around the page
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Rishav Inventory', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)), // Replace with your company name
                    pw.Text('123 Company Address, City, State, ZIP', style: const pw.TextStyle(fontSize: 12)), // Replace with your address
                    pw.Text('Email: betusenger@gmail.com', style: const pw.TextStyle(fontSize: 12)), // Replace with your email
                    pw.Text('Phone: +1 123-456-7890', style: const pw.TextStyle(fontSize: 12)), // Replace with your phone
                  ],
                ),
                // You can add a logo here if you have one (pw.Image)
                // For now, let's just add some spacing
                pw.SizedBox(width: 50),
              ],
            ),
            pw.SizedBox(height: 30),

            // Invoice Title
            pw.Center(
                child: pw.Text('ORDER INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),

            // Invoice Details (you can add invoice number, date, etc. here)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'), // Current Date
                pw.Text('Invoice No: INV-${DateTime.now().millisecondsSinceEpoch}'), // Example Invoice Number
              ],
            ),
            pw.SizedBox(height: 20),

            // Items Table
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(150), // Item Name
                1: const pw.FixedColumnWidth(50),  // Quantity
                2: const pw.FixedColumnWidth(80),  // Price
                3: const pw.FixedColumnWidth(80),  // Total
              },
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                // Table Header
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
                // Item Rows
                ...widget.cartItems.entries.map((entry) {
                  final item = entry.key;
                  final quantity = entry.value;
                  final price = item.getDoubleValue('item_sales_price');
                  final itemTotal = price * quantity;
                  return pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.getStringValue('product_name'))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$quantity', textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${price.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)), // Replaced ₹ with Rs.
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${itemTotal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)), // Replaced ₹ with Rs.
                  ]);
                }).toList(),
                // Total Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide()), // Top border for total row
                  ),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('')), // Empty cell for Item
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('')), // Empty cell for Quantity
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${totalCost.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)), // Replaced ₹ with Rs.
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Footer
            pw.Center(
              child: pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 14)),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text('https://rishavwiki.netlify.app/', style: const pw.TextStyle(fontSize: 12)), // Replace with your website
            ),
          ],
        );
      },
    ));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    double totalCost = 0;
    widget.cartItems.forEach((item, quantity) {
      totalCost += item.getDoubleValue('item_sales_price') * quantity;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Confirm your order:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems.keys.elementAt(index);
                  final quantity = widget.cartItems.values.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.getStringValue('product_name'),
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Price: ₹${item.getDoubleValue('item_sales_price').toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 1,
                          child: Text('Quantity: $quantity'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Cost: ₹${totalCost.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Go back to CreateOrderPage using GetX
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    await widget.onConfirmOrder();
                    setState(() {
                      _orderPlaced = true;
                    });
                  },
                  child: const Text('Confirm Order'),
                ),
              ],
            ),
            if (_orderPlaced)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    const Text(
                      'Order Placed Successfully!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _printPdf(totalCost);
                        },
                        child: const Text('Print PDF'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}