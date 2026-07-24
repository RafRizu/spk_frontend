import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/smartphone_provider.dart';
import 'providers/recommendation_provider.dart';
import 'views/catalog_screen.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SmartphoneProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
      ],
      child: MaterialApp(
        title: 'SPK Smartphone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FF),
        ),
        home: const CatalogScreen(),
      ),
    );
  }
}
