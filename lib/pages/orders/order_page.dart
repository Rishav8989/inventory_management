import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/controller/create_order_controller.dart';
import 'package:inventory_management/widgets/inventory/order_item_widget.dart';

class CreateOrderPage extends StatelessWidget {
  CreateOrderPage({super.key});

  final CreateOrderController controller = Get.put(CreateOrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => SingleChildScrollView(
          clipBehavior: Clip.none, // Prevents clipping issues
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  TextField(
                    controller: controller.searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Product Name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.filterItems(),
                  ),
                  const SizedBox(height: 20),

                  // Button Row (Wrap to avoid overflow)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Wrap(
                      spacing: 20, // Space between buttons
                      runSpacing: 10, // Space if buttons wrap to next line
                      children: [
                        // Create Order Button
                        ElevatedButton(
                          onPressed: controller.cart.isEmpty ||
                                  controller.isCreatingOrder.value
                              ? null
                              : controller.showOrderSummary,
                          child: controller.isCreatingOrder.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Create Order'),
                        ),
                        // Add Stock Button
                        ElevatedButton(
                          onPressed: controller.cart.isEmpty ||
                                  controller.isAddingStock.value
                              ? null
                              : controller.showStockAdditionSummary,
                          child: controller.isAddingStock.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Add Stock'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (controller.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // List of Items
                  if (controller.filteredItems.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredItems[index];
                        return ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900.0),
                          child: OrderItemWidget(
                            item: item,
                            quantity: controller.cart[item.id] ?? 0,
                            updateCartQuantity: controller.updateCartQuantity,
                            cart: controller.cart,
                          ),
                        );
                      },
                    ),

                  // Loading Indicator
                  if (controller.isLoadingItems.value)
                    const Center(child: CircularProgressIndicator()),

                  // No Items Message
                  if (controller.filteredItems.isEmpty &&
                      !controller.isLoadingItems.value &&
                      controller.errorMessage.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No items match your search.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
