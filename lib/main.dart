import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/generation_provider.dart';
import 'providers/voice_provider.dart';
import 'screens/home_screen.dart';
import 'services/eleven_labs_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  final elevenLabsService = ElevenLabsService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ElevenLabsService>.value(value: elevenLabsService),
        ChangeNotifierProvider<VoiceProvider>(
          create: (_) => VoiceProvider(
            elevenLabsService: elevenLabsService,
            storageService: storageService,
          )..loadVoices(),
        ),
        ChangeNotifierProvider<GenerationProvider>(
          create: (_) => GenerationProvider(
            elevenLabsService: elevenLabsService,
            storageService: storageService,
          )..init(),
        ),
      ],
      child: const ElevenStudioApp(),
    ),
  );
}

class ElevenStudioApp extends StatelessWidget {
  const ElevenStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        cardTheme: CardTheme(
          color: const Color(0xFF1A1A24),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0F),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFF6C63FF),
          thumbColor: Color(0xFF6C63FF),
          inactiveTrackColor: Color(0xFF2A2A3A),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
