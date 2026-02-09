import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/submission.dart';
import '../providers/submission_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/voice_button.dart';
import '../utils/constants.dart';

class PreviewScreen extends StatelessWidget {
  final String imagePath;
  final Submission submission;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final submissionProvider =
        Provider.of<SubmissionProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(l10n.submit),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            child: Center(
              child: kIsWeb
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.white54,
                        );
                      },
                    )
                  : Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                    ),
            ),
          ),

          // Voice Instructions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: VoiceButton(
              text: l10n.voiceInstructionPreview,
              languageCode: languageProvider.currentLocale.languageCode,
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Retake Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Delete this submission and go back
                      submissionProvider.deleteSubmission(submission.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh, size: 28),
                    label: Text(
                      l10n.retake,
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Submit Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleSubmit(context, submissionProvider,
                        connectivityProvider, l10n),
                    icon: const Icon(Icons.check_circle, size: 28),
                    label: Text(
                      l10n.submit,
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<void> _handleSubmit(
    BuildContext context,
    SubmissionProvider submissionProvider,
    ConnectivityProvider connectivityProvider,
    AppLocalizations l10n,
  ) async {
    // Update submission status
    final updatedSubmission = submission.copyWith(
      status: connectivityProvider.isOnline
          ? SubmissionStatus.uploading
          : SubmissionStatus.saved,
    );
    submissionProvider.updateSubmission(updatedSubmission);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          connectivityProvider.isOnline
              ? l10n.submittedSuccessfully
              : l10n.savedOffline,
        ),
        backgroundColor:
            connectivityProvider.isOnline ? Colors.green : Colors.orange,
      ),
    );

    if (connectivityProvider.isOnline) {
      // Trigger actual upload
      await submissionProvider.uploadSubmission(updatedSubmission);
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppConstants.routeResults,
          arguments: submission.id,
        );
      }
    } else {
      // Offline mode handling
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pop(context); // Go back home if offline
        }
      });
    }
  }
}
