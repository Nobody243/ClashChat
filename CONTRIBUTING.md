# Contributing to ClashChat

Thank you for your interest in contributing to ClashChat. This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Contributing Process](#contributing-process)
- [Security Guidelines](#security-guidelines)
- [Code Style](#code-style)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment. Please be constructive and professional in all interactions.

## Development Setup

### Prerequisites

- Flutter SDK 3.11.1 or higher
- Dart SDK 3.11.1 or higher
- Git
- Android Studio or VS Code with Flutter extensions

### Local Installation

1. Fork and clone the repository:

```bash
git clone https://github.com/yourusername/clashchat.git
cd clashchat
```

2. Install dependencies:

```bash
flutter pub get
```

3. Set up environment variables:

```bash
cp env.example env
# Edit env with your local values
```

4. Configure Firebase:
   - Create a Firebase project
   - Enable Email/Password and Google Sign-In authentication
   - Add platform-specific configuration files

## Secrets and Environment Variables

### Important Security Notice

Never commit secrets, API keys, or credentials to version control. This includes:
- `env` files
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- `lib/firebase_options.dart`

The repository's `.gitignore` is configured to exclude these files automatically.

### Environment Variables Setup

Use the provided `env.example` as a template:

```bash
cp env.example env
```

Required environment variables:
- `GOOGLE_WEB_CLIENT_ID`: Your Google OAuth client ID for web authentication.
- `APP_SHARED_SECRET`: A lightweight secret for communication between the Flutter app and your debate proxy.

#### Generating a Local App Shared Secret
For local development, you should generate your own unique `APP_SHARED_SECRET` (e.g. via terminal):
```bash
openssl rand -hex 32
```
Save this value in your local `env` file.

#### Setting up a Local Debate Proxy
Because Groq API calls are routed through a server-side proxy for security and the production proxy is privately-hosted, you will need to host your own proxy for local development.

Your local proxy only needs to:
1. Receive incoming requests containing your custom `APP_SHARED_SECRET` in the `X-App-Secret` header to verify the call.
2. Inject your personal `GROQ_API_KEY` into the authorization header.
3. Forward the request payload to the Groq API completion endpoint and return the response.

Once deployed or run locally, make sure to update the endpoint URL in your client code if you want to route to your local proxy.

### Continuous Integration / Production Secrets

All real secrets must be stored in your CI provider's secret store:

```yaml
# Example GitHub Actions configuration
env:
  APP_SHARED_SECRET: ${{ secrets.APP_SHARED_SECRET }}
  GOOGLE_WEB_CLIENT_ID: ${{ secrets.GOOGLE_WEB_CLIENT_ID }}
```

## Removing Accidental Commits

If sensitive data is accidentally committed and pushed:

1. Rotate the secret immediately at the provider
2. Remove it from Git history using `git filter-repo` or BFG
3. Coordinate with the team before force-pushing

```bash
# Remove sensitive file from history
git filter-repo --path env --path .env --invert-paths

# Force-push after team coordination
git push --force-with-lease origin main
```

## Contributing Process

### Creating a Pull Request

1. Create a feature branch from `main`:

```bash
git checkout -b feature/your-feature-name
```

2. Make your changes, following the project's code style
3. Test your changes thoroughly
4. Commit with a clear, descriptive message
5. Push to your fork and submit a pull request

### Pull Request Guidelines

- Ensure your code follows the project's style guidelines
- Include tests if applicable
- Update documentation for new features
- Link any related issues in the PR description

## Code Style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart).

### Key Style Rules

- Use `const` constructors where possible
- Maintain proper null safety
- Write comprehensive error handling
- Add comments for complex logic
- Format code with `dart format`

### Running Tests

```bash
flutter test
```

## Reporting Security Issues

If you discover a security issue or leaked key, please:
1. Contact the repository owner immediately
2. Do not open a public issue
3. Rotate the compromised key before reporting

## Getting Help

For questions or assistance:
- Open an issue with the `question` label
- Refer to the project documentation
- Check existing issues and PRs for context