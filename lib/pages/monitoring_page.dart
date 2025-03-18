// inventory_dashboard_page.dart (Renamed for clarity - you can choose your name)
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart'; // For currency formatting

class InventoryDashboardPage extends StatefulWidget {
  const InventoryDashboardPage({super.key});

  @override
  State<InventoryDashboardPage> createState() => _InventoryDashboardPageState();
}

class _InventoryDashboardPageState extends State<InventoryDashboardPage> {
  List<RecordModel> _inventoryItems = [];
  bool _isLoadingItems = false;
  String _errorMessage = '';

  int _totalStock = 0;
  double _totalInventoryCost = 0;
  double _totalInventorySalesValue = 0;
  int _totalItemsCount = 0;

  @override
  void initState() {
    super.initState();
    _subscribeToInventoryChanges(); // Subscribe to realtime updates
    _fetchInventoryItems();       // Fetch initial data
  }

  @override
  void dispose() {
    pb.collection('inventory').unsubscribe(); // Unsubscribe when widget is disposed
    super.dispose();
  }

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoadingItems = true;
      _errorMessage = '';
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
        _calculateAggregates();
      });
      print('Fetched ${_inventoryItems.length} inventory items.');
    } catch (e) {
      print('Error fetching inventory items: $e');
      setState(() {
        _errorMessage = 'Failed to fetch inventory data. Please try again.';
      });
    } finally {
      setState(() {
        _isLoadingItems = false;
      });
    }
  }

  void _calculateAggregates() {
    _totalStock = 0;
    _totalInventoryCost = 0;
    _totalInventorySalesValue = 0;
    _totalItemsCount = _inventoryItems.length;

    for (var item in _inventoryItems) {
      int stock = item.getIntValue('stock');
      double costPrice = item.getDoubleValue('item_cost_price');
      double salesPrice = item.getDoubleValue('item_sales_price');

      _totalStock += stock;
      _totalInventoryCost += costPrice * stock;
      _totalInventorySalesValue += salesPrice * stock;
    }
  }

  void _subscribeToInventoryChanges() {
    pb.collection('inventory').subscribe('*', (e) {
      setState(() {
        _fetchInventoryItems(); // Re-fetch data on any inventory change
      });
    },);
  }


  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
      ),
      body: Center( // Center the content
        child: ConstrainedBox( // Limit max width
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align column content to start
              children: [
                Wrap( // Dashboard Tiles
                  spacing: 20.0,
                  runSpacing: 20.0,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildDashboardTile(
                      theme: theme,
                      title: 'Total Items in Stock',
                      value: _totalStock.toString(),
                      icon: Icons.inventory,
                      color: Colors.blue,
                    ),
                    _buildDashboardTile(
                      theme: theme,
                      title: 'Total Inventory Cost',
                      value: currencyFormat.format(_totalInventoryCost),
                      icon: Icons.price_change,
                      color: Colors.green,
                    ),
                    _buildDashboardTile(
                      theme: theme,
                      title: 'Total Inventory Sales Value',
                      value: currencyFormat.format(_totalInventorySalesValue),
                      icon: Icons.attach_money,
                      color: Colors.teal,
                    ),
                    _buildDashboardTile(
                      theme: theme,
                      title: 'Total Unique Items',
                      value: _totalItemsCount.toString(),
                      icon: Icons.format_list_numbered,
                      color: Colors.orange,
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
                if (_inventoryItems.isEmpty && _errorMessage.isEmpty && !_isLoadingItems)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text('No inventory items available to display dashboard.'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width > 600
          ? 300
          : MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column( // Main Column for vertical arrangement
        crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally in the column
        children: [
          Row( // Row for Icon and Title
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 10), // Spacing between icon and title
              Expanded( // Use Expanded to make the title take remaining space
                child: Text(
                  title,
                  textAlign: TextAlign.start, // Align title text to start
                  style: theme.textTheme.titleLarge,
                  maxLines: 2, // Limit title to two lines
                  overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Spacing between title row and value
          FittedBox( // Make value text resizable
            fit: BoxFit.scaleDown, // Scale down if text is too large
            child: Text(
              value,
              textAlign: TextAlign.center, // Center value text
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}