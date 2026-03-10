import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crop_model.dart';
import '../providers/language_provider.dart';
import '../services/tts_service.dart';

class CropDetailScreen extends StatelessWidget {
  final CropModel crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLocale.languageCode;
    final ttsService = Provider.of<TtsService>(context, listen: false);

    final cropName = crop.nameTranslations[currentLang] ?? crop.name;
    final careInstructions = crop.careInstructions[currentLang] ?? '';
    final waterReq = crop.waterRequirements[currentLang] ?? '';
    final growthDuration = crop.growthDuration[currentLang] ?? '';
    final diseases = crop.commonDiseases[currentLang] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(cropName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Care Instructions
            _buildSection(
              context,
              title: 'Care Instructions',
              content: careInstructions,
              icon: Icons.agriculture,
              onSpeak: () =>
                  ttsService.speak(careInstructions, languageCode: currentLang),
            ),
            const SizedBox(height: 16),

            // Water Requirements
            _buildSection(
              context,
              title: 'Water Requirements',
              content: waterReq,
              icon: Icons.water_drop,
              onSpeak: () =>
                  ttsService.speak(waterReq, languageCode: currentLang),
            ),
            const SizedBox(height: 16),

            // Growth Duration
            _buildSection(
              context,
              title: 'Growth Duration',
              content: growthDuration,
              icon: Icons.schedule,
              onSpeak: () =>
                  ttsService.speak(growthDuration, languageCode: currentLang),
            ),
            const SizedBox(height: 16),

            // Diseases
            Text(
              'Common Diseases',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...diseases.map((disease) => _buildDiseaseCard(
                  context,
                  disease,
                  currentLang,
                  ttsService,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required VoidCallback onSpeak,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: onSpeak,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(
    BuildContext context,
    Disease disease,
    String languageCode,
    TtsService ttsService,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(Icons.bug_report, color: theme.colorScheme.error),
        title: Text(
          disease.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(disease.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Symptoms',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...disease.symptoms.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text('• $s'),
                    )),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remedies',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () {
                        final remediesText = disease.remedies.join('. ');
                        ttsService.speak(remediesText,
                            languageCode: languageCode);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...disease.remedies.map((r) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check,
                              color: theme.colorScheme.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
