// inventory_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart'; // Import pb
import 'package:inventory_management/pages/inventory/create_inventory_item_page.dart';
import 'package:inventory_management/pages/inventory/update_inventory_item_page.dart';
import 'package:pocketbase/pocketbase.dart';

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


  int _currentPage = 1;
  int _perPage = 6;
  int _totalPages = 1;

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
    });

    try {
      final resultList = await pb.collection('inventory').getList(
        page: _currentPage,
        perPage: _perPage,
        sort: '-created',
        expand: 'user',
      );

      setState(() {
        _inventoryItems = resultList.items;
        _totalPages = resultList.totalPages;
      });
      print('Fetched ${_inventoryItems.length} inventory items (Page $_currentPage of $_totalPages).');

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _isCreatingInventory ? null : _createInventoryItem, // Navigate to create page
                  child: _isCreatingInventory
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Create Item'),
                ),
                ElevatedButton(
                  onPressed: _isLoadingItems ? null : () {
                    setState(() {
                      _currentPage = 1;
                    });
                    _fetchInventoryItems();
                  },
                  child: _isLoadingItems
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Refresh Items'), // Changed text to Refresh
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _inventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = _inventoryItems[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 40, color: Theme.of(context).primaryColor),
                              const SizedBox(height: 8),
                              Text(
                                item.getStringValue('product_name'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.getDoubleValue('item_cost_price').toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 5,
                          left: 5,
                          right: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: _isDeletingItem ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Icon(Icons.delete, color: Colors.red),
                                iconSize: 20,
                                onPressed: _isDeletingItem ? null : () => _deleteInventoryItem(item.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                iconSize: 20,
                                onPressed: () => _updateInventoryItem(item), // Navigate to edit page
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (_isLoadingItems && _inventoryItems.isEmpty && _errorMessage.isEmpty)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_inventoryItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1 ? () {
                        setState(() {
                          _currentPage--;
                        });
                        _fetchInventoryItems();
                      } : null,
                    ),
                    Text('Page $_currentPage of $_totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < _totalPages ? () {
                        setState(() {
                          _currentPage++;
                        });
                        _fetchInventoryItems();
                      } : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}