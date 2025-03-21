import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/controller/create_inventory_item_controller.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/controller/auth_controller.dart';
import 'package:flutter/foundation.dart';

class CreateInventoryItemPage extends StatefulWidget {
  const CreateInventoryItemPage({super.key});

  @override
  State<CreateInventoryItemPage> createState() => _CreateInventoryItemPageState();
}

class _CreateInventoryItemPageState extends State<CreateInventoryItemPage> {
  late final CreateInventoryItemController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateInventoryItemController());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Inventory Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Obx(() {
            if (!controller.isScanningSupported) {
              return Column(
                children: [
                  Text(
                    'Barcode scanning is not supported on this platform',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }

            if (controller.isLoading) {
              return const CircularProgressIndicator();
            }

            return Get.find<AuthController>().userId.value != null
                ? Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow,
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (controller.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                controller.errorMessage,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                          TextFormField(
                            controller: controller.itemNameController,
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                              labelStyle: theme.textTheme.bodyMedium,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter product name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.itemCostPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Cost Price',
                              labelStyle: theme.textTheme.bodyMedium,
                            ),
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
                            controller: controller.itemSalesPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Sales Price',
                              labelStyle: theme.textTheme.bodyMedium,
                            ),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.eanCodeController,
                                  decoration: InputDecoration(
                                    labelText: 'EAN Code',
                                    labelStyle: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: () {
                                  controller.scanEAN(context);
                                },
                                tooltip: 'Scan EAN',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.aboutProductController,
                            decoration: InputDecoration(
                              labelText: 'About Product',
                              labelStyle: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.productSpecificationController,
                            decoration: InputDecoration(
                              labelText: 'Product Specification',
                              labelStyle: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.imageLinkController,
                            decoration: InputDecoration(
                              labelText: 'Image Link',
                              labelStyle: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stock',
                              labelStyle: theme.textTheme.bodyMedium,
                            ),
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
                            onPressed: controller.isCreatingInventory ? null : controller.createInventoryItem,
                            child: controller.isCreatingInventory
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white),
                                  )
                                : const Text('Create Item'),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ),
      ),
    );
  }
}