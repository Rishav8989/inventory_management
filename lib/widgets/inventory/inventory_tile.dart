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
          borderRadius: BorderRadius.circular(5.0),
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
        padding: const EdgeInsets.all(10.0), // Reduced padding slightly
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.getStringValue('product_name'),
              textAlign: TextAlign.left,
              style: theme.textTheme.titleMedium?.copyWith( // Reduced font size
                fontWeight: FontWeight.bold,
                fontSize: 14, // Smaller title size
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Cost: ${currencyFormat.format(item.getDoubleValue('item_cost_price'))}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14, // Smaller body text size
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
