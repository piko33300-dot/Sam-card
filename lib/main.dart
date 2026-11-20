import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shop/screens/store/store_home_screen.dart';
import 'package:shop/theme/app_theme.dart';

const bool _firebaseEnabled = bool.fromEnvironment(
  'FIREBASE_ENABLED',
  defaultValue: true,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_firebaseEnabled) {
    // Firebase config files are supplied by the app owner. Keep the storefront
    // usable in preview builds if those platform files have not been added yet.
    try {
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint('Firebase initialization failed: $error');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAM CARD',
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const StoreHomeScreen(),
    );
  }
}
