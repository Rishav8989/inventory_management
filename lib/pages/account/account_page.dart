import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/pages/account/chat_page.dart';
import 'package:inventory_management/pages/account/profile.dart';
import 'package:inventory_management/pages/account/select_language.dart';
import 'package:inventory_management/utils/translation/language_selector.dart';
import 'package:inventory_management/widgets/logout_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://rishavwiki.netlify.app/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 600.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > maxWidth;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? maxWidth : double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Get.to(() => const Profile());
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Theme.of(context).cardColor,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            'https://rishavwiki.netlify.app/assets/1707189968207-01.jpeg',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Rishav'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'view_profile'.tr,
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: isDesktop ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      _buildListTile(
                        Icons.web,
                        'website'.tr,
                        null,
                        () => _launchWebsite(),
                      ),
                      _buildListTile(
                        Icons.chat_bubble,
                        'Chat With Us'.tr,
                        const ChatPage(),
                      ),
                      _buildListTile(
                        Icons.language,
                        'Select Language'.tr,
                        const LanguageSelectionPage(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: SizedBox(
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () => LogoutService.performLogout(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Logout'.tr),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListTile _buildListTile(
    IconData icon,
    String title,
    Widget? page, [
    VoidCallback? onTap,
  ]) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Icon(icon, color: Theme.of(Get.context!).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(Get.context!).disabledColor,
      ),
      onTap: onTap ??
          () {
            if (page != null) {
              Get.to(() => page);
            }
          },
    );
  }
}
