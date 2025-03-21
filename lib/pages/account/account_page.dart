import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/pages/account/about_page.dart';
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
            padding: const EdgeInsets.all(24.0), // Increased padding
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Get.to(() => const Profile());
                  },
                  child: Container(
                    height: 140, // Increased height for better spacing
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0), // Larger radius
                      color: Theme.of(context).cardColor,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 15.0), // Increased margin
                    padding: const EdgeInsets.all(20.0), // Increased padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 45, // Larger avatar
                          backgroundImage: NetworkImage(
                            'https://rishavwiki.netlify.app/assets/1707189968207-01.jpeg',
                          ),
                        ),
                        const SizedBox(width: 25), // Increased spacing
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Rishav'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24, // Larger font size
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 10), // Increased spacing
                            Text(
                              'view_profile'.tr,
                              style: TextStyle(
                                fontSize: 16, // Larger font size
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15), // Increased spacing

                Card(
                  elevation: isDesktop ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Larger radius
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
                      ),_buildListTile(
                        Icons.account_box_outlined,
                        'About This Project'.tr,
                        const AboutPage(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25), // Increased spacing

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0), // Increased padding
                  child: FractionallySizedBox(
                    widthFactor: 0.6, // Wider button
                    child: SizedBox(
                      height: 55.0, // Taller button
                      child: ElevatedButton(
                        onPressed: () => LogoutService.performLogout(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 18), // Larger text
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
      dense: false, // Removed dense for larger size
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0, // Increased padding
        vertical: 12.0, // Increased padding
      ),
      leading: Icon(icon, 
        color: Theme.of(Get.context!).iconTheme.color,
        size: 28, // Larger icon
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18, // Larger font size
          color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(Get.context!).disabledColor,
        size: 28, // Larger icon
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