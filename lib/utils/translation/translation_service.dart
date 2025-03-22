import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/pages/account/about_page.dart';
import 'package:inventory_management/pages/account/chat_page.dart';
import 'package:inventory_management/pages/account/profile.dart';
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
                    Get.to(() => const ProfilePage());
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

class TranslationService extends Translations {
  static const fallbackLocale = Locale('en', 'US'); // Default locale if translation not found
  static const supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('bn', 'IN'), // Bengali
    Locale('te', 'IN'), // Telugu
    Locale('mr', 'IN'), // Marathi
    Locale('ta', 'IN'), // Tamil
  ];

  @override
  Map<String, Map<String, String>> get keys => translations;
}

final Map<String, Map<String, String>> translations = {
  'en': {
    'view_profile': 'View Profile',
    'account_security': 'Account and Security',
    'general': 'General',
    'service_provider': 'My Service Provider',
    'website': 'Website',
    'notifications': 'Notifications',
    'reports': 'Reports',
    'app_sharing': 'Application Sharing',
    'declaration': 'Declaration',
    'about': 'About',
    'monitoring': 'Monitoring',
    'faults': 'Faults',
    'support': 'Support',
    'account': 'Account',
    'Chat With Us': 'Chat With Us',
    'Select Language': 'Select Language',
    'About This Project': 'About This Project',
    'Logout': 'Logout',
    'Could not launch': 'Could not launch',
  },
  'hi': {
    'view_profile': 'प्रोफ़ाइल देखें',
    'account_security': 'खाता और सुरक्षा',
    'general': 'सामान्य',
    'service_provider': 'मेरे सेवा प्रदाता',
    'website': 'वेबसाइट',
    'notifications': 'सूचनाएँ',
    'reports': 'रिपोर्ट्स',
    'app_sharing': 'एप्लिकेशन साझाकरण',
    'declaration': 'घोषणा',
    'about': 'बारे में',
    'monitoring': 'निगरानी',
    'faults': 'दोष',
    'support': 'समर्थन',
    'account': 'खाता',
    'Chat With Us': 'हमसे चैट करें',
    'Select Language': 'भाषा का चयन करें',
    'About This Project': 'इस परियोजना के बारे में',
    'Logout': 'लॉग आउट',
    'Could not launch': 'लॉन्च नहीं हो सका',
  },
  'bn': {
    'view_profile': 'প্রোফাইল দেখুন',
    'account_security': 'অ্যাকাউন্ট ও নিরাপত্তা',
    'general': 'সাধারণ',
    'service_provider': 'আমার পরিষেবা প্রদানকারী',
    'website': 'ওয়েবসাইট',
    'notifications': 'বিজ্ঞপ্তি',
    'reports': 'রিপোর্ট',
    'app_sharing': 'অ্যাপ শেয়ারিং',
    'declaration': 'ঘোষণা',
    'about': 'পরিচিতি',
    'monitoring': 'পর্যবেক্ষণ',
    'faults': 'ত্রুটি',
    'support': 'সহায়তা',
    'account': 'অ্যাকাউন্ট',
    'Chat With Us': 'আমাদের সাথে চ্যাট করুন',
    'Select Language': 'ভাষা নির্বাচন করুন',
    'About This Project': 'এই প্রকল্প সম্পর্কে',
    'Logout': 'লগ আউট',
    'Could not launch': 'লঞ্চ করা যায়নি',
  },
  'te': {
    'view_profile': 'ప్రొఫైల్ చూడండి',
    'account_security': 'ఖాతా మరియు భద్రత',
    'general': 'సాధారణ',
    'service_provider': 'నా సేవా ప్రదాత',
    'website': 'వెబ్‌సైట్',
    'notifications': 'నోటిఫికేషన్‌లు',
    'reports': 'నివేదికలు',
    'app_sharing': 'యాప్ పంచుకోడం',
    'declaration': 'ప్రకటన',
    'about': 'గురించి',
    'monitoring': 'నిఘా',
    'faults': 'లోపాలు',
    'support': 'మద్దతు',
    'account': 'ఖాతా',
    'Chat With Us': 'మాతో చాట్ చేయండి',
    'Select Language': 'భాషను ఎంచుకోండి',
    'About This Project': 'ఈ ప్రాజెక్ట్ గురించి',
    'Logout': 'నిష్క్రమించు',
    'Could not launch': 'ప్రారంభించలేకపోయింది',
  },
  'mr': {
    'view_profile': 'प्रोफाइल पहा',
    'account_security': 'खाते आणि सुरक्षा',
    'general': 'सामान्य',
    'service_provider': 'माझा सेवा प्रदाता',
    'website': 'वेबसाइट',
    'notifications': 'सूचना',
    'reports': 'अहवाल',
    'app_sharing': 'अॅप शेअरिंग',
    'declaration': 'घोषणा',
    'about': 'विषयी',
    'monitoring': 'निरीक्षण',
    'faults': 'दोष',
    'support': 'आधार',
    'account': 'खाते',
    'Chat With Us': 'आमच्याशी चॅट करा',
    'Select Language': 'भाषा निवडा',
    'About This Project': 'या प्रकल्पाबद्दल',
    'Logout': 'लॉग आउट',
    'Could not launch': 'लॉंच होऊ शकले नाही',
  },
  'ta': {
    'view_profile': 'சுயவிவரத்தை பார்க்கவும்',
    'account_security': 'கணக்கு மற்றும் பாதுகாப்பு',
    'general': 'பொது',
    'service_provider': 'என் சேவை வழங்குபவர்',
    'website': 'இணையதளம்',
    'notifications': 'அறிவிப்புகள்',
    'reports': 'அறிக்கைகள்',
    'app_sharing': 'பயன்பாடு பகிர்வு',
    'declaration': 'அறிக்கை',
    'about': 'பற்றி',
    'monitoring': 'கண்காணிப்பு',
    'faults': 'குறைபாடுகள்',
    'support': 'ஆதரவு',
    'account': 'கணக்கு',
    'Chat With Us': 'எங்களுடன் உரையாடுங்கள்',
    'Select Language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
    'About This Project': 'இந்த திட்டம் பற்றி',
    'Logout': 'வெளியேறு',
    'Could not launch': 'துவங்க முடியவில்லை',
  }
};