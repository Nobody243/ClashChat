# ClashChat — Screen Design Descriptions

This document describes all active user screens in the ClashChat Flutter application, detailing their layout, file locations, routing behavior, and features.

---

## 1. Splash Screen
**File:** `lib/screens/splash_screen.dart`

The entry point of the application. Displays the ClashChat logo and a centered Lottie animation (`ChatAi.json`) on a dark background with floating aurora background effects. Once the entry animation completes:
- It checks `AuthService.isLoggedIn` and validates the user session via `SessionService.isSessionValid()`.
- If logged in and valid, routes to the **Home Screen**.
- Otherwise, routes to the **Login Screen**.

---

## 2. Login Screen
**File:** `lib/screens/login_screen.dart`

The authentication hub, styled exclusively in a dark theme. Features an frosted central card containing two tabs:
- **Login**: Email and password fields with a submission button.
- **Sign Up**: Email, password, and display name fields.
- **Social Sign-In**: Integrated Google Sign-In buttons styled consistently with dark semi-transparent borders.
Upon successful auth, routes to the **Home Screen**.

---

## 3. Home Screen (Shell & Dashboard)
**File:** `lib/screens/home_screen.dart`

The primary navigation shell of the application. It contains a bottom navigation bar managing four screens:
- **Home (Dashboard)** (`_HomeBody`): Displays the main game portal.
- **History**: Pushes the list of past debates.
- **Profile**: Displays user rank, stats, and settings.
- **Settings**: App preferences and appearance.

The core **Home Dashboard** contains:
- **Hero Card** (`_HeroCard`): Shows the current user name and circular Dicebear avatar.
- **Rank Badge** (`RankBadgeWidget`): Displays current rank points and competitive title (e.g. Newcomer, Debater, Orator, Grandmaster).
- **Usage Card** (`_UsageCard`): Tracks the user's daily quota slots (restricting new games once exhausted).
- **Game Modes**: Three cards routing to the start of a debate:
  1. **Casual Mode**: Free practice with custom difficulty and timer constraints.
  2. **Ranked Mode**: Competitive match with points on the line, difficulty matched to user rank, and fixed 10-minute timers.
  3. **Learning Mode**: Coached mode providing constructive real-time debate analysis.

---

## 4. Topic Screen
**File:** `lib/screens/topic_screen.dart`

First step in setting up a debate. Users choose a category or input a custom topic:
- Displays 8 preset categories (Technology, Education, Society, Health, Politics, Environment, Economy, Culture) as responsive selectable cards.
- Provides a custom text input field.
- Navigates to the **Stance Screen** on confirmation.

---

## 5. Stance Screen
**File:** `lib/screens/stance_screen.dart`

Second step in setup. Users select their argument stance:
- A segmented control allowing the selection of **For** or **Against**.
- **Routing Logic**:
  - **Learning Mode**: Navigates directly to the **Chat Screen** (with "Adaptable" difficulty).
  - **Casual Mode**: Pushes to the **Debate Setup Screen**.
  - **Ranked Mode**: Pushes to the **Ranked Setup Screen**.

---

## 6. Debate Setup Screen
**File:** `lib/screens/debate_setup_screen.dart`

Casual Mode setup. Allows players to configure details of their practice session:
- **Difficulty Selection**: Cards for Easy (🌱), Medium (⚔️), and Hard (🔥).
- **Timer Switch**: Toggle to enable a custom debate timer with a minutes slider.
Tapping the action button launches the **Chat Screen**.

---

## 7. Ranked Setup Screen
**File:** `lib/screens/ranked_setup_screen.dart`

Ranked Mode preview. Displays competitive matchmaking parameters:
- Displays current matchmaking details (opponent search status, fixed 10-minute timer constraint, and automatic difficulty matching the player's current rank).
- Previews competitive points on the line.
Tapping start launches the **Chat Screen**.

---

## 8. Chat Screen
**File:** `lib/screens/chat_screen.dart`

The interactive debate interface:
- **App Bar**: Displays topic, current stance badge, and remaining timer.
- **Message List**: Bubbles slide in on entry. User messages are right-aligned with a purple-to-gold gradient; AI replies are left-aligned on surface colors.
- **Typing Indicator**: Shows bouncing dots while the AI endpoint processes.
- **Learning Mode**: Underneath the AI counter-argument, a separate card highlights the AI debate coach's tips and feedback on the user's last message.
Tapping **"End"** in the app bar triggers the final scoring and routes to the **Results Screen**.

---

## 9. Results Screen
**File:** `lib/screens/results_screen.dart`

The review page displayed after scoring completes:
- **Score Arc**: A circular gradient progress indicator painting the final debate score (0-100).
- **Stat Cards**: Displays messages exchanged, final score, and stance.
- **Feedback Lists**: Separate bulleted cards highlighting strengths and weaknesses/areas to improve.
- **Actions**: Double gradient buttons to "Debate Again" or return "Home".

---

## 10. History Screen
**File:** `lib/screens/history_screen.dart`

Accessed from navigation. Displays past debate history:
- **Summary Metrics**: Top strip listing total debates, average score, and wins (score ≥ 70).
- **History Cards**: Interactive cards displaying topic, stance, score, and date. Tapping a card opens its details in the **Results Screen** in read-only history mode.
- **Filter Sheet**: Bottom sheet modal to filter debates by stance and minimum score.

---

## 11. Profile Screen
**File:** `lib/screens/profile_screen.dart`

Accessed from navigation. Displays user account info and credentials setup:
- Displays circular Dicebear avatar, display name, email, and bio.
- **Stats Chips**: Displays profile statistics matching History (total debates, average score, wins).
- **Edit Mode**: Allows updating display name and bio directly in Firestore.
- **Password Check**: Clicking "Change Password" checks if `isGoogleSignIn` is true. If true, routes to **Create Password Screen**; if false, routes to **Change Password Screen**.

---

## 12. Avatar Picker Screen
**File:** `lib/screens/avatar_picker_screen.dart`

Accessed by tapping the avatar in edit mode:
- Allows selecting or randomizing custom Dicebear seed words.
- Displays responsive preview cards of the generated SVG avatars.
- Updates the seed back in the profile document upon selection.

---

## 13. Create Password Screen
**File:** `lib/screens/create_password_screen.dart`

Allows Google Sign-In users who have not yet configured a password to add credentials for email logins:
- Validates password guidelines (minimum 8 characters, 1 uppercase letter, 1 number).
- Updates password in Firebase Auth and flips the `isGoogleSignIn` Firestore flag to false.

---

## 14. Change Password Screen
**File:** `lib/screens/change_password_screen.dart`

Allows standard email/password users to change passwords:
- Validates current password via Firebase reauthentication.
- Validates and updates the new password.

---

## 15. Settings Screen
**File:** `lib/screens/settings_screen.dart`

Accessed from navigation. Features options for:
- **Appearance**: Dark Mode toggle changing themes dynamically via `ThemeProvider`.
- **Preferences**: Switches for notifications, sound, and timers (currently stubs).
- **About**: Displays version metrics and links to terms/privacy policies.
