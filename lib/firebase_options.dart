import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform - '
          'run flutterfire configure to generate platform-specific options.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQMAskTNY3c850tNajJk-Rp8b5Vsd5G8w',
    appId: '1:308163713864:android:5bd8ba9d8cd350ad81317d',
    messagingSenderId: '308163713864',
    projectId: 'clashchat-54dc0',
    storageBucket: 'clashchat-54dc0.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCqb6oxeOMr7gkV-E8brUkzFuebtq0umD0',
    appId: '1:308163713864:web:ba5dc847410a875281317d',
    messagingSenderId: '308163713864',
    projectId: 'clashchat-54dc0',
    storageBucket: 'clashchat-54dc0.firebasestorage.app',
    authDomain: 'clashchat-54dc0.firebaseapp.com',
    databaseURL: 'https://clashchat-54dc0-default-rtdb.asia-southeast1.firebasedatabase.app',
    measurementId: 'G-TSL0RL1CK9',
  );
}
