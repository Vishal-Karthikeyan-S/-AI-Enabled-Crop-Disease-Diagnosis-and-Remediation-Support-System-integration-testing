import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diagnosis_result.dart';
import '../models/submission.dart';
import '../services/sync_service.dart';
import '../providers/language_provider.dart';
import '../providers/submission_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/voice_button.dart';
import '../utils/constants.dart';
import '../utils/image_from_path.dart';

class ResultsScreen extends StatefulWidget {
  final String submissionId;

  const ResultsScreen({super.key, required this.submissionId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Timer? _pollingTimer;
  DiagnosisResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchResults() async {
    final syncService = Provider.of<SyncService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await syncService.fetchDiagnosisResult(widget.submissionId);
      
      if (mounted) {
        if (result == null) {
          // Diagnosis is not ready yet (Processing or Pending Sync)
          _setupPolling();
        } else {
          setState(() {
            _result = result;
            _isLoading = false;
          });
        }
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

  void _setupPolling() {
    _pollingTimer?.cancel();
    // Poll every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
       if (!mounted) {
         timer.cancel();
         return;
       }

       final syncService = Provider.of<SyncService>(context, listen: false);
       final result = await syncService.fetchDiagnosisResult(widget.submissionId);

       if (result != null && mounted) {
         timer.cancel();
         setState(() {
           _result = result;
           _isLoading = false;
         });
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnosisResults),
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
          ? _buildLoading(l10n)
          : _error != null
              ? _buildError(l10n)
              : _result != null
                  ? _buildResults(l10n, languageProvider)
                  : _buildNoResults(l10n),
    );
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            l10n.analysingImage,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '${l10n.error}: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchResults,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n) {
    final submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
    final submission = submissionProvider.getSubmissionById(widget.submissionId);
    
    bool isSyncing = submission?.status == SubmissionStatus.uploading;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSyncing ? Icons.cloud_upload_outlined : Icons.cloud_sync_outlined, 
              size: 80, 
              color: Colors.orange
            ),
            const SizedBox(height: 24),
            Text(
              isSyncing ? l10n.uploadingPhoto : l10n.analysisPending,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isSyncing 
                ? l10n.uploadingPhotoDesc
                : l10n.analysisPendingDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (!isSyncing)
              ElevatedButton(
                onPressed: _fetchResults,
                child: Text(l10n.checkAgain),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.backToHome),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(AppLocalizations l10n, LanguageProvider languageProvider) {
    final result = _result!;
    final theme = Theme.of(context);
    final isUnknown = result.diseaseName == 'Unknown' || result.isUnknown;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with Image
          Stack(
            children: [
              Hero(
                tag: 'image_${widget.submissionId}',
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.green[100],
                  child: const Center(
                    child: Icon(Icons.eco, size: 80, color: Colors.green),
                  ),
                ),
              ),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Result Card
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (isUnknown) ...[
                  const Icon(Icons.help_outline, size: 80, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    l10n.unknownCondition,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.remediationInconclusive,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ] else ...[
                  Text(
                    result.diseaseName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBadge(
                        l10n.confidence,
                        '${result.confidence.toStringAsFixed(1)}%',
                        Icons.analytics_outlined,
                        theme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoBadge(
                        l10n.status,
                        l10n.diagnosed,
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoBadge(
                    'Severity',
                    _getLocalizedSeverity(result.severity, l10n),
                    Icons.warning_amber_rounded,
                    _getSeverityColor(result.severity),
                  ),
                ],

                const SizedBox(height: 32),
                
                // Voice / Speaker Section
                VoiceButton(
                  text: _buildVoiceText(result, l10n),
                  languageCode: languageProvider.currentLocale.languageCode,
                ),

                const SizedBox(height: 40),

                // Actions
                if (!isUnknown)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppConstants.routeTreatment,
                          arguments: {
                            'diseaseId': result.diseaseName,
                            'severity': result.severity,
                          },
                        );
                      },
                      icon: const Icon(Icons.list_alt_outlined),
                      label: Text(l10n.viewActionPlan),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppConstants.routeCamera),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.tryNewCapture),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppConstants.routeHome,
                    (route) => false,
                  ),
                  child: Text(
                    l10n.returningHome,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _buildVoiceText(DiagnosisResult result, AppLocalizations l10n) {
    if (result.diseaseName == 'Unknown' || result.isUnknown) {
      return l10n.remediationInconclusive;
    }
    return l10n.remediationFound(result.diseaseName, _getLocalizedSeverity(result.severity, l10n));
  }

  String _getLocalizedSeverity(DiseaseSeverity severity, AppLocalizations l10n) {
    switch (severity) {
      case DiseaseSeverity.low: return l10n.lowSeverity;
      case DiseaseSeverity.medium: return l10n.mediumSeverity;
      case DiseaseSeverity.high: return l10n.highSeverity;
      case DiseaseSeverity.unknown: return l10n.unknownSeverity;
    }
  }

  Color _getSeverityColor(DiseaseSeverity severity) {
    switch (severity) {
      case DiseaseSeverity.low: return Colors.green;
      case DiseaseSeverity.medium: return Colors.orange;
      case DiseaseSeverity.high: return Colors.red;
      case DiseaseSeverity.unknown: return Colors.grey;
    }
  }
}
