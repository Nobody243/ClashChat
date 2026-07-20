# ClashChat

A mobile-first Flutter application that enables users to engage in AI-powered debates on various topics. Engaging in structured debates with an AI opponent, users can choose their stance, track their progress, and view performance analytics.

A responsive web build is also available as a secondary deployment target to provide broader accessibility (e.g., for quick portfolio viewing without installing an application).

## 📥 Downloads & Demos

- **Android Mobile App**: Download the latest release APK from **[GitHub Releases](https://github.com/Nobody243/ClashChat/releases/latest)**.  
  *(Note: Since this APK is distributed outside the Google Play Store, Android will display an "Unknown Sources" or Play Protect warning during installation. This is expected and safe for this portfolio/demo build.)*
- **Web Version (Secondary)**: Engage directly on the web at **[ClashChat Web Demo](https://clashchat-54dc0.web.app)**.  
  *(Note: The web build adapts the mobile layout for wider screens. For the full native experience, we recommend downloading the Android APK.)*

### 🌐 Browser Notes
If you are accessing the web version using a browser with aggressive built-in privacy tools or VPNs enabled (such as Opera GX with its built-in VPN turned on), these features may block client connections to Firebase Auth or the proxy. If you encounter issues loading the demo or logging in, please try temporarily disabling these browser settings or using a standard browser.


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
- AI scoring and chat via Groq API integration (routed securely via proxy)
- Dicebear avatar seeds rendered as SVG
- Daily per-user usage quota (client-enforced for demo)
- Dark/Light theme with smooth transitions
- Debate history with filtering capabilities
- 24-hour session management
- Three game modes: Casual (free practice), Ranked (competitive scoring), and Learning (coached feedback and tips)
- Responsive layout support adapting the mobile-first UI for desktop/tablet browser windows

## Prerequisites

- Flutter SDK 3.11.1 or higher
- Dart SDK 3.11.1 or higher
- Android SDK (for Android deployment)
- Xcode (for iOS deployment)
- Firebase project setup
- APP_SHARED_SECRET (configured in local env)

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

Copy `env.example` to `env` and fill in your values:

```bash
cp env.example env
```

Edit `env` with your client settings:

```
APP_SHARED_SECRET=your_app_shared_secret_here
GOOGLE_WEB_CLIENT_ID=your_google_web_client_id_here
```

> [!NOTE]
> Groq API calls are routed through a separate, privately-hosted server-side proxy (not included in this repository) to keep the Groq API key out of the client app. The client uses `APP_SHARED_SECRET` as a lightweight header token when talking to the proxy for basic abuse deterrence.

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

### API Routing Architecture

For security, Groq API calls are not made directly from the client. Instead, they route through a separate, privately-hosted server-side proxy to protect API keys:

```
[Flutter App] --(APP_SHARED_SECRET)--> [Server-side Proxy] --(GROQ_API_KEY)--> [Groq API]
```

The `APP_SHARED_SECRET` acts as a lightweight abuse deterrent at the proxy level.

### Responsive Layout Support

To support wider viewports on desktop browsers, the app uses a mobile-first design adapted for wider screens via the following new components:
- **ResponsiveLayout** ([responsive_layout.dart](file:///e:/Projects/MAD%20CLASHCHAT/clashchat/lib/core/responsive_layout.dart)): Centralizes standard viewport width breakpoints and device checking helper methods.
- **DesktopPageShell** ([desktop_page_shell.dart](file:///e:/Projects/MAD%20CLASHCHAT/clashchat/lib/widgets/desktop_page_shell.dart)): A dual-column layout wrapper that constrains, centers, and adapts mobile forms and debate windows gracefully on desktop dimensions.

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

This is a demo/portfolio application and is not production-hardened. Important considerations:

- **Proxy-based API Routing**: Groq API calls are routed through a separate, privately-hosted server-side proxy (not included in this repository) to keep the Groq API key out of the client app.
- **Abuse Deterrence**: The app uses `APP_SHARED_SECRET` as a lightweight header token when talking to the proxy. This is an abuse-deterrent measure, not a strong cryptographic security boundary, as the secret is necessarily present in the compiled client app.
- **Do Not Commit Secrets**: Never commit real secrets, environment files (`env`), or Firebase configuration files to version control.
- **Avatars**: Avatar seeds are stored as strings and rendered via `flutter_svg` for consistent avatar generation.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- Flutter team for the cross-platform framework
- Firebase for backend services
- Groq for AI API capabilities