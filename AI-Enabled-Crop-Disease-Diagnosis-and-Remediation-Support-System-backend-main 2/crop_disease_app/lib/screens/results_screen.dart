import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diagnosis_result.dart';
import '../services/sync_service.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/voice_button.dart';
import '../utils/constants.dart';
import '../providers/submission_provider.dart';

class ResultsScreen extends StatefulWidget {
  final String submissionId;

  const ResultsScreen({super.key, required this.submissionId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  DiagnosisResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    final syncService = Provider.of<SyncService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<SubmissionProvider>(context, listen: false);
      final submission = provider.getSubmissionById(widget.submissionId);
      final diagnosisId = submission?.diagnosisId ?? widget.submissionId;

      final result =
          await syncService.fetchDiagnosisResult(diagnosisId);
      if (mounted) {
        setState(() {
          _result = result;
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
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppConstants.routeHome,
            (route) => false,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _result != null
                  ? _buildResults(l10n, languageProvider)
                  : _buildNoResults(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Analyzing your crop image...',
            style: TextStyle(fontSize: 16),
          ),
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
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchResults,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return const Center(
      child: Text('No results available'),
    );
  }

  Widget _buildResults(
      AppLocalizations l10n, LanguageProvider languageProvider) {
    final result = _result!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Disease Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Disease Icon (placeholder)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                          _getSeverityColor(result.severity).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pest_control,
                      size: 60,
                      color: _getSeverityColor(result.severity),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Disease Name
                  Text(
                    result.isUnknown ? 'Unknown Disease' : result.diseaseName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Severity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(result.severity),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          result.severityEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Severity: ${result.severity.name.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confidence Meter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Confidence',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(result.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: result.confidence >= 0.7
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: result.confidence,
                          minHeight: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            result.confidence >= 0.7
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (result.description != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      result.description!,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Voice Instructions
          VoiceButton(
            text: result.isUnknown
                ? 'The diagnosis confidence is low. Please retake a clearer photo for better results.'
                : 'Disease identified as ${result.diseaseName} with ${result.severity.name} severity. Tap view treatment for remediation steps.',
            languageCode: languageProvider.currentLocale.languageCode,
          ),

          const SizedBox(height: 24),

          // View Treatment Button (only if not unknown)
          if (!result.isUnknown)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeTreatment,
                  arguments: result.id,
                );
              },
              icon: const Icon(Icons.medical_services, size: 28),
              label: const Text(
                'View Treatment Steps',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            // Retake Button for unknown results
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.routeHome,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.camera_alt, size: 28),
              label: const Text(
                'Retake Photo',
                style: TextStyle(fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSeverityColor(DiseaseSeverity severity) {
    switch (severity) {
      case DiseaseSeverity.low:
        return Colors.green;
      case DiseaseSeverity.medium:
        return Colors.orange;
      case DiseaseSeverity.high:
        return Colors.red;
      case DiseaseSeverity.unknown:
        return Colors.grey;
    }
  }
}
