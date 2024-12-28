# Content AI

Content AI is a Flutter application designed to help users create and manage their social media profiles and content calendars. The app integrates with Firebase for authentication and data storage.

## Features

- **Profile Creation**: Users can create and customize their social media profiles.
- **Content Calendar**: Users can plan and manage their content schedule.
- **Authentication**: Supports Google, Apple, and anonymous sign-in.
- **Real-time Updates**: Uses Firebase Firestore for real-time data synchronization.

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Firebase Project: [Set up Firebase](https://firebase.google.com/docs/flutter/setup)

### Installation

1. Clone the repository:

   ````sh
   git clone https://github.com/your-username/content_ai.git
   cd content_ai
   ```sh

   ````

2. Install dependencies:

   ```sh
   flutter pub get
   ```

3. Set up Firebase:

   - Follow the instructions to add Firebase to your Flutter app: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
   - Place the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) in the respective directories.

4. Run the app:

   ```sh
   flutter run
   ```

## Project Structure

```
lib/
├── auth/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   ├── auth_repo.dart
│   └── auth_state.dart
├── home/
│   ├── calendar_bloc.dart
│   ├── calendar_event.dart
│   ├── calendar_state.dart
│   ├── home_screen.dart
│   └── home_widgets.dart
├── profile/
│   ├── profile_bloc.dart
│   ├── profile_creation_screen.dart
│   ├── profile_event.dart
│   ├── profile_model.dart
│   └── profile_state.dart
└── main.dart
```

## Usage

### Profile Creation

1. Open the app and sign in using Google, Apple, or as a guest.
2. If you don't have a profile, you will be prompted to create one.
3. Fill in the required fields and submit the form.

### Content Calendar

1. Navigate to the home screen.
2. Select a date to view or add content.
3. Use the floating action button to add new content suggestions.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
