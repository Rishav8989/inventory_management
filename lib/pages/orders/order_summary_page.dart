import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/widgets/order_pdf_generator.dart';
import 'package:pocketbase/pocketbase.dart'; // Update with your actual import path

class OrderSummaryPage extends StatelessWidget {
  final Map<RecordModel, int> cartItems;
  final VoidCallback onConfirmOrder;
  final List<RecordModel> inventoryItems;

  const OrderSummaryPage({
    Key? key,
    required this.cartItems,
    required this.onConfirmOrder,
    required this.inventoryItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Track order confirmation state
    final isOrderConfirmed = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems.keys.elementAt(index);
                  final quantity = cartItems.values.elementAt(index);
                  final currentStock = item.getIntValue('stock');
                  final newStock = currentStock - quantity;

                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.getStringValue('product_name'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Current Stock:'),
                              Text(currentStock.toString()),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Order Quantity:'),
                              Text(quantity.toString()),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('New Stock:'),
                              Text(newStock.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Column(
              children: [
                if (!isOrderConfirmed.value)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onConfirmOrder();
                          isOrderConfirmed.value = true; // Update confirmation state
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Confirm Order'),
                      ),
                    ],
                  ),
                if (isOrderConfirmed.value)
                  Column(
                    children: [
                      const Text(
                        'Order confirmed successfully!',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // Center the Generate PDF button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Calculate total cost
                            double totalCost = 0;
                            for (var entry in cartItems.entries) {
                              final item = entry.key;
                              final quantity = entry.value;
                              final price = item.getDoubleValue('item_sales_price');
                              totalCost += price * quantity;
                            }
                            
                            // Call generatePdf with both required arguments
                            generatePdf(cartItems, totalCost);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Generate PDF',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Return to Main'),
                      ),
                    ],
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}