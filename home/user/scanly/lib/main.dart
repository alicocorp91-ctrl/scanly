import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scanly/core/theme/app_theme.dart';
import 'package:scanly/core/providers/theme_provider.dart';
import 'package:scanly/shared/models/document_model.dart';
import 'package:scanly/shared/models/folder_model.dart';
import 'package:scanly/features/onboarding/presentation/onboarding_screen.dart';
import 'package:scanly/features/documents/presentation/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(FolderAdapter());
  Hive.registerAdapter(DocumentAdapter());

  // Open boxes
  await Hive.openBox<Folder>('folders');
  await Hive.openBox<Document>('documents');

  runApp(
    const ProviderScope(
      child: ScanlyApp(),
    ),
  );
}

class ScanlyApp extends ConsumerWidget {
  const ScanlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Scanly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    setState(() {
      _showOnboarding = !hasSeenOnboarding;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _showOnboarding
        ? const OnboardingScreen()
        : const HomeScreen();
  }
}