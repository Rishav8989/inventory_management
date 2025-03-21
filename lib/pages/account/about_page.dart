import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Management App - Flutter'.tr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This Flutter application is designed to provide a robust and user-friendly inventory management solution. It leverages various modern Flutter packages and architectural patterns to deliver a seamless experience.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text(
              'Features'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildFeatureSection(context),
            const SizedBox(height: 24),

            Text(
              'Project Structure'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildProjectStructureSection(context),
            const SizedBox(height: 24),

            Text(
              'Dependencies'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildDependenciesSection(context),
            const SizedBox(height: 24),

            Text(
              'Setup and Installation'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildSetupSection(context),
            const SizedBox(height: 24),

            Text(
              'Future Enhancements'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildFutureEnhancementsSection(context),
            const SizedBox(height: 24),

            Text(
              'Contributing'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Contributions to this project are welcome! Please feel free to submit pull requests or open issues to discuss potential improvements.'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text(
              'License'.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'MIT License (If you have a license file)'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Authentication:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'Secure user login and registration'.tr,
          'Protected routes to ensure only authenticated users can access certain parts of the application'.tr,
          'Uses PocketBase as a backend for user data management'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'Theming:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'Light and Dark Mode: Supports both light and dark themes, allowing users to choose their preferred visual style'.tr,
          'Dynamic Theme Switching: Users can switch between light and dark modes within the app'.tr,
          'Persistent Theme: The selected theme is saved and automatically applied on subsequent app launches'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'Localization (Internationalization):'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'Multiple Language Support: The app can be translated into multiple languages'.tr,
          'Language Selection: Users can choose their preferred language from within the app'.tr,
          'Dynamic Language Switching: The app\'s UI updates in real-time when the language is changed'.tr,
          'Persistent Language: The selected language is saved and automatically applied on subsequent app launches'.tr,
          'Uses get package for translation'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'Notifications:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'Local Notifications: The app can send local notifications to users'.tr,
          'Permission Handling: The app requests necessary permissions for sending notifications'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'Backend Integration:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'PocketBase: Utilizes PocketBase as a backend service for data storage and user management'.tr,
          'Environment Variables: Securely manages backend URLs and other sensitive information using environment variables'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'State Management:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'GetX: Employs the GetX package for efficient state management, routing, and dependency injection'.tr,
          'Obx: Uses Obx to rebuild UI components reactively when state changes'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'Data Persistence:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'GetStorage: Uses GetStorage for persistent storage of user preferences (theme, language) and other data'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'Language Selection Page:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'The user can select the language of the app'.tr,
          'The language is saved and applied on the next app start'.tr,
        ]),
        
        const SizedBox(height: 16),
        
        Text(
          'Profile Page:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildFeatureList(context, [
          'The user can see his profile'.tr,
          'This page is under development'.tr,
        ]),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text('• '),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildProjectStructureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The project is organized into the following key directories:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        
        Text(
          'lib/main.dart:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildProjectStructureItem(context, [
            'The entry point of the application'.tr,
            'Initializes essential services like GetStorage, environment variables, theme controller, locale controller, PocketBase, and the notification service'.tr,
            'Sets up the GetMaterialApp with theme, localization, and routing configurations'.tr,
            'Starts the AuthCheck widget to determine the initial screen'.tr,
          ]),
        
        const SizedBox(height: 16),
        
        Text(
          'lib/utils/:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildProjectStructureItem(context, [
            'auth/: Contains files related to user authentication'.tr,
            'theme/: Contains files related to theming'.tr,
            'translation/: Contains files related to localization'.tr,
            'notification_service.dart: Handles notification initialization and permission requests'.tr,
          ]),
        
        const SizedBox(height: 16),
        
        Text(
          'lib/pages/:'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildProjectStructureItem(context, [
            'account/: Contains files related to user account management'.tr,
          ]),
      ],
    );
  }

  Widget _buildProjectStructureItem(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDependenciesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The project utilizes the following key dependencies:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _buildDependencyList(context, [
          'flutter: The core Flutter SDK'.tr,
          'flutter_dotenv: For loading environment variables from a .env file'.tr,
          'get: For state management, routing, and dependency injection'.tr,
          'get_storage: For persistent data storage'.tr,
          'pocketbase: For interacting with the PocketBase backend'.tr,
        ]),
      ],
    );
  }

  Widget _buildDependencyList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text('• '),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSetupSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To get started with this project, follow these steps:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _buildSetupSteps(context),
      ],
    );
  }

  Widget _buildSetupSteps(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Clone the repository:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Text(
            'git clone <repository_url>',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ),
        
        Text(
          '2. Navigate to the project directory:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Text(
            'cd inventory_management',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ),
        
        Text(
          '3. Install dependencies:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Text(
            'flutter pub get',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ),
        
        Text(
          '4. Create a .env file:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Text(
            'Create a .env file in the root of the project and add your PocketBase URL:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 4.0, bottom: 4.0),
          child: Text(
            'POCKETBASE_URL=<your_pocketbase_url>',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ),
        
        Text(
          '5. Run the app:'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Text(
            'flutter run',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFutureEnhancementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureList(context, [
          'Implement core inventory management features like adding, editing, deleting, and viewing inventory items'.tr,
          'Implement different user roles with varying permissions'.tr,
          'Add advanced search and filtering capabilities for inventory items'.tr,
          'Generate reports and analytics on inventory data'.tr,
          'Improve the user interface and user experience'.tr,
          'Add more features to the profile page'.tr,
        ]),
      ],
    );
  }
}