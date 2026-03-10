import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/treatment_step.dart';
import '../services/sync_service.dart';
import '../providers/language_provider.dart';
import '../widgets/voice_button.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../models/diagnosis_result.dart'; // Add for DiseaseSeverity

class TreatmentScreen extends StatefulWidget {
  final String diseaseId;
  final DiseaseSeverity? severity;

  const TreatmentScreen({super.key, required this.diseaseId, this.severity});

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
    final l10n = AppLocalizations.of(context)!;

    String title = l10n.treatmentSteps;
    if (_treatment != null) {
      title = _treatment!.diseaseName;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
          ? _buildLoading(l10n)
          : _error != null
              ? _buildError(l10n)
              : _treatment != null
                  ? _buildTreatment(languageProvider, l10n)
                  : _buildNoTreatment(l10n),
    );
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(l10n.loadingTreatment),
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
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchTreatment,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTreatment(AppLocalizations l10n) {
    return Center(
      child: Text(l10n.noTreatmentAvailable),
    );
  }

  Widget _buildTreatment(
      LanguageProvider languageProvider, AppLocalizations l10n) {
    final treatment = _treatment!;
    final currentSteps =
        _showOrganic ? treatment.organicSteps : treatment.chemicalSteps;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (treatment.rainWarning)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloudy_snowing, color: Colors.blue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.weatherWarning,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.rainWarningDesc,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Header: Disease Name and Overview
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor.withOpacity(0.15),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'disease_title',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      treatment.diseaseName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (treatment.generalAdvice != null)
                  Text(
                    treatment.generalAdvice!,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (widget.severity != null && widget.severity != DiseaseSeverity.unknown) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(widget.severity!),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _getSeverityColor(widget.severity!).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _getLocalizedSeverity(widget.severity!, l10n).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Weather Warning Card
          if (treatment.rainWarning)
            _buildWeatherWarning(treatment, languageProvider, l10n),

          // Mode Toggle (Organic/Chemical)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeToggle(
                      label: l10n.organic,
                      icon: Icons.eco_outlined,
                      isSelected: _showOrganic,
                      onTap: () => setState(() => _showOrganic = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeToggle(
                      label: l10n.chemical,
                      icon: Icons.science_outlined,
                      isSelected: !_showOrganic,
                      onTap: () => setState(() => _showOrganic = false),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Treatment List
          if (currentSteps.isEmpty)
            _buildEmptyState(l10n)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: currentSteps.length,
              itemBuilder: (context, index) {
                return _buildStepCard(currentSteps[index], languageProvider, l10n);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherWarning(Treatment treatment,
      LanguageProvider languageProvider, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_sync_outlined, color: Colors.orange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weatherAlert,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  treatment.weatherCondition ?? l10n.avoidSprayingBeforeRain,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB35A00),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            l10n.noTreatmentStepsAvailable,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(TreatmentStep step, LanguageProvider languageProvider,
      AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isHighPriority = widget.severity == DiseaseSeverity.high && 
        step.safetyLevel != SafetyLevel.safe;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighPriority ? Colors.red.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            leading: _buildStepIndex(step.stepNumber),
            title: Text(
              step.title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            subtitle: Text(
              '${l10n.dosage}: ${step.dosage ?? "As needed"}',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 24),
                    Text(
                      step.description,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    
                    // Detail Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        if (step.timing != null)
                          _buildDetailBadge(Icons.timer_outlined, step.timing!, Colors.blue),
                        _buildDetailBadge(
                          _getSafetyIcon(step.safetyLevel), 
                          step.safetyLevel.name.toUpperCase(), 
                          _getSafetyColor(step.safetyLevel)
                        ),
                      ],
                    ),
                    
                    if (step.ppeRequired.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        l10n.requiredSafetyEquipment.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: step.ppeRequired.map((p) => _buildPPEChip(p)).toList(),
                      ),
                    ],

                    if (step.safetyWarnings.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.gpp_maybe_outlined, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.safetyWarnings.toUpperCase(),
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...step.safetyWarnings.map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(w, style: const TextStyle(fontSize: 13, height: 1.4))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    VoiceButton(
                      text: _buildVoiceText(step, l10n),
                      languageCode: languageProvider.currentLocale.languageCode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndex(int index) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "$index",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPPEChip(String ppe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getPPEIcon(ppe), style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            ppe,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  IconData _getSafetyIcon(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.safe: return Icons.check_circle_outline;
      case SafetyLevel.caution: return Icons.info_outline;
      case SafetyLevel.warning: return Icons.warning_amber_outlined;
      case SafetyLevel.danger: return Icons.gpp_maybe_outlined;
    }
  }

  int get index => 0; // Temp helper for initiallyExpanded

  String _buildVoiceText(TreatmentStep step, AppLocalizations l10n) {
    String text = '${l10n.step} ${step.stepNumber}: ${step.title}. ${step.description}';
    if (step.dosage != null) text += ' ${l10n.dosage}: ${step.dosage}.';
    if (step.timing != null) text += ' ${l10n.timing}: ${step.timing}.';
    return text;
  }

  Color _getSafetyColor(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.safe: return const Color(0xFF4CAF50);
      case SafetyLevel.caution: return const Color(0xFFFF9800);
      case SafetyLevel.warning: return const Color(0xFFE65100);
      case SafetyLevel.danger: return const Color(0xFFF44336);
    }
  }

  String _getPPEIcon(String ppe) {
    if (ppe.toLowerCase().contains('glove')) return '🧤';
    if (ppe.toLowerCase().contains('mask')) return '😷';
    if (ppe.toLowerCase().contains('goggles')) return '🥽';
    if (ppe.toLowerCase().contains('clothing')) return '🥼';
    if (ppe.toLowerCase().contains('boot')) return '🥾';
    return '🛡️';
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
      case DiseaseSeverity.low: return const Color(0xFF4CAF50);
      case DiseaseSeverity.medium: return const Color(0xFFFF9800);
      case DiseaseSeverity.high: return const Color(0xFFF44336);
      case DiseaseSeverity.unknown: return const Color(0xFF9E9E9E);
    }
  }
}
