// inventory_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/pages/inventory/create_inventory_item_page.dart';
import 'package:inventory_management/pages/inventory/update_inventory_item_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Import dart:async - Keep this

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool _isCreatingInventory = false;
  String _errorMessage = '';
  List<RecordModel> _inventoryItems = [];
  List<RecordModel> _filteredInventoryItems = [];
  bool _isLoadingItems = false;
  bool _isDeletingItem = false;
  int _displayedItemCount = 10;
  int _loadMoreIncrement = 10;
  bool _hasMoreToLoad = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // StreamSubscription? _inventorySubscription;  <-- REMOVE StreamSubscription variable

  @override
  void initState() {
    super.initState();
    _subscribeToInventoryChanges(); // Start realtime subscription
    _fetchInventoryItems(); // Initial data fetch
  }

  // @override                                      <-- REMOVE dispose method - not needed for simple subscribe
  // void dispose() {
  //   _inventorySubscription?.cancel(); // Cancel subscription on dispose
  //   super.dispose();
  // }

  void _subscribeToInventoryChanges() {
    pb.collection('inventory').subscribe('*', (e) { // <-- Call subscribe directly, no assignment
      print('Realtime inventory event: ${e.action}');
      print('Record: ${e.record?.toJson()}');
      _fetchInventoryItems(); // Re-fetch inventory on changes
    });
  }

  Future<void> _createInventoryItem() async { // <-- Ensure function is defined
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateInventoryItemPage()),
    ).then((value) {
      if (value == true) {
        _fetchInventoryItems();
      }
    });
  }

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoadingItems = true;
      _errorMessage = '';
      _inventoryItems = [];
      _filteredInventoryItems = [];
    });

    try {
      final resultList = await pb.collection('inventory').getList(
        page: 1,
        perPage: 500,
        sort: '-created',
        expand: 'user',
      );

      setState(() {
        _inventoryItems = resultList.items;
        _filterInventoryItems();
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

  void _filterInventoryItems() {
    List<RecordModel> results = [];
    if (_searchQuery.isEmpty) {
      results = _inventoryItems.take(_displayedItemCount).toList();
    } else {
      results = _inventoryItems
          .where((item) =>
              item.getStringValue('product_name').toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.getStringValue('EAN_code').toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.getStringValue('about_product').toLowerCase().contains(_searchQuery.toLowerCase()))
          .take(_displayedItemCount)
          .toList();
    }

    setState(() {
      _filteredInventoryItems = results;
      _hasMoreToLoad = _searchQuery.isEmpty ? _inventoryItems.length > _displayedItemCount : false;
    });
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
        _fetchInventoryItems(); // Re-fetch after delete (realtime will also trigger this)
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
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UpdateInventoryItemPage(item: item)),
    ).then((value) {
      if (value == true) {
        _fetchInventoryItems(); // Re-fetch after update (realtime will also trigger this)
      }
    });
  }

  void _loadMoreItems() {
    setState(() {
      _displayedItemCount += _loadMoreIncrement;
      _filterInventoryItems();
      _hasMoreToLoad = _searchQuery.isEmpty && _inventoryItems.length > _displayedItemCount;
    });
  }

  void _showItemDetailsBottomSheet(RecordModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return InventoryItemBottomSheet(item: item, onRefresh: _fetchInventoryItems, onDelete: _deleteInventoryItem, onUpdate: _updateInventoryItem);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search items...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _displayedItemCount = _loadMoreIncrement;
                      _hasMoreToLoad = false;
                      _filterInventoryItems();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                    // REFRESH BUTTON REMOVED - Already removed in previous steps
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
                if (_filteredInventoryItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 20.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _filteredInventoryItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredInventoryItems[index];
                        return _buildInventoryTile(context, theme, currencyFormat, item);
                      },
                    ),
                  ),
                if (_isLoadingItems && _inventoryItems.isEmpty && _errorMessage.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (_filteredInventoryItems.isEmpty && _errorMessage.isEmpty && !_isLoadingItems && _searchQuery.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text('No inventory items found matching your search.'),
                  ),
                if (_inventoryItems.isNotEmpty && _filteredInventoryItems.isEmpty && _errorMessage.isEmpty && _searchQuery.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text('No inventory items available.'),
                  ),
                if (_inventoryItems.isNotEmpty && _hasMoreToLoad && _searchQuery.isEmpty)
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
        ),
      ),
    );
  }

  Widget _buildInventoryTile(
      BuildContext context, ThemeData theme, NumberFormat currencyFormat, RecordModel item) {
    return GestureDetector(
      onTap: () => _showItemDetailsBottomSheet(item),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Changed to CrossAxisAlignment.start
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.getStringValue('product_name'),
              textAlign: TextAlign.left, // Align text to left
              style: theme.textTheme.titleLarge,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Cost: ${currencyFormat.format(item.getDoubleValue('item_cost_price'))}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryItemBottomSheet extends StatelessWidget {
  final RecordModel item;
  final VoidCallback onRefresh;
  final Function(String) onDelete;
  final Function(RecordModel) onUpdate;

  const InventoryItemBottomSheet({super.key, required this.item, required this.onRefresh, required this.onDelete, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 40, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.getStringValue('product_name'),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Cost Price: ${currencyFormat.format(item.getDoubleValue('item_cost_price'))}', style: theme.textTheme.bodyMedium),
            Text('Sales Price: ${currencyFormat.format(item.getDoubleValue('item_sales_price'))}', style: theme.textTheme.bodyMedium),
            Text('Stock: ${item.getIntValue('stock')}', style: theme.textTheme.bodyMedium),
            if (item.getStringValue('about_product').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('About Product:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('about_product'), style: theme.textTheme.bodyMedium),
            ],
            if (item.getStringValue('product_specification').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Product Specification:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('product_specification'), style: theme.textTheme.bodyMedium),
            ],
             if (item.getStringValue('EAN_code').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('EAN Code:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('EAN_code'), style: theme.textTheme.bodyMedium),
            ],
             if (item.getStringValue('image_link').isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Image Link:', style: theme.textTheme.titleMedium),
              Text(item.getStringValue('image_link'), style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onUpdate(item);
                  },
                  child: const Text('View/Edit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete(item.id);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}