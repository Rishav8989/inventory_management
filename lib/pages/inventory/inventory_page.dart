// inventory_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/pages/inventory/create_inventory_item_page.dart';
import 'package:inventory_management/pages/inventory/inventory_list_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateInventoryItemPage()),
                ).then((value) {
                  if (value == true) {
                    // Optionally refresh the list if needed when returning from create page
                    // For now, we'll just navigate to the list page to see changes
                  }
                });
              },
              child: const Text('Create New Item'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryListPage()),
                );
              },
              child: const Text('List Inventory Items'),
            ),
          ],
        ),
      ),
    );
  }
}