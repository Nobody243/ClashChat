# ClashChat — Screen Design Descriptions

---

## 1. Splash Screen
**File:** `lib/screens/splash_screen.dart`

The entry point of the app. Displays the ClashChat logo and a Lottie animation (`ChatAi.json`) centered on a dark background with animated aurora blob shapes floating behind it. Once the animation completes, the screen fades out and transitions to the Login Screen.

---

## 2. Login Screen
**File:** `lib/screens/login_screen.dart`

Always displayed in dark mode regardless of system settings. Features a rich decorative background: aurora color blobs, a subtle star field, an orbital glowing ring, and the ClashChat logo with a soft glow. A floating frosted card in the center hosts two tabs — **Login** and **Sign Up** — with email/password fields and a gradient action button. Tapping the button navigates directly to the Home Screen.

---

## 3. Home Screen
**File:** `lib/screens/home_screen.dart`

The main shell of the app. Contains a bottom **Navigation Bar** with four tabs:

- **Home** — The debate setup page. Users scroll through 8 preset topic categories (Tech, Education, Society, Health, Politics, Environment, Economy, Culture), each shown as a selectable card. Below the categories, a text field lets the user type a custom topic. A **For / Against** segmented control (`StanceButton`) lets the user pick their stance. A floating action button labeled **"Start Debate"** launches the Chat Screen.
- **History** — See History Screen.
- **Profile** — See Profile Screen.
- **Settings** — See Settings Screen.

Tabs switch with an `AnimatedSwitcher` (no screen push).

---

## 4. Chat Screen
**File:** `lib/screens/chat_screen.dart`

The live debate interface. The app bar shows the debate topic and the user's chosen stance as a colored badge. Messages appear as animated bubbles that slide in from their respective sides:

- **User messages** — right-aligned, purple-to-gold gradient background.
- **AI messages** — left-aligned, surface color.

A **Typing Indicator** (three staggered bouncing dots) appears while the AI is "thinking." The bottom of the screen has a multi-line text input bar with an animated send button. An **"End"** button in the app bar closes the debate and pushes to the Results Screen.

---

## 5. Results Screen
**File:** `lib/screens/results_screen.dart`

Shown after ending a debate. Features:

- A large animated **Score Arc** (`ScoreArcPainter`) — a 270° sweep arc with a purple-to-gold gradient that animates to the final score.
- A row of three **Stat Cards** showing messages sent, score value, and stance.
- Two **Feedback Sections** — one for Strengths and one for Areas to Improve — each displayed as a bulleted card.
- Two full-width **Gradient Buttons** with a looping shimmer effect: **"Debate Again"** (goes back to Chat) and **"Home"** (returns to Home Screen).

---

## 6. History Screen
**File:** `lib/screens/history_screen.dart`

Accessed from the bottom navigation bar. Displays a list of past debates as **History Debate Cards**, each showing the topic, score badge (gradient pill), stance chip, and date. At the top, a **Summary Strip** shows three aggregate stats: total debates, average score, and wins (score ≥ 70). A filter icon opens a modal bottom sheet where the user can filter by stance (All / For / Against) and set a minimum score using a slider.

---

## 7. Profile Screen
**File:** `lib/screens/profile_screen.dart`

Accessed from the bottom navigation bar. Shows a circular avatar with a placeholder icon, and **editable fields** for name, email, and bio. An **Edit / Done** toggle button in the app bar switches between view and edit mode. Three `StatChip` pills display total debates, wins, and average score.

**Password Management:**
- A "Change Password" tile in the Account section
- Checks the `isGoogleSignIn` Firestore flag to determine routing:
  - **If true (Google user without password):** Routes to `CreatePasswordScreen`
  - **If false (email user or Google user with password):** Routes to `ChangePasswordScreen`

A logout tile at the bottom navigates back to the Login Screen.

---

## 8. Create Password Screen
**File:** `lib/screens/create_password_screen.dart`

Exclusive to Google sign-in users who haven't set a password yet. Accessed via Profile Screen → Change Password (when `isGoogleSignIn` is true).

**Features:**
- **App Bar:** "Create password" title with back button
- **Form Fields:**
  - New Password field (password input with visibility toggle)
    - Validation: Minimum 8 characters, at least one uppercase letter, at least one number
  - Confirm Password field (password input with visibility toggle)
    - Validation: Must match the new password
  - Errors display only after attempting form submission

**Functionality:**
- **Submit Button:** "Create Password" button with gradient styling
  - Validates form on tap
  - Updates Firebase Auth password using `user.updatePassword()`
  - Updates Firestore `isGoogleSignIn` flag to `false` (marks user as having password)
  - Shows success SnackBar
  - Navigates back to Profile Screen
  - Loading state displayed during submission

**Error Handling:**
- Displays Firebase Auth errors (e.g., weak password)
- User-friendly error messages in SnackBars
- Graceful handling of user not found scenarios

---

## 9. Change Password Screen
**File:** `lib/screens/change_password_screen.dart`

For email/password users or Google sign-in users who have already created a password (when `isGoogleSignIn` is false).

**Features:**
- **App Bar:** "Change password" title with back button
- **Form Fields:**
  - Current Password field (password input with visibility toggle)
    - Used to verify user identity before allowing change
  - New Password field (password input with visibility toggle)
    - Same validation as CreatePasswordScreen
  - Confirm New Password field (password input with visibility toggle)
    - Must match new password
  - Errors display only after attempting form submission

**Functionality:**
- **Submit Button:** "Update Password" button with gradient styling
  - Validates all fields on tap
  - Verifies current password (requires reauthentication with Firebase)
  - Updates Firebase Auth password
  - Shows success SnackBar
  - Navigates back to Profile Screen
  - Loading state displayed during submission

**Error Handling:**
- "Current password is incorrect" message if verification fails
- Firebase Auth errors displayed appropriately
- Handles user not found or auth state issues

---

## 10. Settings Screen
**File:** `lib/screens/settings_screen.dart`

Accessed from the bottom navigation bar. Organized into sections:

- **Appearance** — Functional **Dark Mode** toggle wired to `ThemeProvider`.
- **Preferences** — Notifications switch, Sound Effects switch, Debate Timer selector (currently stub values).
- **About** — App Version, Privacy Policy link, Terms of Service link.
