import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);

  final speechService = SpeechService(preferencesService);
  await speechService.init();

  final ttsService = TtsService(preferencesService);
  await ttsService.init();

  final storageService = StorageService(prefs);
  
  // Professional Dynamic Backend Discovery: 
  // Use the same host as the page (localhost, 127.0.0.1, or a specific IP)
  String host = kIsWeb ? Uri.base.host : '10.0.2.2';
  if (host == '0.0.0.0' || host.isEmpty) host = 'localhost';
  final String apiBaseUrl = 'http://$host:8001';
  
  if (kDebugMode) {
    print('Backend Discovery: $apiBaseUrl');
  }
  
  final syncService = SyncService(storageService: storageService, baseUrl: apiBaseUrl);
  final authService = AuthService(prefs);

  // Start auto-sync service (if enabled)
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
        ChangeNotifierProvider(create: (_) => ConnectivityProvider(baseUrl: apiBaseUrl)),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProxyProvider<ConnectivityProvider, SubmissionProvider>(
          create: (context) => SubmissionProvider(
            storageService: storageService,
            syncService: syncService,
          ),
          update: (context, connectivity, previous) {
            // Trigger sync when connectivity changes to online
            if (connectivity.isOnline && previous != null) {
              syncService.syncPendingSubmissions();
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
