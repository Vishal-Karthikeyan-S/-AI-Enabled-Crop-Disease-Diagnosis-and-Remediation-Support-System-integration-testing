import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/submission.dart';
import '../providers/submission_provider.dart';
import '../utils/constants.dart';
import '../utils/image_from_path.dart';
import 'uploaded_images_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  String _statusLabel(SubmissionStatus status, AppLocalizations l10n) {
    switch (status) {
      case SubmissionStatus.saved:
        return l10n.statusSaved;
      case SubmissionStatus.uploading:
        return l10n.statusUploading;
      case SubmissionStatus.submitted:
        return l10n.uploaded;
      case SubmissionStatus.failed:
        return l10n.failed;
      case SubmissionStatus.diagnosed:
        return l10n.diagnosed;
    }
  }

  Color _statusColor(BuildContext context, SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.saved:
        return Colors.orange;
      case SubmissionStatus.uploading:
        return Theme.of(context).colorScheme.primary;
      case SubmissionStatus.submitted:
        return Colors.blue;
      case SubmissionStatus.failed:
        return Theme.of(context).colorScheme.error;
      case SubmissionStatus.diagnosed:
        return Colors.green;
    }
  }

  Widget _thumb(String path) {
    final borderRadius = BorderRadius.circular(12);

    final img = imageFromPath(path, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: 56,
        height: 56,
        child: ColoredBox(
          color: Colors.grey.shade200,
          child: img,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubmissionProvider>(context);
    final submissions = provider.submissions;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadedImagesScreen()),
              );
            },
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: l10n.uploadedImages,
          ),
          IconButton(
            onPressed:
                provider.isLoading ? null : () => provider.loadSubmissions(),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text('${l10n.error}: ${provider.error}'))
              : submissions.isEmpty
                  ? Center(child: Text(l10n.noHistoryYet))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      itemCount: submissions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final s = submissions[index];
                        final statusColor = _statusColor(context, s.status);
                        final theme = Theme.of(context);

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppConstants.routeResults,
                                  arguments: s.id,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: 'thumb_${s.id}',
                                      child: _thumb(s.mediaPath),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatDateTime(s.createdAt),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _statusLabel(s.status, l10n).toUpperCase(),
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 10,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.withOpacity(0.5)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
