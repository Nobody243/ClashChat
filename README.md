# ClashChat

A Flutter mobile application that enables users to engage in AI-powered debates on various topics. Users can select from preset debate categories or enter custom topics, choose their stance (For/Against), and have a structured debate conversation with an AI opponent. The app tracks debate history, scores, and provides performance analytics.

## Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Architecture](#architecture)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [Security Notes](#security-notes)
- [License](#license)

## About

ClashChat is a portfolio/learning project demonstrating:
- Firebase Authentication with Email/Password and Google Sign-In
- Firestore-backed user profiles and debate history
- AI-powered debate scoring and chat via Groq API
- Responsive Flutter UI with dark/light theme support
- Session management and user profile editing

## Features

- Firebase Authentication (Email + Google Sign-In)
- Firestore-backed user profiles and debate records
- AI scoring and chat via Groq API integration
- Dicebear avatar seeds rendered as SVG
- Daily per-user usage quota (client-enforced for demo)
- Dark/Light theme with smooth transitions
- Debate history with filtering capabilities
- 24-hour session management

## Prerequisites

- Flutter SDK 3.11.1 or higher
- Dart SDK 3.11.1 or higher
- Android SDK (for Android deployment)
- Xcode (for iOS deployment)
- Firebase project setup
- Groq API key

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/clashchat.git
cd clashchat
```

2. Install Flutter dependencies:

```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Email/Password and Google Sign-In authentication methods
   - Download and configure platform-specific configuration files

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Edit `.env` with your API keys:

```
GROQ_API_KEY=your_groq_api_key_here
GOOGLE_WEB_CLIENT_ID=your_google_web_client_id_here
```

### Firebase Setup

#### Web
- Register a web app in Firebase Console
- Add the configuration to `lib/firebase_options.dart`

#### Android
- Add `google-services.json` to `android/app/`
- Configure SHA-1 fingerprints for Google Sign-In

#### iOS
- Add `GoogleService-Info.plist` to `ios/Runner/`
- Configure URL schemes in Xcode

## Usage

### Development

Run in Chrome (recommended for development):

```bash
flutter run -d chrome
```

Run on Android device/emulator:

```bash
flutter run -d <device-id>
```

Run on iOS simulator:

```bash
flutter run -d ios
```

### Building for Production

Android:

```bash
flutter build apk --release
```

iOS:

```bash
flutter build ios --release
```

Web:

```bash
flutter build web --release
```

## Architecture

The project follows a modular architecture pattern:

```
lib/
├── core/           # Theme, colors, providers
├── models/         # Data structures (ChatMessage, DebateRecord)
├── screens/        # UI screens and navigation
├── services/       # Business logic (Auth, AI, Session)
└── widgets/        # Reusable UI components
```

### Key Components

- **AuthService**: Handles Firebase Authentication and Google Sign-In
- **AIService**: Manages AI conversation and scoring
- **SessionService**: Manages 24-hour user sessions
- **ThemeProvider**: Manages dark/light theme state

## Dependencies

### Core Framework
| Package | Version | Purpose |
|---------|---------|---------|
| flutter | sdk | UI framework |
| firebase_core | ^3.6.0 | Firebase initialization |
| firebase_auth | ^5.3.1 | Authentication |
| cloud_firestore | ^5.4.4 | Database |

### UI & Animations
| Package | Version | Purpose |
|---------|---------|---------|
| google_fonts | ^6.2.1 | Custom typography |
| flutter_animate | ^4.5.0 | Animations |
| lottie | ^3.1.2 | Lottie animations |
| flutter_svg | ^2.0.10+1 | SVG rendering |

### State Management & Storage
| Package | Version | Purpose |
|---------|---------|---------|
| provider | ^6.1.2 | State management |
| hive | ^2.2.3 | Local database |
| shared_preferences | ^2.2.3 | Key-value storage |

### Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| http | ^1.1.0 | HTTP requests |
| flutter_dotenv | ^5.2.1 | Environment variables |
| uuid | ^4.4.0 | UUID generation |

## Contributing

We welcome contributions. Please read our contributing guidelines for details on:

- Keeping secrets out of the repository
- Setting up the development environment
- Code style and submission process

See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## Security Notes

This is a demo application and not production-ready. Important considerations:

- The Groq API key is currently used client-side for prototyping. Consider adding a server-side proxy for production deployments.
- Do not commit real API keys or secrets to version control.
- Avatar seeds are stored as strings and rendered via `flutter_svg` for consistent avatar generation.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- Flutter team for the cross-platform framework
- Firebase for backend services
- Groq for AI API capabilities