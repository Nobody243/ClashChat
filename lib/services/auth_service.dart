import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'usage_quota_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static const String _googleWebClientId =
      '308163713864-930lujbb5030d0ou9fgh2cr28acm2o3p.apps.googleusercontent.com';

  static String _safeAvatarSeed(String? seed, {String fallback = 'Debater'}) {
    final value = seed?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  // Sign Up
  static Future<String?> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        return 'Failed to create user account';
      }

      // Use provided displayName, fallback to email prefix
      final finalDisplayName = (displayName != null && displayName.isNotEmpty)
          ? displayName
          : email.split('@').first;

      // Update Firebase Auth displayName
      try {
        await user.updateDisplayName(finalDisplayName);
        debugPrint('DisplayName updated: $finalDisplayName');
      } catch (e) {
        debugPrint('Error updating displayName: $e');
      }

      // Refresh the current user to ensure displayName is updated
      try {
        await _auth.currentUser?.reload();
        debugPrint('User reloaded after displayName update');
      } catch (e) {
        debugPrint('Error reloading user: $e');
      }

      // Create Firestore user document with retry logic
      try {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await userDoc.set({
          'displayName': finalDisplayName,
          'email': user.email,
          'bio': '',
          'role': 'Member',
          'rankPoints': 0,
          'dailyUsageLimit': UsageQuotaService.defaultDailyLimit,
          'dailyUsageUsed': 0,
          'dailyUsageDayKey': UsageQuotaService.todayKey(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('Firestore document created for user ${user.uid}');
      } catch (firestoreError) {
        debugPrint('Firestore error (non-blocking): $firestoreError');
        // Continue anyway - auth user is created, Firestore can be populated later
      }

      debugPrint('SignUp successful for $email - uid: ${user.uid}');
      return null; // null = success
    } on FirebaseAuthException catch (authError) {
      debugPrint('FirebaseAuthException: ${authError.code} - ${authError.message}');
      return authError.message ?? authError.code;
    } catch (e) {
      debugPrint('Unexpected SignUp error: $e');
      return 'Signup failed: ${e.toString()}';
    }
  }

  // Login
  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Current user
  static User? get currentUser => _auth.currentUser;

  // Check if logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // Check if user account still exists in Firestore
  static Future<bool> userAccountExists(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user account: $e');
      return false;
    }
  }

  // Fetch user profile from Firestore
  static Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return doc.data();
  }

  // Stream user profile updates
  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream(
    String uid,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }

  // Google Sign In
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
      }

      final user = userCredential.user;
      if (user == null) return null;

      final displayName = _safeAvatarSeed(user.displayName);
      final email = user.email ?? '';

      await user.updateDisplayName(displayName);
      await user.reload();

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final profileData = <String, dynamic>{
        'displayName': displayName,
        'email': email,
        'avatarSeed': displayName,
        'isGoogleSignIn': true,
        'bio': '',
        'role': 'Member',
        'rankPoints': 0,
        'dailyUsageLimit': UsageQuotaService.defaultDailyLimit,
        'dailyUsageUsed': 0,
        'dailyUsageDayKey': UsageQuotaService.todayKey(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        profileData['createdAt'] = FieldValue.serverTimestamp();
      }

      await userDoc.set(profileData, SetOptions(merge: true));
      await UsageQuotaService.ensureInitialized(user.uid);
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  // Check if user has password authentication set
  static bool hasPasswordAuth() {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Check if password provider exists in user's provider data
    return user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
  }
}
