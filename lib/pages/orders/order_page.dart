// lib/pages/inventory/create_order_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart'; // Import pb
import 'package:inventory_management/pages/orders/order_summary_page.dart';
import 'package:inventory_management/widgets/inventory/order_item_widget.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:async';


class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  bool _isCreatingOrder = false;
  String _errorMessage = '';
  List<RecordModel> _inventoryItems = [];
  List<RecordModel> _filteredItems = [];
  bool _isLoadingItems = false;
  final Map<String, int> _cart = {};
  final TextEditingController _searchController = TextEditingController();
  String _importMessage = '';

  @override
  void initState() {
    super.initState();
    _subscribeToInventoryChanges();
    _fetchInventoryItems();
  }

  void _subscribeToInventoryChanges() {
    pb.collection('inventory').subscribe('*', (e) {
      print('Realtime inventory event: ${e.action}');
      print('Record: ${e.record?.toJson()}');
      _fetchInventoryItems();
    });
  }

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoadingItems = true;
      _errorMessage = '';
      _inventoryItems = [];
      _filteredItems = [];
    });

    try {
      final resultList = await pb.collection('inventory').getList(
        perPage: 500,
        sort: 'product_name',
      );

      setState(() {
        _inventoryItems = resultList.items;
        _filterItems();
      });
      print('CreateOrderPage: Fetched ${_inventoryItems.length} inventory items.');
    } catch (e) {
      print('CreateOrderPage: Error fetching inventory items: $e');
      setState(() {
        _errorMessage = 'Failed to fetch inventory items. Please try again.';
      });
    } finally {
      setState(() {
        _isLoadingItems = false;
      });
    }
  }

  void _filterItems() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredItems = _inventoryItems
          .where((item) => item.getStringValue('product_name').toLowerCase().contains(query))
          .toList();
    });
  }

  void _updateCartQuantity(RecordModel item, int quantity) {
    setState(() {
      if (quantity > 0) {
        _cart[item.id] = quantity;
      } else {
        _cart.remove(item.id);
      }
    });
    print(
        'CreateOrderPage: Updated cart for ${item.getStringValue('product_name')} - Quantity: $quantity. Cart: $_cart');
  }

  Future<void> _processOrder() async {
    setState(() {
      _isCreatingOrder = true;
      _errorMessage = '';
    });

    try {
      for (var itemId in _cart.keys) {
        final quantity = _cart[itemId]!;
        final item = _inventoryItems.firstWhere((item) => item.id == itemId);

        final currentStock = item.getIntValue('stock');
        if (quantity > currentStock) {
          setState(() {
            _errorMessage =
                'Order quantity exceeds stock for: ${item.getStringValue('product_name')}';
          });
          return;
        }

        final newStock = currentStock - quantity;
        await pb.collection('inventory').update(item.id, body: {'stock': newStock});
        print(
            'CreateOrderPage: Updated stock for ${item.getStringValue('product_name')} - Ordered: $quantity, New Stock: $newStock');
      }

      setState(() {
        _importMessage = 'Order created and inventory updated successfully!';
        _cart.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order Created and Inventory Updated!')),
      );

      _fetchInventoryItems();
    } catch (e) {
      print('CreateOrderPage: Error creating order: $e');
      setState(() {
        _errorMessage = 'Failed to create order. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create order.')),
      );
    } finally {
      setState(() {
        _isCreatingOrder = false;
      });
    }
  }

  void _showOrderSummary() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to the cart to create an order.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
          cartItems: _cart.map((itemId, quantity) {
            final item = _inventoryItems.firstWhere((item) => item.id == itemId);
            return MapEntry(item, quantity);
          }),
          onConfirmOrder: _processOrder,
          inventoryItems: _inventoryItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Product Name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _filterItems(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: _cart.isEmpty || _isCreatingOrder ? null : _showOrderSummary,
                        child: _isCreatingOrder
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            : const Text('Create Order'),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_filteredItems.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return OrderItemWidget(
                        item: item,
                        quantity: _cart[item.id] ?? 0,
                        updateCartQuantity: _updateCartQuantity,
                        cart: _cart,
                      );
                    },
                  ),
                if (_isLoadingItems && _filteredItems.isEmpty && _errorMessage.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (_filteredItems.isEmpty && !_isLoadingItems && _errorMessage.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No items match your search.",
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}