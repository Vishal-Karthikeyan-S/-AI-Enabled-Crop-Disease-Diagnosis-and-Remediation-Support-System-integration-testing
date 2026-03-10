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
import '../services/sync_service.dart';

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Text(
                      l10n.categories,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.viewAll,
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories Row - Using image icons like reference
                _buildCategoriesRow(context, currentLang, theme, l10n),
                const SizedBox(height: 32),

                _buildQuickTips(theme, l10n),
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
                l10n.welcome,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
              context: context,
              theme: theme,
              connectivityProvider: connectivityProvider,
              submissionProvider: submissionProvider,
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
        Icon(Icons.light_mode, size: 16, color: theme.iconTheme.color),
        Switch.adaptive(
          value: themeProvider.isDarkMode,
          onChanged: (_) => themeProvider.toggleTheme(),
          activeThumbColor: theme.colorScheme.primary,
          activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
        Icon(Icons.dark_mode, size: 16, color: theme.iconTheme.color),
      ],
    );
  }

  Widget _buildConnectivityPill({
    required BuildContext context,
    required ThemeData theme,
    required ConnectivityProvider connectivityProvider,
    required SubmissionProvider submissionProvider,
    required String onlineLabel,
    required String offlineLabel,
  }) {
    final isOnline = connectivityProvider.isOnline;
    final isNetworkOn = connectivityProvider.isNetworkOn;
    final pendingCount = submissionProvider.pendingCount;

    Color fg;
    String label;
    IconData icon;

    if (isOnline) {
      fg = Colors.green;
      label = onlineLabel;
      icon = Icons.wifi;
    } else if (isNetworkOn) {
      fg = Colors.orange;
      label = "No Server"; // Server is unreachable but wifi/data is on
      icon = Icons.signal_wifi_connected_no_internet_4;
    } else {
      fg = Colors.red;
      label = offlineLabel;
      icon = Icons.wifi_off;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: fg.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (pendingCount > 0) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting manual synchronization...')),
              );
              Provider.of<SyncService>(context, listen: false).syncPendingSubmissions(manualTrigger: true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sync, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    '$pendingCount pending',
                    style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoriesRow(BuildContext context, String languageCode,
      ThemeData theme, AppLocalizations l10n) {
    // Categories with 3D-style emoji/image representations
    final categories = [
      {
        'id': 'paddy',
        'emoji': '🌾',
        'name': l10n.cereals,
      },
      {
        'id': 'wheat',
        'emoji': '🫛',
        'name': l10n.legumes,
      },
      {
        'id': 'fruits',
        'emoji': '🍉',
        'name': l10n.fruits,
      },
      {
        'id': 'vegetables',
        'emoji': '🥦',
        'name': l10n.vegetables,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((category) {
        return _buildCategoryCard(
          context,
          emoji: category['emoji'] as String,
          name: category['name'] as String,
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: theme.cardColor,
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color,
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
    final l10n = AppLocalizations.of(context)!;

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
              category == 'vegetables'
                  ? l10n.selectVegetable
                  : l10n.selectFruit,
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
                    child: Icon(Icons.eco, color: theme.colorScheme.primary),
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

  Widget _buildQuickTips(ThemeData theme, AppLocalizations l10n) {
    final tips = <Map<String, dynamic>>[
      {
        'icon': Icons.wb_sunny_outlined,
        'title': l10n.useGoodLighting,
        'desc': l10n.useGoodLightingDesc,
      },
      {
        'icon': Icons.center_focus_strong,
        'title': l10n.focusOnLeaf,
        'desc': l10n.focusOnLeafDesc,
      },
      {
        'icon': Icons.cleaning_services_outlined,
        'title': l10n.cleanCameraLens,
        'desc': l10n.cleanCameraLensDesc,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickTips,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((t) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
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
                          color: theme.textTheme.bodySmall?.color,
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
