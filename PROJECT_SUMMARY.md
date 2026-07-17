# ClashChat - Complete Project Summary

**Version:** 1.0.0+1  
**Platform:** Flutter (iOS, Android, Web)  
**Language:** Dart 3.11.1+  
**Status:** In Development

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Directory Structure](#directory-structure)
4. [Dependencies](#dependencies)
5. [Core Features](#core-features)
6. [Screen Descriptions](#screen-descriptions)
7. [Models & Data](#models--data)
8. [Services](#services)
9. [Widgets & Components](#widgets--components)
10. [Theme & Colors](#theme--colors)
11. [Authentication Flow](#authentication-flow)
12. [Current Implementation Status](#current-implementation-status)
13. [Known Issues & Fixes Applied](#known-issues--fixes-applied)

---

## Project Overview

**ClashChat** is a Flutter mobile application that enables users to engage in AI-powered debates on various topics. Users can select from preset debate categories or enter custom topics, choose their stance (For/Against), and have a structured debate conversation with an AI opponent. The app tracks debate history, scores, and provides performance analytics.

### Core Concept
- **Tagline:** "Where every word is a weapon" / "Debate. Evolve. Dominate."
- **Primary Purpose:** Educational debate platform with AI conversation partner
- **Target Users:** Students, debaters, critical thinkers

---

## Architecture

### Technology Stack
- **Backend:** Firebase (Authentication, Firestore, Cloud Functions)
- **State Management:** Provider
- **UI Framework:** Flutter Material 3
- **Local Storage:** Hive, SharedPreferences
- **Authentication:** Firebase Auth + Google Sign-In
- **Real-time:** Firestore streams

### Design Pattern
- **MVC-like structure** with separation:
  - **Services**: Business logic (Auth, AI, Session management)
  - **Screens**: UI & navigation logic
  - **Widgets**: Reusable components
  - **Models**: Data structures
  - **Core**: Theme, colors, providers

### State Management Flow
```
Provider (ThemeProvider)
    ↓
Material App (observes theme changes)
    ↓
Screens consume ThemeProvider via context.watch<ThemeProvider>()
```

### Authentication Flow
```
Splash Screen (checks AuthService.isLoggedIn)
    ├─→ If logged in → HomeScreen
    └─→ If not logged in → LoginScreen
        ├─ Sign In → Firebase Auth → HomeScreen
        ├─ Create Account → Signup flow → Firestore doc creation → HomeScreen
        └─ Google Sign-In (both tabs) → Firebase Auth → HomeScreen
```

---

## Directory Structure

```
lib/
├── core/
│   ├── app_colors.dart           # Color palette constants
│   ├── app_theme.dart            # Light & dark theme definitions
│   └── theme_provider.dart       # ThemeMode provider (dark/light/system)
├── models/
│   ├── chat_message.dart         # ChatMessage model
│   └── debate_record.dart        # DebateRecord model
├── screens/
│   ├── splash_screen.dart        # App entry point with animation
│   ├── login_screen.dart         # Auth UI (Sign In / Sign Up tabs)
│   ├── home_screen.dart          # Main app shell with navigation
│   ├── chat_screen.dart          # Live debate interface
│   ├── results_screen.dart       # Post-debate results & stats
│   ├── history_screen.dart       # Past debates list with filters
│   ├── profile_screen.dart       # User profile & editing
│   ├── settings_screen.dart      # App settings
│   └── difficulty_screen.dart    # (Implicit) Debate difficulty/setup
├── services/
│   ├── auth_service.dart         # Firebase Auth, Google Sign-In
│   ├── ai_service.dart           # AI conversation (mock responses)
│   ├── session_service.dart      # Session management (SharedPreferences)
│   └── avatar_preferences.dart   # Avatar/user avatar storage
├── widgets/
│   ├── message_bubble.dart       # Chat message display
│   ├── typing_indicator.dart     # AI typing animation
│   ├── chat_input_bar.dart       # Message input field
│   ├── gradient_button.dart      # Reusable gradient button
│   ├── stance_button.dart        # For/Against toggle
│   ├── stat_chip.dart            # Small stat display
│   ├── result_stat_card.dart     # Post-debate stat card
│   ├── score_arc_painter.dart    # Circular progress arc
│   ├── history_debate_card.dart  # History list item
│   ├── history_summary_strip.dart # Aggregate stats strip
│   ├── feedback_section.dart     # Strengths/areas to improve
│   ├── user_avatar.dart          # User avatar display
│   └── avatar_card.dart          # Profile header card
├── firebase_options.dart         # Firebase project config
└── main.dart                     # App entry point
```

---

## Dependencies

### Core Framework
```yaml
flutter: sdk
cupertino_icons: ^1.0.8          # iOS-style icons
```

### Firebase & Backend
```yaml
firebase_core: ^3.6.0            # Firebase initialization
firebase_auth: ^5.3.1            # Email/password + Google auth
cloud_firestore: ^5.4.4          # Cloud database for debates
google_sign_in: ^6.2.1           # Google OAuth
```

### UI & Animation
```yaml
google_fonts: ^6.2.1             # Custom fonts
flutter_animate: ^4.5.0          # Advanced animations
lottie: ^3.1.2                   # Lottie animations (ChatAi.json)
flutter_svg: ^2.0.10+1           # SVG rendering
flutter_chat_ui: ^1.6.15         # Chat UI components
flutter_chat_types: ^3.6.2       # Chat message types
```

### State Management & Storage
```yaml
provider: ^6.1.2                 # State management
hive: ^2.2.3                     # Local NoSQL database
hive_flutter: ^1.1.0             # Hive Flutter integration
shared_preferences: ^2.2.3       # Simple key-value storage
```

### Utilities
```yaml
http: ^1.1.0                     # HTTP requests
flutter_dotenv: ^5.2.1           # Environment variables
uuid: ^4.4.0                     # UUID generation
intl: ^0.19.0                    # Internationalization
```

---

## Core Features

### 1. Authentication
- **Email/Password Sign Up & Sign In**
  - Form validation (non-empty fields required)
  - Error handling with dialogs
  - User data persisted to Firestore on signup
  
- **Google Sign-In**
  - Available on both Sign In and Create Account tabs
  - Dark-themed button matching UI
  - Automatic session creation
  - Redirect to HomeScreen on success

- **Session Management**
  - 24-hour session duration
  - Session token stored in SharedPreferences
  - Automatic logout on expiration

### 2. User Profile Management
- **Profile Storage:** Firestore document per user
  - Fields: `displayName`, `email`, `bio`, `role`, `createdAt`, `isGoogleSignIn`
  
- **Profile Display:**
  - Avatar with initials
  - Display name fallback (Firestore → Firebase Auth → "Debater")
  - Email from Firebase Auth
  - Role badge ("Member" default)
  
- **Profile Editing:**
  - Edit mode toggle (Edit/Done button)
  - Update displayName and bio
  - Real-time Firestore listener for changes
  - Both Firestore and Firebase Auth updated on save

- **Password Management:**
  - **Google Sign-In Users:** Conditional routing based on `isGoogleSignIn` flag
    - First time: Navigate to `CreatePasswordScreen` to set a password
    - After password created: Flag set to `false` in Firestore
    - Subsequent times: Navigate to `ChangePasswordScreen`
  - **Email/Password Users:** Always navigate to `ChangePasswordScreen`

### 3. Debate System
- **Topic Selection:**
  - 8 preset categories (Tech, Education, Society, Health, Politics, Environment, Economy, Culture)
  - Custom topic input
  - Category shown as selectable cards with icons and colors
  
- **Stance Selection:**
  - For/Against segmented control (`StanceButton`)
  - User stance displayed in chat header and results
  
- **Live Debate Chat:**
  - Real-time message exchange with AI
  - User messages right-aligned, purple-gold gradient
  - AI messages left-aligned, surface color
  - Typing indicator while AI responds
  - Multi-line input with send button

### 4. Results & Analytics
- **Post-Debate Score:**
  - Animated score arc (270° sweep) with gradient
  - Final score displayed in center of arc
  
- **Stat Display:**
  - Messages sent
  - Final score value
  - User stance
  - Strengths & areas to improve (bulleted feedback)
  
- **Navigation:**
  - "Debate Again" → Returns to ChatScreen
  - "Home" → Returns to HomeScreen

### 5. History Tracking
- **Debate List:**
  - Shows past debates with topic, score, stance, date
  - Score displayed as gradient pill
  - Stance as chip
  
- **Summary Stats:**
  - Total debates count
  - Average score
  - Win count (≥70 score)
  
- **Filtering:**
  - Filter by stance (All / For / Against)
  - Minimum score slider filter

### 6. Theme System
- **Dark/Light Mode:**
  - Toggle in Settings screen
  - Persisted via ThemeProvider
  - 400ms animation on switch
  
- **Color System:**
  - Dark theme: Deep midnight blacks + vibrant accents
  - Light theme: Luxury ivory + purple tints
  - Adaptive helpers: `AppColors.bg(isDark)`, `AppColors.surf(isDark)`

---

## Screen Descriptions

### 1. Splash Screen
- **File:** `lib/screens/splash_screen.dart`
- **Purpose:** App entry point with animation
- **Features:**
  - Lottie animation (ChatAi.json) centered on screen
  - Aurora blob background with animated gradients
  - App title "ClashChat" with gradient text
  - Tagline "Debate. Evolve. Dominate."
  - Version tag (v1.0.0) at bottom
  - Auth state check: Navigates to HomeScreen if logged in, LoginScreen otherwise
  - 700ms fade transition on exit

### 2. Login Screen
- **File:** `lib/screens/login_screen.dart`
- **Purpose:** User authentication (Sign In & Sign Up)
- **Always Dark Mode:** Immune to app theme settings
- **Background:**
  - Aurora blob painter (purple, indigo, gold, cyan blobs)
  - 60 twinkling stars with varying opacity
  - Orbiting rings (3 elliptical rings at different angles/speeds)
  - Orbiting dots on rings with glow effect
  - 40% black tint overlay
- **Central Card (Frosted Glass):**
  - ClipRRect with BackdropFilter (20 sigma blur)
  - Semi-transparent white background
  - Pulsing glow border
  - Animated logo orb (bolt icon in gradient circle, rotating arc, pulsing shadow)
  - Gradient title "ClashChat"
  - Tagline in italic
- **Tab System:**
  - Toggle between "Sign In" and "Create Account"
  - Animated switcher with fade + slide
  - Active tab shows gradient, inactive shows subtle background
  
- **Sign In Tab:**
  - Email field
  - Password field with visibility toggle
  - "Forgot password?" link (stub)
  - "Sign In" button (gradient, shimmer effect)
  - "Continue with Google" button (dark theme with border)
  
- **Create Account Tab:**
  - Full Name field
  - Email field
  - Password field with visibility toggle
  - "Join Debate" button (gradient, shimmer effect)
  - "Continue with Google" button (dark theme with border)
- **Form Validation:**
  - All fields required for signup
  - SnackBar errors for empty fields
- **Authentication:**
  - AuthService.login() / AuthService.signUp()
  - SessionService.createSession() on success
  - Redirect to HomeScreen

### 3. Home Screen
- **File:** `lib/screens/home_screen.dart`
- **Purpose:** Main app shell with navigation
- **Navigation Bar:**
  - Bottom NavigationBar with 4 tabs: Home, History, Profile, Settings
  - AnimatedContainer shows background color transition
  - IconButton style icons

- **Home Tab (_HomeBody):**
  - **Hero Card at top:**
    - Gradient background (purple-to-gold on dark, purple-to-gold on light)
    - Decorative circles (semi-transparent white)
    - User greeting: "Welcome back, [displayName]"
    - Three stats: Debates (12), Win Rate (78%), Avg Score (4.3)
    - Stats will be updated later with actual data
  
  - **Category Selection:**
    - "Choose a Category" header
    - 8 category cards in horizontal scroll (icons + labels)
    - Each category selectable, shows scale animation
    - Categories: Tech, Education, Society, Health, Politics, Environment, Economy, Culture
  
  - **Custom Topic Input:**
    - Text field for custom topic entry
    - Clears when category selected, vice versa
  
  - **Stance Selection:**
    - StanceButton component (For/Against segmented control)
    - Interactive toggle with color feedback
  
  - **FAB (Start Debate):**
    - Floating Action Button with "Start Debate" label
    - Icon: flash_on_rounded
    - Elastic scale animation on appearance
    - Calls _startDebate() → DifficultyScreen → ChatScreen

- **History Tab:** Displays HistoryScreen (see below)
- **Profile Tab:** Displays ProfileScreen (see below)
- **Settings Tab:** Displays SettingsScreen (see below)

### 4. Chat Screen
- **File:** `lib/screens/chat_screen.dart`
- **Purpose:** Live debate interface
- **App Bar:**
  - Topic name (e.g., "Technology")
  - User stance badge (colored pill)
  - End button to close debate
  
- **Message Display:**
  - ScrollView with auto-scroll to bottom on new messages
  - User messages: Right-aligned, purple-to-gold gradient background, round corners
  - AI messages: Left-aligned, surface color background
  - Animated slide-in from respective sides
  - Timestamp on each message (optional visibility)
  
- **Typing Indicator:**
  - Three bouncing dots animation
  - Appears while AI is responding
  - Disappears when AI message appears
  
- **Message Input:**
  - Multi-line TextFormField
  - Icon button to send (arrow icon)
  - TextField clears on send
  - Auto-scroll to bottom after send
  
- **Behavior:**
  - On app load: AI sends welcome message ("Welcome to ClashChat! Topic: [topic]. Stance: [stance]. Make your opening statement!")
  - On user message: Shows typing indicator, then AI responds after delay
  - End button: Navigates to ResultsScreen

### 5. Results Screen
- **File:** `lib/screens/results_screen.dart`
- **Purpose:** Post-debate results & performance feedback
- **Content:**
  - **Score Arc (270° sweep):**
    - Animated from 0 to final score
    - Gradient (purple-to-gold)
    - Score displayed in center (e.g., "78%")
  
  - **Stat Cards (3 columns):**
    - Messages sent count
    - Final score value
    - User stance label
  
  - **Feedback Sections (2):**
    - Strengths (green-tinted card)
    - Areas to Improve (amber-tinted card)
    - Bulleted lists with placeholder feedback
  
  - **Action Buttons (2 full-width):**
    - "Debate Again" → Pushes back to ChatScreen
    - "Home" → Pops to HomeScreen
  
- **Animations:**
  - Arc sweeps up on load
  - Stat cards fade in with delay stagger
  - Buttons shimmer effect

### 6. History Screen
- **File:** `lib/screens/history_screen.dart`
- **Purpose:** Past debates list & analytics
- **Top Summary Strip:**
  - Total debates count (large number)
  - Average score (large number)
  - Win count (large number)
  - Labels below each
  
- **Filter Bar:**
  - Icon button (filter icon) opens modal
  - Modal allows:
    - Stance filter (All / For / Against segmented control)
    - Minimum score slider (0-100)
    - Apply/Reset buttons
  
- **Debate List:**
  - HistoryDebateCard items (scrollable column)
  - Each card shows:
    - Topic name (bold)
    - Score (gradient pill, e.g., "78/100")
    - Stance (chip, colored)
    - Date/time (small gray text)
  - Tap to view details (stub - could expand or navigate)
  
- **Animations:**
  - Cards fade in with stagger animation
  - Filter icon rotates on tap

### 7. Profile Screen
- **File:** `lib/screens/profile_screen.dart`
- **Purpose:** User profile viewing & editing
- **Top Header:**
  - "Profile" title
  - Edit/Done toggle button (changes appearance based on mode)
  
- **Avatar Card:**
  - Gradient background (purple-to-surfaceDeep on dark, purple-to-gold on light)
  - Circular avatar with person icon
  - User display name (large, white text)
  - User email (smaller, semi-transparent white)
  - Role badge ("Member", gold text with gold border)
  - Camera icon overlay in edit mode (stub for photo upload)
  
- **Personal Info Section:**
  - Three editable fields (disabled by default):
    - Display Name (person icon)
    - Email Address (mail icon)
    - Bio (edit_note icon)
  - Dividers between fields
  - Fields highlight on edit mode
  
- **Save Button:**
  - Appears in edit mode
  - Updates both Firestore and Firebase Auth displayName
  - Shows success/error SnackBar
  
- **Account Section:**
  - Change Password tile:
    - Checks `isGoogleSignIn` flag in Firestore
    - Routes to `CreatePasswordScreen` if Google user hasn't set password
    - Routes to `ChangePasswordScreen` if email user or Google user with password
  - Notification Preferences tile (stub)
  - Privacy Settings tile (stub)
  - Help & Support tile (stub)
  
- **Sign Out:**
  - Full-width outlined button (red/error color)
  - LogoutIcon + "Sign Out" label
  - Clears session, logs out user, navigates to LoginScreen

### 8. Create Password Screen
- **File:** `lib/screens/create_password_screen.dart`
- **Purpose:** Allow Google sign-in users to create a password for their account
- **Access:** Profile Screen → Change Password → (if `isGoogleSignIn` is true)
- **App Bar:**
  - Title: "Create password"
  - Back button to return to profile
  
- **Form Fields:**
  - New Password field (password input, visibility toggle)
    - Validation: At least 8 characters, 1 uppercase letter, 1 number required
  - Confirm Password field (password input, visibility toggle)
    - Validation: Must match new password
  - Real-time error display (errors show only after attempting submission)
  
- **Submit Button:**
  - "Create Password" button (gradient)
  - On submit:
    - Validates both fields
    - Updates Firebase Auth user password
    - Updates Firestore `isGoogleSignIn` flag to `false`
    - Shows success SnackBar
    - Navigates back to Profile Screen
  - Loading state during submission
  
- **Error Handling:**
  - Displays Firebase errors (e.g., "password too weak")
  - User-friendly error messages in SnackBars

### 9. Change Password Screen
- **File:** `lib/screens/change_password_screen.dart`
- **Purpose:** Allow email/password or established users to change their password
- **Access:** Profile Screen → Change Password → (if `isGoogleSignIn` is false OR email/password user)
- **App Bar:**
  - Title: "Change password"
  - Back button to return to profile
  
- **Form Fields:**
  - Current Password field (password input, visibility toggle)
    - Used to verify user identity before allowing change
  - New Password field (password input, visibility toggle)
    - Same validation as CreatePasswordScreen
  - Confirm New Password field (password input, visibility toggle)
    - Must match new password
  - Real-time error display
  
- **Submit Button:**
  - "Update Password" button (gradient)
  - On submit:
    - Validates all fields
    - Verifies current password (reauthentication)
    - Updates Firebase Auth password
    - Shows success SnackBar
    - Navigates back to Profile Screen
  - Loading state during submission
  
- **Error Handling:**
  - "Current password is incorrect" if verification fails
  - Other Firebase errors displayed appropriately

### 10. Settings Screen
- **File:** `lib/screens/settings_screen.dart`
- **Purpose:** App configuration
- **Appearance Section:**
  - Dark Mode toggle (wired to ThemeProvider)
  - Shows current mode status
  
- **Preferences Section:**
  - Notifications toggle (stub)
  - Sound Effects toggle (stub)
  - Debate Timer dropdown (stub - "30s", "60s", "Unlimited")
  
- **About Section:**
  - App Version (v1.0.0)
  - Privacy Policy link (stub)
  - Terms of Service link (stub)
  
- **Animations:**
  - Tiles fade in with stagger
  - Toggle switches animate smoothly

---

## Models & Data

### ChatMessage
**File:** `lib/models/chat_message.dart`

```dart
class ChatMessage {
  final String text;          // Message content
  final bool isUser;          // true = user message, false = AI message
  final DateTime timestamp;   // When message was sent
}
```

### DebateRecord
**File:** `lib/models/debate_record.dart`

Structure (based on History Screen display):
```dart
class DebateRecord {
  final String id;            // Unique ID (UUID)
  final String topic;         // Debate topic
  final String stance;        // "For" or "Against"
  final int score;            // Final score (0-100)
  final DateTime dateTime;    // When debate occurred
  final List<String> strengths;        // Feedback strengths
  final List<String> improvements;     // Feedback areas to improve
  final int messageCount;     // Messages exchanged
}
```

### Firestore User Document
**Collection:** `users`  
**Document:** `{uid}`

```json
{
  "displayName": "John Doe",
  "email": "john@example.com",
  "bio": "Passionate debater",
  "role": "Member",
  "createdAt": Timestamp,
  "avatarSeed": "JohnDoe"  // For consistent avatar generation
}
```

### Firestore Debate Document (Future)
**Collection:** `debates`  
**Document:** `{debateId}`

```json
{
  "userId": "uid",
  "topic": "Technology",
  "stance": "For",
  "score": 78,
  "messages": [
    { "text": "...", "isUser": true, "timestamp": Timestamp },
    { "text": "...", "isUser": false, "timestamp": Timestamp }
  ],
  "strengths": ["..."],
  "improvements": ["..."],
  "createdAt": Timestamp
}
```

---

## Services

### AuthService
**File:** `lib/services/auth_service.dart`

**Purpose:** Handle authentication (Firebase Auth + Google Sign-In)

**Key Methods:**
- `signUp(String email, String password, {String? displayName})` → `Future<String?>`
  - Creates Firebase Auth user
  - Updates displayName in Firebase Auth
  - Creates Firestore user document
  - Returns null on success, error message on failure
  
- `login(String email, String password)` → `Future<String?>`
  - Signs in with email/password
  - Returns null on success, error message on failure
  
- `signInWithGoogle()` → `Future<UserCredential?>`
  - Google OAuth flow
  - Returns UserCredential on success, null on failure
  
- `logout()` → `Future<void>`
  - Signs out user
  - Clears session
  
- `currentUser` → `User?`
  - Getter for Firebase Auth current user
  
- `isLoggedIn` → `bool`
  - Getter returns true if user is logged in
  
- `fetchProfile(String uid)` → `Future<Map<String, dynamic>?>`
  - Fetches user profile from Firestore
  
- `profileStream(String uid)` → `Stream<DocumentSnapshot>`
  - Real-time listener for user profile changes

**Error Handling:**
- Try/catch for all async operations
- Firebase-specific error codes handled
- Console logging for debugging

### AIService
**File:** `lib/services/ai_service.dart`

**Purpose:** Handle AI conversation (currently mock responses)

**Current Status:** Mock implementation with hardcoded responses

**Expected Methods:**
- `getAIResponse(String topic, String userMessage, String stance)` → `Future<String>`
  - Should call actual AI API (OpenAI, Gemini, etc.)
  - Currently returns mock responses with delays
  - Supports context awareness (topic, stance)

**Future Enhancement:**
- Integrate with OpenAI API or similar
- Stream responses for real-time display
- Context-aware argument generation

### SessionService
**File:** `lib/services/session_service.dart`

**Purpose:** Manage user sessions (24-hour duration)

**Key Methods:**
- `createSession()` → `Future<void>`
  - Generates random token
  - Stores in SharedPreferences with timestamp
  
- `isSessionValid()` → `Future<bool>`
  - Checks if session exists and is not expired
  - Returns false if not found or expired
  
- `clearSession()` → `Future<void>`
  - Removes session token (logout)
  
- `getRemainingTime()` → `Future<Duration?>`
  - Returns time until session expiration
  - Returns null if no active session

**Storage Keys:**
- `session_token` → String (unique token)
- `session_created_at` → String (ISO 8601 timestamp)

**Session Duration:** 24 hours

### AvatarPreferences
**File:** `lib/services/avatar_preferences.dart`

**Purpose:** Manage avatar appearance (color, seed for consistency)

**Expected Methods:**
- Store/retrieve avatar color
- Generate consistent avatar for user based on seed

---

## Widgets & Components

### MessageBubble
**File:** `lib/widgets/message_bubble.dart`

Displays individual chat message with:
- Right-align for user messages, left-align for AI
- Gradient background for user (purple-to-gold)
- Surface color for AI
- Rounded corners
- Slide animation on appearance
- Optional timestamp

### TypingIndicator
**File:** `lib/widgets/typing_indicator.dart`

Three bouncing dots animation:
- Staggered animation timing
- Smooth scale/position changes
- Surface color background

### ChatInputBar
**File:** `lib/widgets/chat_input_bar.dart`

Message input component:
- Multi-line TextFormField
- Send button (icon or text)
- Character count (optional)
- Auto-focus keyboard
- Clears field on send

### GradientButton
**File:** `lib/widgets/gradient_button.dart`

Reusable gradient button:
- Customizable gradient colors
- Shimmer effect option
- Shadow with glow
- Rounded corners
- Loading state support

### StanceButton
**File:** `lib/widgets/stance_button.dart`

For/Against toggle:
- Segmented control style
- Color feedback on selection
- Smooth animation
- Returns selected stance

### StatChip
**File:** `lib/widgets/stat_chip.dart`

Small stat display:
- Icon + value + label
- Compact design
- Color theming
- Used in profile and history

### ResultStatCard
**File:** `lib/widgets/result_stat_card.dart`

Post-debate stat card:
- Larger than StatChip
- Gradient background (optional)
- Value + label
- Used in results screen

### ScoreArcPainter
**File:** `lib/widgets/score_arc_painter.dart`

Custom painter for score visualization:
- 270° sweep arc
- Gradient (purple-to-gold)
- Animated sweep from 0 to final score
- Text in center

### HistoryDebateCard
**File:** `lib/widgets/history_debate_card.dart`

History list item:
- Topic, score, stance, date
- Tap/long-press handlers (stub)
- Gradient accent (optional)
- Compact layout

### HistorySummaryStrip
**File:** `lib/widgets/history_summary_strip.dart`

Aggregate stats display:
- Total debates
- Average score
- Win count
- Horizontal layout
- Large typography

### FeedbackSection
**File:** `lib/widgets/feedback_section.dart`

Bulleted feedback card:
- Title (Strengths / Areas to Improve)
- Bulleted list of items
- Colored background (green for strengths, amber for improvement)
- Post-debate display

### UserAvatar
**File:** `lib/widgets/user_avatar.dart`

User avatar display:
- Circular container
- Initials or icon
- Placeholder if no image
- Color based on user/seed
- Sizes: small, medium, large

### AvatarCard
**File:** `lib/widgets/avatar_card.dart`

Profile header card:
- Avatar image
- Display name
- Email
- Role badge
- Edit mode camera icon (stub)

---

## Theme & Colors

**File:** `lib/core/app_colors.dart`

### Brand Colors
```dart
primary: #7B4FA6         // Royal Purple
primaryLight: #9D6DC4   // Soft Lavender
secondary: #3D7DD8      // Refined Blue
gold: #C49A3C           // Luxury Gold
```

### Semantic Colors
```dart
success: #2A7A4F        // Dark Green
successAlt: #38A169     // Medium Green
warning: #D4891A        // Orange
error: #C0392B          // Dark Red
errorAlt: #E53E3E       // Bright Red
```

### Dark Theme (Default)
```dart
background: #0C0B10     // Deep Midnight
surface: #14121C        // Dark Navy
surfaceDeep: #1C192A    // Darker Navy
```

### Light Theme
```dart
backgroundLight: #F8F7FF        // Soft Lavender White
surfaceLight: #FFFFFF           // Pure White
surfaceDeepLight: #F0ECFB       // Light Lavender Tint
```

### Adaptive Helpers
```dart
AppColors.bg(isDark)           // Returns appropriate background
AppColors.surf(isDark)         // Returns appropriate surface
AppColors.textPrimary(isDark)  // Returns appropriate text color
AppColors.textSecondary(isDark)
AppColors.border(isDark)
```

**Theme Implementation:** `lib/core/app_theme.dart`
- Light theme via `AppTheme.light()`
- Dark theme via `AppTheme.dark()`
- Material 3 design system
- Animated transitions (400ms, easeInOut curve)

---

## Authentication Flow

### Sign Up Flow
1. User taps "Create Account" tab on LoginScreen
2. Fills name, email, password
3. Taps "Join Debate" or "Continue with Google"
4. **Email/Password:**
   - AuthService.signUp(email, password, displayName)
   - Creates Firebase Auth user
   - Updates Firebase Auth displayName
   - Creates Firestore user document with: displayName, email, bio: "", role: "Member", createdAt
   - SessionService.createSession()
   - Navigator.pushAndRemoveUntil to HomeScreen
   - Form clears on success
5. **Google:**
   - AuthService.signInWithGoogle()
   - Calls GoogleSignIn().signIn()
   - Creates/updates Firebase Auth user
   - SessionService.createSession()
   - Navigator.pushReplacement to HomeScreen

### Sign In Flow
1. User taps "Sign In" tab on LoginScreen
2. Fills email, password
3. Taps "Sign In" or "Continue with Google"
4. **Email/Password:**
   - AuthService.login(email, password)
   - Signs in with Firebase Auth
   - SessionService.createSession()
   - Navigator.pushReplacement to HomeScreen
5. **Google:**
   - Same as signup (creates account if first time)

### Session Validation
- On app launch: Splash screen checks AuthService.isLoggedIn
- Splash navigates to HomeScreen if true, LoginScreen if false
- Session duration: 24 hours
- SessionService.isSessionValid() checked periodically (stub)

---

## Current Implementation Status

### ✅ Completed Features
- [x] Splash screen with Lottie animation
- [x] Login/Sign Up screens with Firebase Auth
- [x] Google Sign-In on both tabs
- [x] Email/password validation
- [x] Dark & light theme system with toggle
- [x] User profile creation in Firestore (with `isGoogleSignIn` flag)
- [x] User profile viewing & editing
- [x] Profile data display on home screen
- [x] Session management (24-hour)
- [x] Bottom navigation (Home, History, Profile, Settings)
- [x] Home screen with category selection
- [x] Custom topic input with validation (requires at least one letter)
- [x] For/Against stance selection
- [x] Chat screen with message display
- [x] User & AI message bubbles (styled)
- [x] Typing indicator animation
- [x] Message input bar with send
- [x] Results screen with score arc animation
- [x] Results stat cards and feedback sections
- [x] History screen with debate list
- [x] History filtering (stance, min score)
- [x] Summary stats strip
- [x] Settings screen with dark mode toggle
- [x] All animations (fade, slide, scale, shimmer)
- [x] Responsive layout (mobile first)
- [x] Aurora background effects (blobs, stars, rings)
- [x] 3D tilting card effect on login
- [x] Navigation state management
- [x] Password creation for Google sign-in users (CreatePasswordScreen)
- [x] Password change for established users (ChangePasswordScreen)
- [x] Conditional password screen routing based on `isGoogleSignIn` flag

### 🟡 Partially Implemented Features
- [ ] AI conversation (mock responses only, needs real API)
- [ ] Debate scoring algorithm (hardcoded values)
- [ ] User avatar image upload (photo picker stub)
- [ ] Password reset flow (via Firebase - UI link stub)
- [ ] Notification preferences (UI only)
- [ ] Sound effects toggle (UI only)
- [ ] Debate timer settings (UI only)

### ❌ Not Yet Implemented
- [ ] Debate persistence to Firestore
- [ ] Leaderboard/rankings
- [ ] Social features (follow users, share debates)
- [ ] Advanced analytics dashboard
- [ ] Push notifications
- [ ] Offline mode
- [ ] Debate categories admin panel
- [ ] User reporting/moderation
- [ ] Premium features
- [ ] In-app messaging between users

---

## Known Issues & Fixes Applied

### Issue 1: Navigation After Account Creation
**Problem:** After signup, app was stuck on LoginScreen instead of navigating to HomeScreen  
**Root Cause:** Splash screen always navigated to LoginScreen regardless of auth state  
**Fix Applied:**
- Updated SplashScreen to check `AuthService.isLoggedIn`
- Routes to HomeScreen if logged in, LoginScreen otherwise

### Issue 2: User Data Not Displaying on Profile
**Problem:** Profile page showed "Debater" instead of user's name after signup  
**Root Cause:** Profile data loading race condition with signup completion  
**Fix Applied:**
- Enhanced auth_service.dart with better error handling
- Improved profile_screen.dart to use Firebase Auth data as fallback
- Initialize controllers with Firebase Auth displayName first
- Firestore listener updates afterward
- home_screen.dart now falls back to Firebase Auth displayName

### Issue 3: Google Button Styling
**Problem:** White Google button stood out against dark login background  
**Fix Applied:**
- Changed background to dark semi-transparent (`_kBg.withValues(alpha: 0.5)`)
- Added subtle border (`_kBorder` with 1.5 width)
- Changed text color to white for contrast

### Issue 4: Signup Google/Apple Buttons Missing
**Problem:** Signup tab had "Join Debate" button but no Google option  
**Fix Applied:**
- Added identical Google sign-in button to signup form
- Maintains consistency between tabs
- Same dark styling and functionality

### Issue 5: Google Sign-In Users Password Management
**Problem:** Google users prompted to "change password" when they hadn't set one yet  
**Solution Implemented:**
- Added `isGoogleSignIn` boolean flag to Firestore user document
- Set to `true` when user signs in with Google (new users)
- Profile screen now checks this flag:
  - If `true`: Routes to `CreatePasswordScreen` (no current password required)
  - If `false`: Routes to `ChangePasswordScreen` (verifies current password)
- When password is created, `isGoogleSignIn` is set to `false`
- Status: ✅ **Implemented and tested**

### Issue 6: Sensitive Files Exposed in Git
**Problem:** Firebase credentials (`google-services.json`) and environment variables (`.env`) not properly protected
**Solution Applied:**
- Updated `.gitignore` to include:
  - `google-services.json` (Android Firebase credentials)
  - `GoogleService-Info.plist` (iOS Firebase credentials)
  - `.env` (environment variables with API keys)
  - `lib/firebase_options.dart` (Firebase configuration)
- Status: ✅ **Protected before first commit** (no push to GitHub yet)

---

## Development Notes

### Running the App
```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

### Hot Reload
```bash
# While app is running in terminal:
r   # Hot reload
R   # Hot restart
h   # List commands
d   # Detach
q   # Quit
```

### Environment Setup
- Create `.env` file with sensitive configuration (API keys, credentials)
- `.env` is in `.gitignore` and should NOT be committed to Git
- Same applies to `lib/firebase_options.dart`, `google-services.json`, and `GoogleService-Info.plist`
- Flutter 3.11.1+ required
- Dart 3.11.1+ required

### Firebase Setup
- Project initialized with DefaultFirebaseOptions
- Authentication: Email/Password + Google
- Database: Firestore with users collection
- Security Rules: (Currently in development mode - should restrict for production)

### Code Style
- Google Dart style guide
- Const constructors where possible
- Proper null safety (non-nullable by default)
- Comprehensive error handling
- Console logging for debugging

### Assets
- Lottie animations: `assets/lottie/ChatAi.json`
- Google icon: `assets/google_icon.png`
- Custom fonts: Via GoogleFonts package
- SVG support: Via flutter_svg

---

## Testing Checklist

- [ ] Signup with email/password
- [ ] Signup with Google
- [ ] Login with email/password
- [ ] Login with Google
- [ ] Profile data appears after signup
- [ ] Profile editing works
- [ ] Theme toggle works
- [ ] Navigation between tabs works
- [ ] Category selection works
- [ ] Custom topic input works
- [ ] Stance selection works
- [ ] Chat messages display correctly
- [ ] Results screen shows after debate
- [ ] History list shows past debates
- [ ] History filtering works
- [ ] Logout works and clears session
- [ ] App respects theme after restart
- [ ] All animations play smoothly
- [ ] Responsive on mobile/tablet/web

---

## Future Enhancements

1. **Real AI Integration**
   - Integrate OpenAI API or Google Gemini
   - Implement streaming responses
   - Add context-aware argument generation

2. **Debate Scoring**
   - Implement real scoring algorithm
   - Consider: argument quality, fact accuracy, rhetorical strength

3. **Social Features**
   - User profiles with photos
   - Follow other debaters
   - Share debate results
   - Leaderboards

4. **Analytics**
   - Advanced stats dashboard
   - Win rate trends
   - Topic expertise tracking

5. **Notifications**
   - Push notifications for friend activities
   - Debate reminders
   - Achievement unlocks

6. **Offline Mode**
   - Cache recent debates
   - Queue offline actions

7. **Premium Features**
   - Advanced AI modes
   - Unlimited debates
   - Custom debate categories

8. **Admin Panel**
   - Manage debate categories
   - User moderation
   - Analytics dashboard

---

## Support & Contact

For questions or issues, refer to:
- Flutter docs: https://flutter.dev
- Firebase docs: https://firebase.google.com/docs
- Project issue tracker: (Add your GitHub/Jira link)

---

**Last Updated:** May 9, 2026  
**Project Status:** In Development (Alpha)  
**Version:** 1.0.0+1
