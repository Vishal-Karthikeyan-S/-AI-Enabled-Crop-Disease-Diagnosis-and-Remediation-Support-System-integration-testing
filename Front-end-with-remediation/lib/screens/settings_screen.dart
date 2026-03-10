import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/submission_provider.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loaded = false;
  bool _voiceEnabled = true;
  bool _notificationsEnabled = true;
  bool _hapticsEnabled = true;
  bool _autoSyncEnabled = true;

  void _loadFromPrefs() {
    final prefs = Provider.of<PreferencesService>(context, listen: false);
    setState(() {
      _voiceEnabled = prefs.isVoiceEnabled();
      _notificationsEnabled = prefs.areNotificationsEnabled();
      _hapticsEnabled = prefs.areHapticsEnabled();
      _autoSyncEnabled = prefs.isAutoSyncEnabled();
      _loaded = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loadFromPrefs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    final prefs = Provider.of<PreferencesService>(context, listen: false);
    final syncService = Provider.of<SyncService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    final submissionProvider =
        Provider.of<SubmissionProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final speechService = Provider.of<SpeechService>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(l10n.account),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            subtitle: Text(l10n.logoutDesc),
            onTap: () async {
              await authService.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (r) => false);
            },
          ),
          const Divider(height: 40),
          _buildSectionTitle(l10n.language),
          _buildLanguageSelector(context, languageProvider),
          const Divider(height: 40),
          _buildSectionTitle(l10n.theme),
          SwitchListTile(
            title:
                Text(themeProvider.isDarkMode ? l10n.darkMode : l10n.lightMode),
            secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(height: 40),
          _buildSectionTitle(l10n.voiceAndAccessibility),
          SwitchListTile(
            title: Text(l10n.voiceAssistance),
            subtitle: Text(l10n.voiceAssistanceDesc),
            secondary: const Icon(Icons.volume_up),
            value: _voiceEnabled,
            onChanged: (value) async {
              setState(() => _voiceEnabled = value);
              await prefs.setVoiceEnabled(value);
              if (!value) {
                await speechService.stop();
                await ttsService.stop();
              }
            },
          ),
          SwitchListTile(
            title: Text(l10n.hapticFeedback),
            subtitle: Text(l10n.hapticFeedbackDesc),
            secondary: const Icon(Icons.vibration),
            value: _hapticsEnabled,
            onChanged: (value) async {
              setState(() => _hapticsEnabled = value);
              await prefs.setHapticsEnabled(value);
            },
          ),
          const Divider(height: 40),
          _buildSectionTitle(l10n.syncAndNotifications),
          SwitchListTile(
            title: Text(l10n.autoSync),
            subtitle: Text(l10n.autoSyncDesc),
            secondary: const Icon(Icons.sync),
            value: _autoSyncEnabled,
            onChanged: (value) async {
              setState(() => _autoSyncEnabled = value);
              await prefs.setAutoSyncEnabled(value);
              if (value) {
                syncService.startAutoSync(interval: const Duration(minutes: 5));
              } else {
                syncService.stopAutoSync();
              }
            },
          ),
          SwitchListTile(
            title: Text(l10n.notifications),
            subtitle: Text(l10n.notificationsDesc),
            secondary: const Icon(Icons.notifications_active_outlined),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await prefs.setNotificationsEnabled(value);
            },
          ),
          const Divider(height: 40),
          _buildSectionTitle(l10n.fontSize),
          _buildFontSizeSelector(context, fontSizeProvider, l10n),
          const Divider(height: 40),
          _buildSectionTitle(l10n.data),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.clearLocalHistory),
            subtitle: Text(l10n.clearLocalHistoryDesc),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.clearLocalHistoryConfirm),
                  content: Text(
                    l10n.clearLocalHistoryWarning,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.clear),
                    ),
                  ],
                ),
              );

              if (ok != true) return;
              await storageService.clearAllData();
              await submissionProvider.loadSubmissions();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.localHistoryCleared)),
              );
            },
          ),
          const Divider(height: 40),
          _buildSectionTitle(l10n.about),
          ListTile(
            title: Text(l10n.about),
            subtitle: Text(l10n.appVersion),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context, LanguageProvider provider) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppConstants.supportedLanguages.entries.map((entry) {
        final isSelected = provider.currentLocale.languageCode == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) provider.setLanguage(entry.key);
          },
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: FontWeight.bold,
          ),
          selectedColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSelector(
      BuildContext context, FontSizeProvider provider, AppLocalizations l10n) {
    return RadioGroup<FontSize>(
      groupValue: provider.currentFontSize,
      onChanged: (value) {
        if (value != null) provider.setFontSize(value);
      },
      child: Column(
        children: [
          RadioListTile<FontSize>(
            title: Text(l10n.small, style: const TextStyle(fontSize: 12)),
            value: FontSize.small,
          ),
          RadioListTile<FontSize>(
            title: Text(l10n.medium, style: const TextStyle(fontSize: 16)),
            value: FontSize.medium,
          ),
          RadioListTile<FontSize>(
            title: Text(l10n.large, style: const TextStyle(fontSize: 20)),
            value: FontSize.large,
          ),
        ],
      ),
    );
  }
}
