// update_inventory_item_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/main.dart';
import 'package:pocketbase/pocketbase.dart';

class UpdateInventoryItemPage extends StatefulWidget {
  final RecordModel item;
  const UpdateInventoryItemPage({super.key, required this.item});

  @override
  State<UpdateInventoryItemPage> createState() => _UpdateInventoryItemPageState();
}

class _UpdateInventoryItemPageState extends State<UpdateInventoryItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCostPriceController = TextEditingController();
  final TextEditingController _itemSalesPriceController = TextEditingController();
  final TextEditingController _eanCodeController = TextEditingController();
  final TextEditingController _aboutProductController = TextEditingController();
  final TextEditingController _productSpecificationController = TextEditingController();
  final TextEditingController _imageLinkController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  bool _isUpdatingItem = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadItemData();
  }

  void _loadItemData() {
    _itemNameController.text = widget.item.getStringValue('product_name');
    _itemCostPriceController.text = widget.item.getDoubleValue('item_cost_price').toString();
    _itemSalesPriceController.text = widget.item.getDoubleValue('item_sales_price').toString();
    _eanCodeController.text = widget.item.getStringValue('EAN_code');
    _aboutProductController.text = widget.item.getStringValue('about_product');
    _productSpecificationController.text = widget.item.getStringValue('product_specification');
    _imageLinkController.text = widget.item.getStringValue('image_link');
    _stockController.text = widget.item.getIntValue('stock').toString();
  }


  Future<void> _updateInventoryItem(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdatingItem = true;
      _errorMessage = '';
    });

    try {
      final body = <String, dynamic>{
        "product_name": _itemNameController.text.trim(),
        "item_cost_price": double.tryParse(_itemCostPriceController.text.trim()) ?? 0,
        "item_sales_price": double.tryParse(_itemSalesPriceController.text.trim()) ?? 0,
        "EAN_code": _eanCodeController.text.trim(),
        "about_product": _aboutProductController.text.trim(),
        "product_specification": _productSpecificationController.text.trim(),
        "image_link": _imageLinkController.text.trim(),
        "stock": int.tryParse(_stockController.text.trim()) ?? 0,
      };

      await pb.collection('inventory').update(widget.item.id, body: body);
      print('Inventory item updated successfully! ID: ${widget.item.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory item updated.')),
      );
      Navigator.pop(context, true); // Go back to list page and indicate success

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Inventory Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
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
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _itemSalesPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sales Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sales price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eanCodeController,
                decoration: const InputDecoration(labelText: 'EAN Code'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aboutProductController,
                decoration: const InputDecoration(labelText: 'About Product'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productSpecificationController,
                decoration: const InputDecoration(labelText: 'Product Specification'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageLinkController,
                decoration: const InputDecoration(labelText: 'Image Link'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isUpdatingItem ? null : () => _updateInventoryItem(context),
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
                  Navigator.pop(context); // Cancel edit, go back to list
                },
                child: const Text('Cancel Edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}