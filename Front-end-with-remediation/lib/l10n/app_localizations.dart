import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
    Locale('te')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Crop Disease Diagnosis'**
  String get appTitle;

  /// No description provided for @capturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get capturePhoto;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit for Diagnosis'**
  String get submit;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. Will upload when connected.'**
  String get savedOffline;

  /// No description provided for @submittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Submitted successfully!'**
  String get submittedSuccessfully;

  /// No description provided for @submittedOnline.
  ///
  /// In en, this message translates to:
  /// **'Photo captured and saved!'**
  String get submittedOnline;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get telugu;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Crop Disease Diagnosis'**
  String get welcomeTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Identify crop diseases quickly and get remediation guidance'**
  String get welcomeMessage;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Capture or Select Image'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of affected crops or select from gallery'**
  String get onboardingStep1Desc;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Offline Support'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'App works without internet. Photos saved locally.'**
  String get onboardingStep2Desc;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Multi-Language'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Available in English, Hindi, Telugu, and Tamil'**
  String get onboardingStep3Desc;

  /// No description provided for @onboardingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistance'**
  String get onboardingStep4Title;

  /// No description provided for @onboardingStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap speaker icon to hear instructions'**
  String get onboardingStep4Desc;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @replayTutorial.
  ///
  /// In en, this message translates to:
  /// **'Replay Tutorial'**
  String get replayTutorial;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get appVersion;

  /// No description provided for @voiceInstructionHome.
  ///
  /// In en, this message translates to:
  /// **'Tap camera icon to capture a photo of affected crops, or tap gallery icon to select an existing image'**
  String get voiceInstructionHome;

  /// No description provided for @voiceInstructionCapture.
  ///
  /// In en, this message translates to:
  /// **'Tap the circular button to capture photo'**
  String get voiceInstructionCapture;

  /// No description provided for @voiceInstructionPreview.
  ///
  /// In en, this message translates to:
  /// **'Review your image. Tap submit to diagnose or retake to capture again'**
  String get voiceInstructionPreview;

  /// No description provided for @voiceInstructionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your submission was successful'**
  String get voiceInstructionSuccess;

  /// No description provided for @voiceInstructionOffline.
  ///
  /// In en, this message translates to:
  /// **'Your image was saved offline and will upload when you are connected to internet'**
  String get voiceInstructionOffline;

  /// No description provided for @errorCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get errorCameraPermission;

  /// No description provided for @errorStoragePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied'**
  String get errorStoragePermission;

  /// No description provided for @errorInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format'**
  String get errorInvalidFile;

  /// No description provided for @errorFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File size too large'**
  String get errorFileTooLarge;

  /// No description provided for @errorVideoTooLong.
  ///
  /// In en, this message translates to:
  /// **'Video duration exceeds 30 seconds'**
  String get errorVideoTooLong;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @mySubmissions.
  ///
  /// In en, this message translates to:
  /// **'My Submissions'**
  String get mySubmissions;

  /// No description provided for @noSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No submissions yet'**
  String get noSubmissions;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to hear'**
  String get tapToSpeak;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All →'**
  String get viewAll;

  /// No description provided for @quickTips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get quickTips;

  /// No description provided for @useGoodLighting.
  ///
  /// In en, this message translates to:
  /// **'Use good lighting'**
  String get useGoodLighting;

  /// No description provided for @useGoodLightingDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo in bright light for better detection.'**
  String get useGoodLightingDesc;

  /// No description provided for @focusOnLeaf.
  ///
  /// In en, this message translates to:
  /// **'Focus on the leaf'**
  String get focusOnLeaf;

  /// No description provided for @focusOnLeafDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep the affected area centered and avoid blur.'**
  String get focusOnLeafDesc;

  /// No description provided for @cleanCameraLens.
  ///
  /// In en, this message translates to:
  /// **'Clean camera lens'**
  String get cleanCameraLens;

  /// No description provided for @cleanCameraLensDesc.
  ///
  /// In en, this message translates to:
  /// **'Wipe the lens for sharper images.'**
  String get cleanCameraLensDesc;

  /// No description provided for @cereals.
  ///
  /// In en, this message translates to:
  /// **'Cereals'**
  String get cereals;

  /// No description provided for @legumes.
  ///
  /// In en, this message translates to:
  /// **'Legumes'**
  String get legumes;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @selectVegetable.
  ///
  /// In en, this message translates to:
  /// **'Select Vegetable'**
  String get selectVegetable;

  /// No description provided for @selectFruit.
  ///
  /// In en, this message translates to:
  /// **'Select Fruit'**
  String get selectFruit;

  /// No description provided for @treatmentSteps.
  ///
  /// In en, this message translates to:
  /// **'Treatment Steps'**
  String get treatmentSteps;

  /// No description provided for @loadingTreatment.
  ///
  /// In en, this message translates to:
  /// **'Loading treatment recommendations...'**
  String get loadingTreatment;

  /// No description provided for @noTreatmentAvailable.
  ///
  /// In en, this message translates to:
  /// **'No treatment information available'**
  String get noTreatmentAvailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @weatherAlert.
  ///
  /// In en, this message translates to:
  /// **'Weather Alert'**
  String get weatherAlert;

  /// No description provided for @avoidSprayingBeforeRain.
  ///
  /// In en, this message translates to:
  /// **'Avoid spraying before rain'**
  String get avoidSprayingBeforeRain;

  /// No description provided for @organic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get organic;

  /// No description provided for @chemical.
  ///
  /// In en, this message translates to:
  /// **'Chemical'**
  String get chemical;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @timing.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timing;

  /// No description provided for @safetyWarnings.
  ///
  /// In en, this message translates to:
  /// **'Safety Warnings:'**
  String get safetyWarnings;

  /// No description provided for @requiredSafetyEquipment.
  ///
  /// In en, this message translates to:
  /// **'Required safety equipment'**
  String get requiredSafetyEquipment;

  /// No description provided for @noTreatmentStepsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No treatment steps available for this option.'**
  String get noTreatmentStepsAvailable;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @warningLabel.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningLabel;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @remedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get remedies;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out and return to login screen'**
  String get logoutDesc;

  /// No description provided for @voiceAndAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Voice & Accessibility'**
  String get voiceAndAccessibility;

  /// No description provided for @voiceAssistance.
  ///
  /// In en, this message translates to:
  /// **'Voice assistance'**
  String get voiceAssistance;

  /// No description provided for @voiceAssistanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable/disable voice (read aloud) features'**
  String get voiceAssistanceDesc;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on interactions (if supported)'**
  String get hapticFeedbackDesc;

  /// No description provided for @syncAndNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sync & Notifications'**
  String get syncAndNotifications;

  /// No description provided for @autoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto sync'**
  String get autoSync;

  /// No description provided for @autoSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload pending items automatically when online'**
  String get autoSyncDesc;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable in-app notifications'**
  String get notificationsDesc;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @clearLocalHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear local history'**
  String get clearLocalHistory;

  /// No description provided for @clearLocalHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Deletes saved submissions and results from this device'**
  String get clearLocalHistoryDesc;

  /// No description provided for @clearLocalHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear local history?'**
  String get clearLocalHistoryConfirm;

  /// No description provided for @clearLocalHistoryWarning.
  ///
  /// In en, this message translates to:
  /// **'This will remove all locally saved submissions and results. This action cannot be undone.'**
  String get clearLocalHistoryWarning;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @localHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Local history cleared'**
  String get localHistoryCleared;

  /// No description provided for @uploadedImages.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Images'**
  String get uploadedImages;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @statusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved (not uploaded)'**
  String get statusSaved;

  /// No description provided for @statusUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get statusUploading;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @diagnosed.
  ///
  /// In en, this message translates to:
  /// **'Diagnosed'**
  String get diagnosed;

  /// No description provided for @searchCropDisease.
  ///
  /// In en, this message translates to:
  /// **'Search crop / disease...'**
  String get searchCropDisease;

  /// No description provided for @noRemediesFound.
  ///
  /// In en, this message translates to:
  /// **'No remedies found'**
  String get noRemediesFound;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @unknownCondition.
  ///
  /// In en, this message translates to:
  /// **'Unknown Condition'**
  String get unknownCondition;

  /// No description provided for @inconclusive.
  ///
  /// In en, this message translates to:
  /// **'Inconclusive'**
  String get inconclusive;

  /// No description provided for @analysisConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Confidence'**
  String get analysisConfidence;

  /// No description provided for @viewActionPlan.
  ///
  /// In en, this message translates to:
  /// **'View Action Plan'**
  String get viewActionPlan;

  /// No description provided for @tryNewCapture.
  ///
  /// In en, this message translates to:
  /// **'Try New Capture'**
  String get tryNewCapture;

  /// No description provided for @returningHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returningHome;

  /// No description provided for @lowSeverity.
  ///
  /// In en, this message translates to:
  /// **'Low Severity'**
  String get lowSeverity;

  /// No description provided for @mediumSeverity.
  ///
  /// In en, this message translates to:
  /// **'Medium Severity'**
  String get mediumSeverity;

  /// No description provided for @highSeverity.
  ///
  /// In en, this message translates to:
  /// **'High Severity'**
  String get highSeverity;

  /// No description provided for @unknownSeverity.
  ///
  /// In en, this message translates to:
  /// **'Unknown Severity'**
  String get unknownSeverity;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @takeVideo.
  ///
  /// In en, this message translates to:
  /// **'Take Video'**
  String get takeVideo;

  /// No description provided for @analysingImage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your crop image...'**
  String get analysingImage;

  /// No description provided for @diagnosisResults.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Results'**
  String get diagnosisResults;

  /// No description provided for @uploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading Photo...'**
  String get uploadingPhoto;

  /// No description provided for @analysisPending.
  ///
  /// In en, this message translates to:
  /// **'Analysis Pending'**
  String get analysisPending;

  /// No description provided for @uploadingPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Your photo is currently being sent to our servers. This may take a moment depending on your connection.'**
  String get uploadingPhotoDesc;

  /// No description provided for @analysisPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your photo is saved safely. It will be analyzed as soon as it syncs with our servers. Please check your internet connection.'**
  String get analysisPendingDesc;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get checkAgain;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @weatherWarning.
  ///
  /// In en, this message translates to:
  /// **'Weather Advisory'**
  String get weatherWarning;

  /// No description provided for @rainWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Rain is expected soon. Avoid applying treatments that can be washed away, or ensure they are applied during a dry window.'**
  String get rainWarningDesc;

  /// No description provided for @remediationInconclusive.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis inconclusive. Please capture a closer, well-lit photo of the affected area.'**
  String get remediationInconclusive;

  /// No description provided for @remediationFound.
  ///
  /// In en, this message translates to:
  /// **'We have identified {diseaseName}. The severity is {severity}. Please review the recommended treatment steps below.'**
  String remediationFound(Object diseaseName, Object severity);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
