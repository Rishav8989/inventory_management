// inventory_dashboard_controller.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode

class InventoryDashboardController {
  final BuildContext context;
  final Function(List<RecordModel>) onItemsFetched;
  final Function(String) onError;
  final Function() onLoading;
  final Function() onLoadingComplete;

  static const String _cacheKey = 'inventoryCache';
  final _storage = GetStorage(); // GetStorage instance

  InventoryDashboardController({
    required this.context,
    required this.onItemsFetched,
    required this.onError,
    required this.onLoading,
    required this.onLoadingComplete,
  });

  Future<void> fetchInventoryItems() async {
    onLoading();
    List<RecordModel> cachedItems = await _getCachedItems();
    if (cachedItems.isNotEmpty) {
      onItemsFetched(cachedItems); // Display cached data immediately
    }

    try {
      final resultList = await pb.collection('inventory').getList(
        page: 1,
        perPage: 500,
        sort: '-created',
        expand: 'user',
      );
      _cacheItems(resultList.items); // Update cache with fresh data
      onItemsFetched(resultList.items); // Display fresh data
    } catch (e) {
      // If cache was empty and network fails, show error. If cache was present, network error might be less critical.
      if (cachedItems.isEmpty) {
        onError('Failed to fetch inventory data. Please try again.');
      } else {
        onError('Failed to refresh inventory data. Displaying cached data.');
        // Still display cached data even if refresh fails, user has some data to see.
      }
    } finally {
      onLoadingComplete();
    }
  }

  Future<List<RecordModel>> _getCachedItems() async {
    final cachedDataJson = _storage.read(_cacheKey);

    if (cachedDataJson != null && cachedDataJson is String) {
      try {
        final List<dynamic> cachedData = jsonDecode(cachedDataJson);
        return cachedData.map((itemJson) => RecordModel.fromJson(itemJson as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Error parsing cached data: $e'); // Log error, but return empty list
        return [];
      }
    }
    return [];
  }

  Future<void> _cacheItems(List<RecordModel> items) async {
    try {
      final List<Map<String, dynamic>> itemsJson = items.map((item) => item.toJson()).toList();
      final String encodedJson = jsonEncode(itemsJson); // Encode list to JSON string
      await _storage.write(_cacheKey, encodedJson); // Store JSON string in GetStorage
    } catch (e) {
      print('Error caching data: $e'); // Log error, caching is best effort
    }
  }

  void subscribeToInventoryChanges() {
    pb.collection('inventory').subscribe('*', (e) {
      fetchInventoryItems(); // Re-fetch data on any inventory change, which will update cache and UI
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
    onItemsFetched(inventoryItems); // Still using onItemsFetched as it seems to be the UI update trigger
  }
}