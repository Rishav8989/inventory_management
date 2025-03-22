# Inventory Management App - Flutter
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![PocketBase](https://img.shields.io/badge/PocketBase-333333?style=for-the-badge&logo=pocketbase&logoColor=white)](https://pocketbase.io/)

**Connect with me:** [My Website](https://rishavwiki.netlify.app/)

This Flutter application is designed to provide a robust and user-friendly inventory management solution. It leverages various modern Flutter packages and architectural patterns to deliver a seamless experience.

## Demo Video

Here's a quick demonstration of the app's current features:

<video src="assets/screen-20250322-054823.mp4" controls="controls">
  Your browser does not support the video tag.
</video>

![video](assets/screen-20250322-054823.mp4)

## Features

This application boasts a rich set of features, including:

1.  **User Authentication:**
    *   Secure user login and registration.
    *   Protected routes to ensure only authenticated users can access certain parts of the application.
    *   Uses PocketBase as a backend for user data management.

2.  **Theming:**
    *   **Light and Dark Mode:** Supports both light and dark themes, allowing users to choose their preferred visual style.
    *   **Dynamic Theme Switching:** Users can switch between light and dark modes within the app.
    *   **Persistent Theme:** The selected theme is saved and automatically applied on subsequent app launches.

3.  **Localization (Internationalization):**
    *   **Multiple Language Support:** The app can be translated into multiple languages.
    *   **Language Selection:** Users can choose their preferred language from within the app.
    *   **Dynamic Language Switching:** The app's UI updates in real-time when the language is changed.
    *   **Persistent Language:** The selected language is saved and automatically applied on subsequent app launches.
    *   Uses `get` package for translation.

4.  **Notifications:**
    *   **Local Notifications:** The app can send local notifications to users.
    *   **Permission Handling:** The app requests necessary permissions for sending notifications.

5.  **Backend Integration:**
    *   **PocketBase:** Utilizes PocketBase as a backend service for data storage and user management.
    *   **Environment Variables:** Securely manages backend URLs and other sensitive information using environment variables.

6.  **State Management:**
    *   **GetX:** Employs the GetX package for efficient state management, routing, and dependency injection.
    *   **Obx:** Uses Obx to rebuild UI components reactively when state changes.

7.  **Data Persistence:**
    *   **GetStorage:** Uses GetStorage for persistent storage of user preferences (theme, language) and other data.

8. **Language Selection Page**
    * The user can select the language of the app.
    * The language is saved and applied on the next app start.

9. **Profile Page**
    * The user can see his profile.
    * This page is under development.

## Project Structure

The project is organized into the following key directories:

*   **`lib/main.dart`:**
    *   The entry point of the application.
    *   Initializes essential services like GetStorage, environment variables, theme controller, locale controller, PocketBase, and the notification service.
    *   Sets up the `GetMaterialApp` with theme, localization, and routing configurations.
    *   Starts the `AuthCheck` widget to determine the initial screen.

*   **`lib/utils/`:**
    *   **`auth/`:** Contains files related to user authentication.
        *   `auth_check.dart`: Checks if the user is logged in and redirects to the appropriate screen.
    *   **`theme/`:** Contains files related to theming.
        *   `app_theme.dart`: Defines the light and dark themes.
        *   `theme_controller.dart`: Manages the current theme and handles theme switching.
    *   **`translation/`:** Contains files related to localization.
        *   `locale_controller.dart`: Manages the current locale and handles language switching.
        *   `translation_service.dart`: Provides the translation data and fallback locale.
        * `language_selector.dart`: Widget for selecting the language.
    *   `notification_service.dart`: Handles notification initialization and permission requests.

*   **`lib/pages/`:**
    *   **`account/`:** Contains files related to user account management.
        *   `select_language.dart`: The page for selecting the app's language.
        * `profile.dart`: The user profile page.

## Dependencies

The project utilizes the following key dependencies:

*   **`flutter`:** The core Flutter SDK.
*   **`flutter_dotenv`:** For loading environment variables from a `.env` file.
*   **`get`:** For state management, routing, and dependency injection.
*   **`get_storage`:** For persistent data storage.
*   **`pocketbase`:** For interacting with the PocketBase backend.

## Setup and Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    ```

2.  **Navigate to the project directory:**
    ```bash
    cd inventory_management
    ```

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Create a `.env` file:**
    *   Create a `.env` file in the root of the project.
    *   Add the following line, replacing `<your_pocketbase_url>` with your actual PocketBase URL:
        ```
        POCKETBASE_URL=<your_pocketbase_url>
        ```

5.  **Run the app:**
    ```bash
    flutter run
    ```

## Future Enhancements

*   **Inventory Management Features:** Implement core inventory management features like adding, editing, deleting, and viewing inventory items.
*   **User Roles:** Implement different user roles with varying permissions.
*   **Advanced Search and Filtering:** Add advanced search and filtering capabilities for inventory items.
*   **Reporting and Analytics:** Generate reports and analytics on inventory data.
*   **More UI/UX improvements:** Improve the user interface and user experience.
* **Complete the profile page:** Add more features to the profile page.

## Contributing

Contributions to this project are welcome! Please feel free to submit pull requests or open issues to discuss potential improvements.

## License

MIT License (If you have a license file)
