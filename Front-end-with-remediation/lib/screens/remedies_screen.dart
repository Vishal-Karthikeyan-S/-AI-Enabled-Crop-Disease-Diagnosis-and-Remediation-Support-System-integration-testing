import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/crop_data.dart';
import '../l10n/app_localizations.dart';
import '../models/crop_model.dart';
import '../providers/language_provider.dart';
import '../services/tts_service.dart';

class RemediesScreen extends StatefulWidget {
  const RemediesScreen({super.key});

  @override
  State<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends State<RemediesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLocale.languageCode;
    final l10n = AppLocalizations.of(context)!;

    // Collect all diseases from all crops
    final List<DiseaseInfo> allDiseases = [];
    for (final crop in CropData.crops) {
      final diseases = crop.commonDiseases[currentLang] ?? [];
      for (final disease in diseases) {
        allDiseases.add(
          DiseaseInfo(
            cropName: crop.nameTranslations[currentLang] ?? crop.name,
            disease: disease,
            cropId: crop.id,
          ),
        );
      }
    }

    final filtered = allDiseases.where((d) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return d.cropName.toLowerCase().contains(q) ||
          d.disease.name.toLowerCase().contains(q) ||
          d.disease.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.remedies),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchCropDisease,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(l10n.noRemediesFound))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _DiseaseCard(
                        diseaseInfo: filtered[index],
                        languageCode: currentLang,
                        accent: theme.colorScheme.primary,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DiseaseInfo {
  final String cropName;
  final Disease disease;
  final String cropId;

  DiseaseInfo({
    required this.cropName,
    required this.disease,
    required this.cropId,
  });
}

class _DiseaseCard extends StatelessWidget {
  final DiseaseInfo diseaseInfo;
  final String languageCode;
  final Color accent;

  const _DiseaseCard({
    required this.diseaseInfo,
    required this.languageCode,
    required this.accent,
  });

  String _cropEmoji(String cropId) {
    switch (cropId) {
      case 'paddy':
        return '🌾';
      case 'wheat':
        return '🌾';
      case 'tomato':
        return '🍅';
      case 'potato':
        return '🥔';
      case 'mango':
        return '🥭';
      case 'banana':
        return '🍌';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ttsService = Provider.of<TtsService>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final emoji = _cropEmoji(diseaseInfo.cropId);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
        title: Text(
          diseaseInfo.disease.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          diseaseInfo.cropName,
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          tooltip: l10n.listen,
          icon: Icon(Icons.volume_up, color: accent),
          onPressed: () {
            final text =
                '${diseaseInfo.disease.name}. ${diseaseInfo.disease.description}. ${l10n.remedies}: ${diseaseInfo.disease.remedies.join('. ')}';
            ttsService.speak(text, languageCode: languageCode);
          },
        ),
        children: [
          // "Image" header (emoji + icon)
          Container(
            height: 110,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Text(emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    diseaseInfo.disease.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.pest_control, color: accent, size: 40),
                const SizedBox(width: 16),
              ],
            ),
          ),
          _sectionTitle(l10n.symptoms, accent),
          const SizedBox(height: 8),
          ...diseaseInfo.disease.symptoms.map(
            (s) => _bullet(theme, s, accent),
          ),
          const SizedBox(height: 14),
          _sectionTitle(l10n.remedies, accent),
          const SizedBox(height: 8),
          ...diseaseInfo.disease.remedies.map(
            (r) => _check(theme, r, accent),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color accent) {
    return Text(
      title,
      style: TextStyle(
        color: accent,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    );
  }

  Widget _bullet(ThemeData theme, String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _check(ThemeData theme, String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
