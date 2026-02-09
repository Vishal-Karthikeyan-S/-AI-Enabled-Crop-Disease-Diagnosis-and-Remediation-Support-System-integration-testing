import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/treatment_step.dart';
import '../services/sync_service.dart';
import '../providers/language_provider.dart';
import '../widgets/voice_button.dart';
import '../utils/constants.dart';

class TreatmentScreen extends StatefulWidget {
  final String diseaseId;

  const TreatmentScreen({super.key, required this.diseaseId});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  Treatment? _treatment;
  bool _isLoading = true;
  String? _error;
  bool _showOrganic = true; // Toggle between organic and chemical

  @override
  void initState() {
    super.initState();
    _fetchTreatment();
  }

  Future<void> _fetchTreatment() async {
    final syncService = Provider.of<SyncService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final treatment = await syncService.fetchTreatment(widget.diseaseId);
      if (mounted) {
        setState(() {
          _treatment = treatment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Steps'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppConstants.routeHome,
              (route) => false,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _treatment != null
                  ? _buildTreatment(languageProvider)
                  : _buildNoTreatment(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Loading treatment recommendations...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchTreatment,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTreatment() {
    return const Center(
      child: Text('No treatment information available'),
    );
  }

  Widget _buildTreatment(LanguageProvider languageProvider) {
    final treatment = _treatment!;
    final currentSteps =
        _showOrganic ? treatment.organicSteps : treatment.chemicalSteps;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Disease Name Header
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              children: [
                Text(
                  treatment.diseaseName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (treatment.generalAdvice != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    treatment.generalAdvice!,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          // Weather Warning
          if (treatment.rainWarning)
            _buildWeatherWarning(treatment, languageProvider),

          // Treatment Type Toggle
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    label: '🌱 Organic',
                    isSelected: _showOrganic,
                    onTap: () => setState(() => _showOrganic = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton(
                    label: '⚗️ Chemical',
                    isSelected: !_showOrganic,
                    onTap: () => setState(() => _showOrganic = false),
                  ),
                ),
              ],
            ),
          ),

          // Treatment Steps
          if (currentSteps.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'No treatment steps available for this option.',
                textAlign: TextAlign.center,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: currentSteps
                    .map((step) => _buildStepCard(step, languageProvider))
                    .toList(),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWeatherWarning(
      Treatment treatment, LanguageProvider languageProvider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌧️ Weather Alert',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  treatment.weatherCondition ?? 'Avoid spraying before rain',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(TreatmentStep step, LanguageProvider languageProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getSafetyColor(step.safetyLevel),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Number and Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
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
                      Row(
                        children: [
                          Text(
                            step.typeEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            step.safetyEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              step.description,
              style: const TextStyle(fontSize: 14),
            ),

            // Dosage
            if (step.dosage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.medication, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Dosage: ${step.dosage}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],

            // Timing
            if (step.timing != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Timing: ${step.timing}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],

            // PPE Required
            if (step.ppeRequired.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: step.ppeRequired.map((ppe) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getPPEIcon(ppe),
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          ppe,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            // Safety Warnings
            if (step.safetyWarnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Safety Warnings:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...step.safetyWarnings.map((warning) => Padding(
                          padding: const EdgeInsets.only(left: 28, bottom: 4),
                          child: Text(
                            '• $warning',
                            style: const TextStyle(fontSize: 13),
                          ),
                        )),
                  ],
                ),
              ),
            ],

            // Voice Button
            const SizedBox(height: 12),
            VoiceButton(
              text: _buildVoiceText(step),
              languageCode: languageProvider.currentLocale.languageCode,
            ),
          ],
        ),
      ),
    );
  }

  String _buildVoiceText(TreatmentStep step) {
    String text = 'Step ${step.stepNumber}: ${step.title}. ${step.description}';

    if (step.dosage != null) {
      text += ' Dosage: ${step.dosage}.';
    }

    if (step.timing != null) {
      text += ' Timing: ${step.timing}.';
    }

    if (step.ppeRequired.isNotEmpty) {
      text += ' Required safety equipment: ${step.ppeRequired.join(", ")}.';
    }

    if (step.safetyWarnings.isNotEmpty) {
      text += ' Warning: ${step.safetyWarnings.join(". ")}.';
    }

    return text;
  }

  Color _getSafetyColor(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.safe:
        return Colors.green;
      case SafetyLevel.caution:
        return Colors.orange;
      case SafetyLevel.warning:
        return Colors.deepOrange;
      case SafetyLevel.danger:
        return Colors.red;
    }
  }

  String _getPPEIcon(String ppe) {
    if (ppe.toLowerCase().contains('glove')) return '🧤';
    if (ppe.toLowerCase().contains('mask')) return '😷';
    if (ppe.toLowerCase().contains('goggles') ||
        ppe.toLowerCase().contains('eye')) return '🥽';
    if (ppe.toLowerCase().contains('clothing') ||
        ppe.toLowerCase().contains('suit')) return '🥼';
    if (ppe.toLowerCase().contains('boot')) return '🥾';
    return '🛡️';
  }
}
