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
      
      Get.snackbar(
        'Success',
        'Inventory item created with ID: ${record.id}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );

      // Navigate back to the previous page after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.back(result: true);
      });

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
    // Create a text theme with increased font sizes
    final TextTheme textTheme = Theme.of(context).textTheme.copyWith(
      titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
      bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
      labelMedium: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 16),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Inventory Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            // Set max width to 600
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
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
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            ),
                          TextFormField(
                            controller: _itemNameController,
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
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
                            decoration: InputDecoration(
                              labelText: 'Cost Price',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
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
                            decoration: InputDecoration(
                              labelText: 'Sales Price',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
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
                            decoration: InputDecoration(
                              labelText: 'EAN Code',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _aboutProductController,
                            decoration: InputDecoration(
                              labelText: 'About Product',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _productSpecificationController,
                            decoration: InputDecoration(
                              labelText: 'Product Specification',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _imageLinkController,
                            decoration: InputDecoration(
                              labelText: 'Image Link',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stock',
                              labelStyle: textTheme.labelMedium,
                            ),
                            style: textTheme.bodyMedium,
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
                            onPressed: _isCreatingInventory ? null : _createInventoryItem,
                            child: _isCreatingInventory
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white),
                                  )
                                : Text(
                                    'Create Item',
                                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ),
          ),
        ),
      ),
    );
  }
}