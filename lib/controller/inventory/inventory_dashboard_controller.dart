// inventory_dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart';
import 'package:pocketbase/pocketbase.dart';

class InventoryDashboardController {
  final BuildContext context;
  final Function(List<RecordModel>) onItemsFetched;
  final Function(String) onError;
  final Function() onLoading;
  final Function() onLoadingComplete;

  InventoryDashboardController({
    required this.context,
    required this.onItemsFetched,
    required this.onError,
    required this.onLoading,
    required this.onLoadingComplete,
  });

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
      onError('Failed to fetch inventory data. Please try again.');
    } finally {
      onLoadingComplete();
    }
  }

  void subscribeToInventoryChanges() {
    pb.collection('inventory').subscribe('*', (e) {
      fetchInventoryItems(); // Re-fetch data on any inventory change
    });
  }

  void calculateAggregates(List<RecordModel> inventoryItems) {
    int totalStock = 0;
    double totalInventoryCost = 0;
    double totalInventorySalesValue = 0;

    for (var item in inventoryItems) {
      int stock = item.getIntValue('stock');
      double costPrice = item.getDoubleValue('item_cost_price');
      double salesPrice = item.getDoubleValue('item_sales_price');

      totalStock += stock;
      totalInventoryCost += costPrice * stock;
      totalInventorySalesValue += salesPrice * stock;
    }

    // You can return these values or use a callback to update the UI
    // For simplicity, we can use a callback to update the UI
    // This can be modified based on your needs
    onItemsFetched(inventoryItems);
  }
}
