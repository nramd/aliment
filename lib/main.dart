import 'package:aliment/core/navigation/app_router.dart';
import 'package:aliment/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aliment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Sesuaikan dengan theme Anda, atau gunakan default
        useMaterial3: true,
        fontFamily: 'Gabarito',
      ),
      routerConfig: router,
    );
  }
}
