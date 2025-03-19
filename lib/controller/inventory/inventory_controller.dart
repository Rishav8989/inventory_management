// inventory_controller.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/pages/inventory/create_inventory_item_page.dart';
import 'package:inventory_management/pages/inventory/update_inventory_item_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:async';
import 'package:get/get.dart'; // Import GetX

class InventoryController {
  // Removed BuildContext context
  final Function(List<RecordModel>) onItemsFetched;
  final Function(String) onError;
  final Function() onLoading;
  final Function() onLoadingComplete;

  InventoryController({
    // Removed required this.context,
    required this.onItemsFetched,
    required this.onError,
    required this.onLoading,
    required this.onLoadingComplete,
  });

  Future<void> createInventoryItem() async {
    Get.to(() => const CreateInventoryItemPage())!.then((value) { // Use Get.to and handle result
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
    bool? confirmDelete = await Get.dialog<bool>( // Use Get.dialog
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(result: false), // Use Get.back
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true), // Use Get.back
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await pb.collection('inventory').delete(recordId);
        Get.snackbar( // Use Get.snackbar
          'Success',
          'Inventory item deleted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
        fetchInventoryItems();
      } catch (e) {
        onError('Failed to delete item.');
      }
    }
  }

  Future<void> updateInventoryItem(RecordModel item) async {
    Get.to(() => UpdateInventoryItemPage(item: item))!.then((value) { // Use Get.to and handle result
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