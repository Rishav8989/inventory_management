// inventory_controller.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/pages/inventory/create_inventory_item_page.dart';
import 'package:inventory_management/pages/inventory/update_inventory_item_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:async';

class InventoryController {
  final BuildContext context;
  final Function(List<RecordModel>) onItemsFetched;
  final Function(String) onError;
  final Function() onLoading;
  final Function() onLoadingComplete;

  InventoryController({
    required this.context,
    required this.onItemsFetched,
    required this.onError,
    required this.onLoading,
    required this.onLoadingComplete,
  });

  Future<void> createInventoryItem() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateInventoryItemPage()),
    ).then((value) {
      if (value == true) {
        fetchInventoryItems();
      }
    });
  }

  Future<void> fetchInventoryItems() async {
    onLoading();
    try {
      final resultList = await pb.collection('inventory').getList(
        page: 1,
        perPage: 500,
        sort: '-created',
        expand: 'user',
      );
      onItemsFetched(resultList.items);
    } catch (e) {
      onError('Failed to fetch inventory items. Please try again.');
    } finally {
      onLoadingComplete();
    }
  }

  Future<void> deleteInventoryItem(String recordId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await pb.collection('inventory').delete(recordId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory item deleted.')),
        );
        fetchInventoryItems();
      } catch (e) {
        onError('Failed to delete item.');
      }
    }
  }

  Future<void> updateInventoryItem(RecordModel item) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UpdateInventoryItemPage(item: item)),
    ).then((value) {
      if (value == true) {
        fetchInventoryItems();
      }
    });
  }

  void subscribeToInventoryChanges() {
    pb.collection('inventory').subscribe('*', (e) {
      fetchInventoryItems();
    });
  }
}
