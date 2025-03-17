// inventory_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/main.dart'; // Import pb
import 'package:inventory_management/utils/auth/auth_controller.dart';
import 'package:pocketbase/pocketbase.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCostPriceController = TextEditingController();
  bool _isCreatingInventory = false;
  String _errorMessage = '';
  bool _showForm = false;
  List<String> _inventoryItemIds = []; // List to store created inventory item IDs
  List<RecordModel> _inventoryItems = []; // List to store fetched inventory items
  bool _isLoadingItems = false;
  bool _isDeletingItem = false; // Track item deletion state
  bool _isUpdatingItem = false; // Track item update state
  RecordModel? _editingItem; // Track item being edited

  int _currentPage = 1; // Current page number for pagination
  int _perPage = 6;     // Items per page, adjust as needed
  int _totalPages = 1;    // Total pages, updated from PocketBase

  Future<void> _createInventoryItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingInventory = true;
      _errorMessage = '';
    });

    try {
      final authController = Get.find<AuthController>();
      final userId = authController.userId.value; // Get userId from controller

      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID not found. Please login again.';
          _isCreatingInventory = false;
        });
        return;
      }

      final body = <String, dynamic>{
        "item_name": _itemNameController.text.trim(),
        "item_cost_price": double.tryParse(_itemCostPriceController.text.trim()) ?? 0,
        "user": userId, // Use the logged-in user's ID
      };

      final record = await pb.collection('inventory').create(body: body); // Capture the RecordModel

      print('Inventory item created successfully!');
      print('Created Record ID: ${record.id}'); // Print the ID to console

      setState(() {
        _inventoryItemIds.add(record.id); // Add the ID to the list
        _showForm = false; // Hide the form after successful creation
        _itemNameController.clear();
        _itemCostPriceController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inventory item created with ID: ${record.id}')),
      );
      _fetchInventoryItems(); // Refresh item list after creation

    } catch (e) {
      print('Error creating inventory item: $e');
      setState(() {
        _errorMessage = 'Failed to create inventory item. Please try again.';
      });
    } finally {
      setState(() {
        _isCreatingInventory = false;
      });
    }
  }

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoadingItems = true;
      _errorMessage = '';
      _inventoryItems = []; // Clear existing items before fetching
    });

    try {
      final resultList = await pb.collection('inventory').getList(
        page: _currentPage,
        perPage: _perPage,
        sort: '-created',
      );

      setState(() {
        _inventoryItems = resultList.items; // Store fetched records
        _totalPages = resultList.totalPages;   // Update total pages for pagination
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
      _isDeletingItem = true; // Start deletion loading state
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
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),  // Yes
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
          SnackBar(content: Text('Inventory item deleted.')),
        );
        _fetchInventoryItems(); // Refresh item list after deletion
      }
    } catch (e) {
      print('Error deleting inventory item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item.')),
      );
    } finally {
      setState(() {
        _isDeletingItem = false; // End deletion loading state
      });
    }
  }

  Future<void> _updateInventoryItem(RecordModel item) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdatingItem = true;
      _errorMessage = '';
    });

    try {
      final body = <String, dynamic>{
        "item_name": _itemNameController.text.trim(),
        "item_cost_price": double.tryParse(_itemCostPriceController.text.trim()) ?? 0,
      };

      await pb.collection('inventory').update(item.id, body: body);
      print('Inventory item updated successfully! ID: ${item.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inventory item updated.')),
      );
      _fetchInventoryItems(); // Refresh item list after update
      setState(() {
        _editingItem = null; // Clear editing item, go back to grid view
      });

    } catch (e) {
      print('Error updating inventory item: $e');
      setState(() {
        _errorMessage = 'Failed to update inventory item. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update item.')),
      );
    } finally {
      setState(() {
        _isUpdatingItem = false;
      });
    }
  }


  Widget _buildEditForm(RecordModel item) {
    if (_editingItem != item) { // Reset form if editing a different item
      _itemNameController.text = item.getStringValue('item_name');
      _itemCostPriceController.text = item.getDoubleValue('item_cost_price').toString();
      _editingItem = item; // Set current editing item
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextFormField(
            controller: _itemNameController,
            decoration: const InputDecoration(labelText: 'Item Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _itemCostPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cost Price'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cost price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isUpdatingItem ? null : () => _updateInventoryItem(item),
            child: _isUpdatingItem
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('Update Item'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _editingItem = null; // Cancel editing, go back to grid view
              });
            },
            child: const Text('Cancel Edit'),
          ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _fetchInventoryItems(); // Fetch items when page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: SingleChildScrollView( // Wrap the main Column with SingleChildScrollView
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showForm = !_showForm; // Toggle form visibility
                      _errorMessage = ''; // Clear any previous error message
                      _editingItem = null; // Ensure edit form is hidden when showing create form
                    });
                  },
                  child: Text(_showForm ? 'Hide Form' : 'Create Inventory Item'),
                ),
                ElevatedButton(
                  onPressed: _isLoadingItems ? null : () {
                    setState(() {
                      _currentPage = 1; // Reset to page 1 when listing items
                    });
                    _fetchInventoryItems();
                  },
                  child: _isLoadingItems
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('List Items'),
                ),
              ],
            ),
            if (_showForm && _editingItem == null) // Show Create Form only when _showForm is true and not editing
              Obx(() => // Wrap the form in Obx to react to userId changes
                  Get.find<AuthController>().userId.value != null
                      ? Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              TextFormField(
                                controller: _itemNameController,
                                decoration: const InputDecoration(labelText: 'Item Name'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter item name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _itemCostPriceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Cost Price'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter cost price';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _isCreatingInventory ? null : _createInventoryItem,
                                child: _isCreatingInventory
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white),
                                      )
                                    : const Text('Create Item'),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),
            if (_editingItem != null) // Show Edit Form when _editingItem is set
              _buildEditForm(_editingItem!),

            const SizedBox(height: 20), // Spacing
            if (_errorMessage.isNotEmpty && !_showForm && _editingItem == null) // Error message for item listing
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_inventoryItemIds.isNotEmpty && !_showForm && _editingItem == null) // Created Item IDs list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Created Item IDs:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Disable list scrolling within column
                    itemCount: _inventoryItemIds.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: Text(_inventoryItemIds[index]),
                      );
                    },
                  ),
                ],
              ),
            if (_inventoryItems.isNotEmpty && _editingItem == null) // Fetched Inventory Items List as Grid, hide when editing
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10), // Add vertical padding around GridView
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns in the grid
                    crossAxisSpacing: 10.0, // Spacing between columns
                    mainAxisSpacing: 10.0, // Spacing between rows
                    childAspectRatio: 1.0, // Aspect ratio for square boxes (width/height = 1)
                  ),
                  itemCount: _inventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = _inventoryItems[index];
                    return Stack( // Use Stack to position buttons
                      children: [
                        Container( // Main Item Container
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400), // Grey border
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Use min to avoid taking extra space
                            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 40, color: Theme.of(context).primaryColor), // Inventory icon
                              const SizedBox(height: 8),
                              Text(
                                item.getStringValue('item_name'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2, // Limit to 2 lines
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.getDoubleValue('item_cost_price').toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              // Removed ID Text Widget here to hide the ID
                            ],
                          ),
                        ),
                        Positioned( // Buttons Row Position
                          top: 5,
                          left: 5,
                          right: 5,
                          child: Row( // Row for buttons
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between buttons
                            children: [
                              IconButton( // Delete Button
                                icon: _isDeletingItem ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Icon(Icons.delete, color: Colors.red),
                                iconSize: 20,
                                onPressed: _isDeletingItem ? null : () => _deleteInventoryItem(item.id), // Disable during deletion
                              ),
                              IconButton( // Edit Button
                                icon: _isUpdatingItem ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Icon(Icons.edit, color: Colors.blue),
                                iconSize: 20,
                                onPressed: _isUpdatingItem ? null : () {
                                  setState(() {
                                    _editingItem = item; // Set item to edit
                                    _showForm = false; // Hide create form if open
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            if (_isLoadingItems && _inventoryItems.isEmpty && _errorMessage.isEmpty && _editingItem == null) // Loading indicator for item list
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_inventoryItems.isNotEmpty && _editingItem == null) // Pagination Controls
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
                      } : null, // Disable if on first page
                    ),
                    Text('Page $_currentPage of $_totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < _totalPages ? () {
                        setState(() {
                          _currentPage++;
                        });
                        _fetchInventoryItems();
                      } : null, // Disable if on last page
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