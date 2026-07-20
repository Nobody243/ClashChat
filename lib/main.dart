import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/theme_provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env");

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDe9v0qLvAkqx8yB4FwVMVnPH9DODZSTPo",
        authDomain: "clashchat-54dc0.firebaseapp.com",
        databaseURL: "https://clashchat-54dc0-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "clashchat-54dc0",
        storageBucket: "clashchat-54dc0.firebasestorage.app",
        messagingSenderId: "308163713864",
        appId: "1:308163713864:web:ba5dc847410a875281317d",
        measurementId: "G-TSL0RL1CK9",
      ),
    );
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ClashChatApp(),
    ),
  );
}

class ClashChatApp extends StatelessWidget {
  const ClashChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'ClashChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOut,
      home: const SplashScreen(),
    );
  }
}
