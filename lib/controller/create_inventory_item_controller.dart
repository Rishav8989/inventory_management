import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/controller/auth_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class CreateInventoryItemController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemCostPriceController = TextEditingController();
  final TextEditingController itemSalesPriceController = TextEditingController();
  final TextEditingController eanCodeController = TextEditingController();
  final TextEditingController aboutProductController = TextEditingController();
  final TextEditingController productSpecificationController = TextEditingController();
  final TextEditingController imageLinkController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  bool isCreatingInventory = false;
  String errorMessage = '';
  MobileScannerController cameraController = MobileScannerController();
  bool isScanningSupported = false;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    // Check if platform is Android or iOS
    isScanningSupported = (defaultTargetPlatform == TargetPlatform.android || 
                           defaultTargetPlatform == TargetPlatform.iOS);
  }

  Future<void> createInventoryItem() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isCreatingInventory = true;
    errorMessage = '';
    update();

    try {
      final authController = Get.find<AuthController>();
      final userId = authController.userId.value;

      if (userId == null) {
        errorMessage = 'User ID not found. Please login again.';
        isCreatingInventory = false;
        update();
        return;
      }

      final body = <String, dynamic>{
        "product_name": itemNameController.text.trim(),
        "item_cost_price": double.tryParse(itemCostPriceController.text.trim()) ?? 0,
        "item_sales_price": double.tryParse(itemSalesPriceController.text.trim()) ?? 0,
        "user": userId,
        "EAN_code": eanCodeController.text.trim(),
        "about_product": aboutProductController.text.trim(),
        "product_specification": productSpecificationController.text.trim(),
        "image_link": imageLinkController.text.trim(),
        "stock": int.tryParse(stockController.text.trim()) ?? 0,
      };

      final record = await pb.collection('inventory').create(body: body);

      print('Inventory item created successfully! ID: ${record.id}');

      // Clear all text fields
      itemNameController.clear();
      itemCostPriceController.clear();
      itemSalesPriceController.clear();
      eanCodeController.clear();
      aboutProductController.clear();
      productSpecificationController.clear();
      imageLinkController.clear();
      stockController.clear();
      
      Get.snackbar(
        'Success',
        'Inventory item created with ID: ${record.id}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
      Get.back(result: true);

    } catch (e) {
      print('Error creating inventory item: $e');
      errorMessage = 'Failed to create inventory item. Please try again.';
      update();
    } finally {
      isCreatingInventory = false;
      update();
    }
  }

  Future<void> scanEAN(BuildContext context) async {
    if (!isScanningSupported) {
      errorMessage = 'Barcode scanning is not supported on this platform';
      update();
      return;
    }

    isLoading = true;
    update();

    // Request camera permission
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanPage(),
        ),
      );

      if (result != null && result is String) {
        eanCodeController.text = result;
      }
    } else {
      errorMessage = 'Camera permission is required for scanning';
      isLoading = false;
      update();
    }
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController cameraController = MobileScannerController();
  String? _scannedBarcode;

  @override
  void initState() {
    super.initState();
    cameraController.start();
  }

  @override
  void dispose() {
    cameraController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan EAN Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_rear),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            setState(() {
              _scannedBarcode = barcodes.first.rawValue!;
            });
            Navigator.pop(context, _scannedBarcode);
          }
        },
      ),
    );
  }
}