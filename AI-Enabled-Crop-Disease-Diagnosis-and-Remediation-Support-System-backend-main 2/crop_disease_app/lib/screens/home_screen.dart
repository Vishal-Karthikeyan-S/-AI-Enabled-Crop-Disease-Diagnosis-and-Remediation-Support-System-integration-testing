import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/submission_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../data/crop_data.dart';
import 'crop_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final submissionProvider = Provider.of<SubmissionProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context);
    final currentLang = languageProvider.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information Header (Profile + Connectivity Status)
                _buildHeader(
                  context,
                  authService: authService,
                  connectivityProvider: connectivityProvider,
                  submissionProvider: submissionProvider,
                  themeProvider: themeProvider,
                  l10n: l10n,
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // Categories Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All →',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories Row - Using image icons like reference
                _buildCategoriesRow(context, currentLang, theme),
                const SizedBox(height: 32),

                _buildQuickTips(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required AuthService authService,
    required ConnectivityProvider connectivityProvider,
    required SubmissionProvider submissionProvider,
    required ThemeProvider themeProvider,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    final user = authService.currentUser;

    return Row(
      children: [
        // Profile Avatar (kept), but remove top settings icon per requirement.
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.name ?? 'Farmer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildConnectivityPill(
              theme: theme,
              isOnline: connectivityProvider.isOnline,
              pendingCount: submissionProvider.pendingCount,
              onlineLabel: l10n.online,
              offlineLabel: l10n.offline,
            ),
            const SizedBox(height: 10),
            _buildThemeToggle(themeProvider, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.light_mode, size: 16, color: Colors.grey[600]),
        Switch.adaptive(
          value: themeProvider.isDarkMode,
          onChanged: (_) => themeProvider.toggleTheme(),
          activeThumbColor: theme.colorScheme.primary,
          activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
        Icon(Icons.dark_mode, size: 16, color: Colors.grey[600]),
      ],
    );
  }

  Widget _buildConnectivityPill({
    required ThemeData theme,
    required bool isOnline,
    required int pendingCount,
    required String onlineLabel,
    required String offlineLabel,
  }) {
    final label = isOnline ? onlineLabel : offlineLabel;
    final subLabel = (!isOnline && pendingCount > 0) ? ' • $pendingCount pending' : '';

    final bg = isOnline ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12);
    final fg = isOnline ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOnline ? Icons.wifi : Icons.wifi_off, color: fg, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label$subLabel',
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(
      BuildContext context, String languageCode, ThemeData theme) {
    // Categories with 3D-style emoji/image representations
    final categories = [
      {
        'id': 'paddy',
        'emoji': '🌾',
        'name': {
          'en': 'Cereals',
          'hi': 'अनाज',
          'te': 'తృణధాన్యాలు',
          'ta': 'தானியங்கள்'
        }
      },
      {
        'id': 'wheat',
        'emoji': '🫛',
        'name': {
          'en': 'Legumes',
          'hi': 'दालें',
          'te': 'పప్పులు',
          'ta': 'பருப்புகள்'
        }
      },
      {
        'id': 'fruits',
        'emoji': '🍉',
        'name': {'en': 'Fruits', 'hi': 'फल', 'te': 'పండ్లు', 'ta': 'பழங்கள்'}
      },
      {
        'id': 'vegetables',
        'emoji': '🥦',
        'name': {
          'en': 'Vegetables',
          'hi': 'सब्जियां',
          'te': 'కూరగాయలు',
          'ta': 'காய்கறிகள்'
        }
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((category) {
        return _buildCategoryCard(
          context,
          emoji: category['emoji'] as String,
          name: (category['name'] as Map<String, String>)[languageCode] ??
              (category['name'] as Map<String, String>)['en']!,
          onTap: () => _navigateToCategory(context, category['id'] as String),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String emoji,
    required String name,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String categoryId) {
    if (categoryId == 'paddy' || categoryId == 'wheat') {
      final crop = CropData.getCropById(categoryId);
      if (crop != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CropDetailScreen(crop: crop)),
        );
      }
    } else {
      _showSubcategories(context, categoryId);
    }
  }

  void _showSubcategories(BuildContext context, String category) {
    final crops = CropData.getCropsByCategory(category);
    final theme = Theme.of(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLocale.languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category == 'vegetables' ? 'Select Vegetable' : 'Select Fruit',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...crops.map((crop) => ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: crop.imagePath != null
                        ? Image.asset(
                            crop.imagePath!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, _, __) => Icon(
                                Icons.eco,
                                color: theme.colorScheme.primary),
                          )
                        : Icon(Icons.eco, color: theme.colorScheme.primary),
                  ),
                  title: Text(crop.nameTranslations[currentLang] ?? crop.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CropDetailScreen(crop: crop)),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTips(ThemeData theme) {
    final tips = <Map<String, dynamic>>[
      {
        'icon': Icons.wb_sunny_outlined,
        'title': 'Use good lighting',
        'desc': 'Take a clear photo in bright light for better detection.'
      },
      {
        'icon': Icons.center_focus_strong,
        'title': 'Focus on the leaf',
        'desc': 'Keep the affected area centered and avoid blur.'
      },
      {
        'icon': Icons.cleaning_services_outlined,
        'title': 'Clean camera lens',
        'desc': 'Wipe the lens for sharper images.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((t) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    t['icon'] as IconData,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t['desc'] as String,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
