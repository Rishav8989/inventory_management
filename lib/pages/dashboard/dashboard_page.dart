// inventory_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/controller/inventory/inventory_dashboard_controller.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:inventory_management/main.dart';
import 'package:pocketbase/pocketbase.dart';

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

  late InventoryDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InventoryDashboardController(
      context: context,
      onItemsFetched: (items) {
        setState(() {
          _inventoryItems = items;
          _calculateAggregates();
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

  @override
  void dispose() {
    pb.collection('inventory').unsubscribe(); // Unsubscribe when widget is disposed
    super.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
