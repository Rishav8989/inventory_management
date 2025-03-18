import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart'; // Import pb
import 'package:inventory_management/pages/inventory/create_inventory_item_page.dart';
import 'package:inventory_management/pages/inventory/update_inventory_item_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart'; // Import intl for number formatting

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool _isCreatingInventory = false;
  String _errorMessage = '';
  List<RecordModel> _inventoryItems = [];
  bool _isLoadingItems = false;
  bool _isDeletingItem = false;
  int _displayedItemCount = 10; // Initial number of items to display
  int _loadMoreIncrement = 10; // Number of items to load on "Load More"
  bool _hasMoreToLoad = false;

  @override
  void initState() {
    super.initState();
    _fetchInventoryItems(); // Fetch items on page load
  }

  Future<void> _createInventoryItem() async {
    // Navigate to CreateInventoryItemPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateInventoryItemPage()),
    ).then((value) {
      if (value == true) {
        _fetchInventoryItems(); // Refresh list after successful creation
      }
    });
  }

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoadingItems = true;
      _errorMessage = '';
      _inventoryItems = [];
      _hasMoreToLoad = false; // Reset on refresh
      _displayedItemCount = _loadMoreIncrement; // Reset display count
    });

    try {
      final resultList = await pb.collection('inventory').getList(
        page: 1, // Fetch all items in one go for "Load More" functionality
        perPage: 500,
        sort: '-created',
        expand: 'user',
      );

      setState(() {
        _inventoryItems = resultList.items;
        _hasMoreToLoad = _inventoryItems.length > _displayedItemCount;
      });
      print('Fetched ${_inventoryItems.length} inventory items.');
    } catch (e) {
      print('Error fetching inventory items: $e');
      setState(() {
        _errorMessage = 'Failed to fetch inventory items. Please try again.';
      });
    } finally {
      setState(() {
        _isLoadingItems = false;
      });
    }
  }

  Future<void> _deleteInventoryItem(String recordId) async {
    setState(() {
      _isDeletingItem = true;
    });

    try {
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
        await pb.collection('inventory').delete(recordId);
        print('Inventory item deleted successfully! ID: $recordId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory item deleted.')),
        );
        _fetchInventoryItems();
      }
    } catch (e) {
      print('Error deleting inventory item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item.')),
      );
    } finally {
      setState(() {
        _isDeletingItem = false;
      });
    }
  }

  Future<void> _updateInventoryItem(RecordModel item) async {
    // Navigate to UpdateInventoryItemPage
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UpdateInventoryItemPage(item: item)),
    ).then((value) {
      if (value == true) {
        _fetchInventoryItems(); // Refresh list after successful update
      }
    });
  }

  void _loadMoreItems() {
    setState(() {
      _displayedItemCount += _loadMoreIncrement;
      if (_displayedItemCount >= _inventoryItems.length) {
        _displayedItemCount = _inventoryItems.length;
        _hasMoreToLoad = false;
      } else {
        _hasMoreToLoad = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed:
                      _isCreatingInventory ? null : _createInventoryItem,
                  child: _isCreatingInventory
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Create Item'),
                ),
                ElevatedButton(
                  onPressed: _isLoadingItems
                      ? null
                      : () {
                          _fetchInventoryItems();
                        },
                  child: _isLoadingItems
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Refresh Items'),
                ),
              ],
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
            if (_inventoryItems.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: <DataColumn>[
                    const DataColumn(label: Text('Product Name')),
                    DataColumn(
                        label: Text('Cost Price (${currencyFormat.currencySymbol})')),
                    DataColumn(
                        label: Text('Sales Price (${currencyFormat.currencySymbol})')),
                    const DataColumn(label: Text('Stock Info')),
                    const DataColumn(label: Text('Actions')), // Changed heading to Actions
                  ],
                  rows: _inventoryItems.take(_displayedItemCount).map((item) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(item.getStringValue('product_name'))),
                        DataCell(Text(currencyFormat.format(
                            item.getDoubleValue('item_cost_price')))),
                        DataCell(Text(currencyFormat.format(
                            item.getDoubleValue('item_sales_price')))),
                        DataCell(Text('${item.getIntValue('stock')}')),
                        DataCell(
                          Row( // Use Row to place buttons side by side
                            mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () {
                                  _updateInventoryItem(item);
                                },
                              ),
                              IconButton(
                                icon: _isDeletingItem
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator())
                                    : const Icon(Icons.delete, color: Colors.red),
                                onPressed: _isDeletingItem
                                    ? null
                                    : () => _deleteInventoryItem(item.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            if (_isLoadingItems && _inventoryItems.isEmpty && _errorMessage.isEmpty)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_inventoryItems.isNotEmpty && _hasMoreToLoad)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _isLoadingItems ? null : _loadMoreItems,
                  child: _isLoadingItems
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Load More'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}