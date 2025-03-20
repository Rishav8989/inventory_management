import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/utils/translation/language_selector.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ElevatedButton(
        onPressed: () {
          Get.to(() => const LanguageSelectionPage());
        },
        child: Row(
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 8),
            Text('Select Language'.tr),
          ],
        ),
      ),
    );
  }
}