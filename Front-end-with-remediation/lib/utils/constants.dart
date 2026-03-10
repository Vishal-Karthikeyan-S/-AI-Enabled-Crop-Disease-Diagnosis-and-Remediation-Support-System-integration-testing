class AppConstants {
  // App Info
  static const String appName = 'Crop Disease Diagnosis';
  static const String appVersion = '1.0.0';

  // File Constraints
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 50;
  static const int maxVideoDurationSeconds = 30;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const int maxVideoSizeBytes = maxVideoSizeMB * 1024 * 1024;

  // Supported File Formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];

  // Database
  static const String databaseName = 'crop_disease.db';
  static const int databaseVersion = 1;
  static const String mediaTable = 'media_files';

  // SharedPreferences Keys
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyFontSize = 'fontSize';
  static const String keyFirstLaunch = 'firstLaunch';
  static const String keyTutorialCompleted = 'tutorialCompleted';

  // Settings
  static const String keyVoiceEnabled = 'voiceEnabled';
  static const String keyNotificationsEnabled = 'notificationsEnabled';
  static const String keyHapticsEnabled = 'hapticsEnabled';
  static const String keyAutoSyncEnabled = 'autoSyncEnabled';

  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी',
    'te': 'తెలుగు',
    'ta': 'தமிழ்',
  };

  // Font Size Multipliers
  static const double fontSizeSmall = 0.9;
  static const double fontSizeMedium = 1.0;
  static const double fontSizeLarge = 1.2;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Auto-redirect Duration
  static const Duration autoRedirectDuration = Duration(seconds: 3);

  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeHome = '/home';
  static const String routeCamera = '/camera';
  static const String routeGallery = '/gallery';
  static const String routePreview = '/preview';
  static const String routeResults = '/results';
  static const String routeTreatment = '/treatment';
  static const String routeSubmission = '/submission';
  static const String routeSettings = '/settings';

  // Asset Paths
  static const String assetBgLight = 'assets/images/bg_light.png';
  static const String assetBgDark = 'assets/images/bg_dark.png';
}

enum FontSize {
  small,
  medium,
  large,
}
