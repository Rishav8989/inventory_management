// inventory_tile.dart
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';

class InventoryTile extends StatelessWidget {
  final RecordModel item;
  final ThemeData theme;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const InventoryTile({
    super.key,
    required this.item,
    required this.theme,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Changed to CrossAxisAlignment.start
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.getStringValue('product_name'),
              textAlign: TextAlign.left, // Align text to left
              style: theme.textTheme.titleLarge,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Cost: ${currencyFormat.format(item.getDoubleValue('item_cost_price'))}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}