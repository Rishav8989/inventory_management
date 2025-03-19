// lib/widgets/order_item_widget.dart
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
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.getStringValue('product_name'), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Price: ₹${item.getDoubleValue('item_sales_price').toStringAsFixed(2)}'),
                Text('Stock: ${item.getIntValue('stock')}'),
              ],
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final currentQuantity = cart[item.id] ?? 0;
                    updateCartQuantity(item, currentQuantity - 1);
                  },
                ),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Text('$quantity'),
                  ),
                ),
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
    );
  }
}