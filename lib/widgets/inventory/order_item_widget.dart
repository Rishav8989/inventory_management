import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class OrderItemWidget extends StatelessWidget {
  final RecordModel item;
  final int quantity;
  final Function(RecordModel, int) updateCartQuantity;
  final Map<String, int> cart;

  const OrderItemWidget({
    super.key,
    required this.item,
    required this.quantity,
    required this.updateCartQuantity,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900.0), // Prevents overflow
        child: Row(
          children: [
            // Product Details Column
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.getStringValue('product_name'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                    maxLines: 1,
                  ),
                  Text(
                    'Price: ₹${item.getDoubleValue('item_sales_price').toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Stock: ${item.getIntValue('stock')}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            
            // Spacing between text and buttons
            const SizedBox(width: 10),

            // Quantity and Buttons Row
            Expanded(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min, // Prevents excess width
                mainAxisAlignment: MainAxisAlignment.end, // Aligns to right
                children: [
                  // Decrease Quantity Button
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final currentQuantity = cart[item.id] ?? 0;
                      if (currentQuantity > 0) {
                        updateCartQuantity(item, currentQuantity - 1);
                      }
                    },
                  ),

                  // Quantity Display
                  SizedBox(
                    width: 20,
                    child: Center(
                      child: Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Increase Quantity Button
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final currentQuantity = cart[item.id] ?? 0;
                      updateCartQuantity(item, currentQuantity + 1);
                    },
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
