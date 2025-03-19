import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/main.dart'; // Import pb
import 'package:inventory_management/pages/orders/order_summary_page.dart';
import 'package:inventory_management/pages/orders/stock_addition_summary_page.dart';
import 'package:pocketbase/pocketbase.dart';

class CreateOrderController extends GetxController {
  var isCreatingOrder = false.obs;
  var isAddingStock = false.obs;
  var errorMessage = ''.obs;
  var isLoadingItems = false.obs;
  var inventoryItems = <RecordModel>[].obs;
  var filteredItems = <RecordModel>[].obs;
  var cart = <String, int>{}.obs;

  final TextEditingController searchController = TextEditingController();
  String importMessage = '';

  @override
  void onInit() {
    super.onInit();
    _subscribeToInventoryChanges();
    fetchInventoryItems();
  }

  // Subscribe to Inventory Realtime Changes
  void _subscribeToInventoryChanges() {
    pb.collection('inventory').subscribe('*', (e) {
      print('Realtime inventory event: ${e.action}');
      fetchInventoryItems();
    });
  }

  // Fetch Inventory Items
  Future<void> fetchInventoryItems() async {
    isLoadingItems(true);
    errorMessage('');
    inventoryItems([]);
    filteredItems([]);

    try {
      final resultList = await pb.collection('inventory').getList(
        perPage: 500,
        sort: 'product_name',
      );

      inventoryItems.assignAll(resultList.items);
      filterItems(); // Initial filter after fetching
    } catch (e) {
      errorMessage('Failed to fetch inventory items. Please try again.');
    } finally {
      isLoadingItems(false);
    }
  }

  // Filter Items based on Search Query
  void filterItems() {
    final query = searchController.text.trim().toLowerCase();
    filteredItems.assignAll(
      inventoryItems
          .where((item) => item.getStringValue('product_name').toLowerCase().contains(query))
          .toList(),
    );
  }

  // Update Cart Quantity
  void updateCartQuantity(RecordModel item, int quantity) {
    if (quantity > 0) {
      cart[item.id] = quantity;
    } else {
      cart.remove(item.id);
    }
    print('Updated cart for ${item.getStringValue('product_name')} - Quantity: $quantity. Cart: $cart');
  }

  // Process Order and Update Inventory
  Future<void> processOrder() async {
    isCreatingOrder(true);
    errorMessage('');

    try {
      for (var itemId in cart.keys) {
        final quantity = cart[itemId]!;
        final item = inventoryItems.firstWhere((item) => item.id == itemId);

        final currentStock = item.getIntValue('stock');
        if (quantity > currentStock) {
          errorMessage('Order quantity exceeds stock for: ${item.getStringValue('product_name')}');
          return;
        }

        final newStock = currentStock - quantity;
        await pb.collection('inventory').update(item.id, body: {'stock': newStock});
        print(
            'Updated stock for ${item.getStringValue('product_name')} - Ordered: $quantity, New Stock: $newStock');
      }

      importMessage = 'Order created and inventory updated successfully!';
      cart.clear();
      Get.snackbar('Success', 'Order Created and Inventory Updated!');
      fetchInventoryItems(); // Refresh inventory after order
    } catch (e) {
      errorMessage('Failed to create order. Please try again.');
      Get.snackbar('Error', 'Failed to create order.');
    } finally {
      isCreatingOrder(false);
    }
  }

  // Add Stock to Inventory
  Future<void> processStockAddition() async {
    isAddingStock(true);
    errorMessage('');

    try {
      for (var itemId in cart.keys) {
        final quantity = cart[itemId]!;
        final item = inventoryItems.firstWhere((item) => item.id == itemId);

        final currentStock = item.getIntValue('stock');
        final newStock = currentStock + quantity;
        await pb.collection('inventory').update(item.id, body: {'stock': newStock});
        print('Added stock for ${item.getStringValue('product_name')} - Added: $quantity, New Stock: $newStock');
      }

      Get.snackbar('Success', 'Stock added successfully!');
      cart.clear();
      fetchInventoryItems(); // Refresh inventory
    } catch (e) {
      errorMessage('Failed to add stock. Please try again.');
      Get.snackbar('Error', 'Failed to add stock.');
    } finally {
      isAddingStock(false);
    }
  }

  // Show Order Summary
  // Show Order Summary
void showOrderSummary() {
  if (cart.isEmpty) {
    Get.snackbar('Error', 'Please add items to the cart to create an order.');
    return;
  }

  Get.to(() => OrderSummaryPage(
        cartItems: cart.map((itemId, quantity) {
          final item = inventoryItems.firstWhere((item) => item.id == itemId);
          return MapEntry(item, quantity);
        }),
        onConfirmOrder: processOrder,
        inventoryItems: inventoryItems,
      ));
}

// Show Stock Addition Summary
void showStockAdditionSummary() {
  if (cart.isEmpty) {
    Get.snackbar('Error', 'Please add items to the cart to add stock.');
    return;
  }

  Get.to(() => StockAdditionSummaryPage(
        cartItems: cart.map((itemId, quantity) {
          final item = inventoryItems.firstWhere((item) => item.id == itemId);
          return MapEntry(item, quantity);
        }),
        onConfirmStockAddition: processStockAddition,
        inventoryItems: inventoryItems,
      ));
}
}