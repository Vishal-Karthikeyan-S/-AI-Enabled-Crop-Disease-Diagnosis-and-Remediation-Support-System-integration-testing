import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/preferences_service.dart';
import 'services/speech_service.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';
import 'services/auth_service.dart';
import 'services/tts_service.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/submission_provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Initialize FFI for web (Required for sqflite on Web, though we mostly use memory/backend)
    databaseFactory = databaseFactoryFfiWeb;
  }

  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);

  final speechService = SpeechService(preferencesService);
  await speechService.init();

  final ttsService = TtsService(preferencesService);
  await ttsService.init();

  final storageService = StorageService();
  final syncService = SyncService(storageService: storageService);
  final authService = AuthService(prefs);

  // Start auto-sync service (if enabled)
  // This background service periodically checks for pending uploads
  if (preferencesService.isAutoSyncEnabled()) {
    syncService.startAutoSync(interval: const Duration(minutes: 5));
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeProvider(preferencesService)),
        ChangeNotifierProvider(
            create: (_) => LanguageProvider(preferencesService)),
        ChangeNotifierProvider(
            create: (_) => FontSizeProvider(preferencesService)),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProxyProvider<ConnectivityProvider, SubmissionProvider>(
          create: (context) => SubmissionProvider(
            storageService: storageService,
            syncService: syncService,
          ),
          update: (context, connectivity, previous) {
            // Trigger sync when connectivity changes to online
            // This is the "Auto-Sync" feature in action.
            if (connectivity.isOnline && previous != null) {
              previous.syncPendingItems();
            }
            return previous ??
                SubmissionProvider(
                  storageService: storageService,
                  syncService: syncService,
                );
          },
        ),
        Provider.value(value: speechService),
        Provider.value(value: ttsService),
        Provider.value(value: storageService),
        Provider.value(value: syncService),
        Provider.value(value: preferencesService),
      ],
      child: const CropDiseaseApp(),
    ),
  );
}
