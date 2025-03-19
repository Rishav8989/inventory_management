// inventory_item_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';

class InventoryItemBottomSheet extends StatelessWidget {
  final RecordModel item;
  final VoidCallback onRefresh;
  final Function(String) onDelete;
  final Function(RecordModel) onUpdate;

  const InventoryItemBottomSheet({super.key, required this.item, required this.onRefresh, required this.onDelete, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 40, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.getStringValue('product_name'),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Cost Price: ${currencyFormat.format(item.getDoubleValue('item_cost_price'))}', style: theme.textTheme.bodyMedium),
            Text('Sales Price: ${currencyFormat.format(item.getDoubleValue('item_sales_price'))}', style: theme.textTheme.bodyMedium),
            Text('Stock: ${item.getIntValue('stock')}', style: theme.textTheme.bodyMedium),
            if (item.getStringValue('about_product').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('About Product:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('about_product'), style: theme.textTheme.bodyMedium),
            ],
            if (item.getStringValue('product_specification').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Product Specification:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('product_specification'), style: theme.textTheme.bodyMedium),
            ],
             if (item.getStringValue('EAN_code').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('EAN Code:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('EAN_code'), style: theme.textTheme.bodyMedium),
            ],
             if (item.getStringValue('image_link').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Image Link:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('image_link'), style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onUpdate(item);
                  },
                  child: const Text('View/Edit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete(item.id);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}