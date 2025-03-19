// create_inventory_item_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/controller/auth_controller.dart';

class CreateInventoryItemPage extends StatefulWidget {
  const CreateInventoryItemPage({super.key});

  @override
  State<CreateInventoryItemPage> createState() => _CreateInventoryItemPageState();
}

class _CreateInventoryItemPageState extends State<CreateInventoryItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCostPriceController = TextEditingController();
  final TextEditingController _itemSalesPriceController = TextEditingController();
  final TextEditingController _eanCodeController = TextEditingController();
  final TextEditingController _aboutProductController = TextEditingController();
  final TextEditingController _productSpecificationController = TextEditingController();
  final TextEditingController _imageLinkController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  bool _isCreatingInventory = false;
  String _errorMessage = '';

  Future<void> _createInventoryItem(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingInventory = true;
      _errorMessage = '';
    });

    try {
      final authController = Get.find<AuthController>();
      final userId = authController.userId.value;

      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID not found. Please login again.';
          _isCreatingInventory = false;
        });
        return;
      }

      final body = <String, dynamic>{
        "product_name": _itemNameController.text.trim(),
        "item_cost_price": double.tryParse(_itemCostPriceController.text.trim()) ?? 0,
        "item_sales_price": double.tryParse(_itemSalesPriceController.text.trim()) ?? 0,
        "user": userId,
        "EAN_code": _eanCodeController.text.trim(),
        "about_product": _aboutProductController.text.trim(),
        "product_specification": _productSpecificationController.text.trim(),
        "image_link": _imageLinkController.text.trim(),
        "stock": int.tryParse(_stockController.text.trim()) ?? 0,
      };

      final record = await pb.collection('inventory').create(body: body);

      print('Inventory item created successfully! ID: ${record.id}');

      setState(() {
        _itemNameController.clear();
        _itemCostPriceController.clear();
        _itemSalesPriceController.clear();
        _eanCodeController.clear();
        _aboutProductController.clear();
        _productSpecificationController.clear();
        _imageLinkController.clear();
        _stockController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inventory item created with ID: ${record.id}')),
      );
      Navigator.pop(context, true); // Go back to list page and indicate success

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Inventory Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() => Get.find<AuthController>().userId.value != null
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
                      onPressed: _isCreatingInventory ? null : () => _createInventoryItem(context),
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
      ),
    );
  }
}