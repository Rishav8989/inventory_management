// inventory_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/controller/inventory_controller.dart';
import 'package:inventory_management/widgets/inventory/inventory_item_bottom_sheet.dart';
import 'package:inventory_management/widgets/inventory/inventory_tile.dart';
import 'package:intl/intl.dart';
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
  List<RecordModel> _filteredInventoryItems = [];
  bool _isLoadingItems = false;
  int _displayedItemCount = 10;
  int _loadMoreIncrement = 10;
  bool _hasMoreToLoad = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late InventoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InventoryController(
      context: context,
      onItemsFetched: (items) {
        setState(() {
          _inventoryItems = items;
          _filterInventoryItems();
        });
      },
      onError: (message) {
        setState(() {
          _errorMessage = message;
        });
      },
      onLoading: () {
        setState(() {
          _isLoadingItems = true;
          _errorMessage = '';
          _inventoryItems = [];
          _filteredInventoryItems = [];
        });
      },
      onLoadingComplete: () {
        setState(() {
          _isLoadingItems = false;
        });
      },
    );

    _controller.subscribeToInventoryChanges();
    _controller.fetchInventoryItems();
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
        return InventoryItemBottomSheet(
          item: item,
          onRefresh: _controller.fetchInventoryItems,
          onDelete: _controller.deleteInventoryItem,
          onUpdate: _controller.updateInventoryItem,
        );
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
                      onPressed: _isCreatingInventory ? null : () {
                        _controller.createInventoryItem();
                      },
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
                        return InventoryTile(
                          item: item,
                          theme: theme,
                          currencyFormat: currencyFormat,
                          onTap: () => _showItemDetailsBottomSheet(item),
                        );
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
}
