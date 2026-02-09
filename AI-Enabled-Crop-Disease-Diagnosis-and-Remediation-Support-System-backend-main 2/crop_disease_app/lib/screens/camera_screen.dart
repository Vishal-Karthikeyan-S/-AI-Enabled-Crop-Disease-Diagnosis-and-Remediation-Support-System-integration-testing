import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/submission.dart';
import '../providers/submission_provider.dart';
import '../providers/connectivity_provider.dart';
import '../l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  /// When true, this screen is used as a tab inside [MainNavigation].
  /// In that case we must NOT pop the Navigator (there is nothing to pop).
  final bool embedded;

  const CameraScreen({super.key, this.embedded = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;

  void _maybePop() {
    if (!mounted) return;
    if (widget.embedded) return;
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    // Don't auto-launch camera, show options instead
  }

  Future<void> _takePhoto() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        await _handleCapturedMedia(photo);
      } else {
        _maybePop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${l10n.error}: ${kIsWeb ? "Camera not available on web. Please use gallery." : e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        _maybePop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _handleCapturedMedia(XFile media) async {
    final submissionProvider =
        Provider.of<SubmissionProvider>(context, listen: false);
    final connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      // Create submission
      final submission = Submission(
        id: const Uuid().v4(),
        mediaPath: media.path,
        mediaType: MediaType.image,
        createdAt: DateTime.now(),
        status: SubmissionStatus.saved,
      );

      // Save to local storage
      await submissionProvider.addSubmission(submission);

      // On Web, trigger upload immediately since we don't have background sync
      if (kIsWeb && connectivityProvider.isOnline) {
         await submissionProvider.uploadSubmission(submission);
      }

      if (mounted) {
        // Show appropriate message
        final message = connectivityProvider.isOnline
            ? l10n.submittedOnline
            : l10n.savedOffline;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                connectivityProvider.isOnline ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back (only when opened as a route, not when embedded as a tab)
        _maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _maybePop();
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        await _handleCapturedMedia(photo);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _maybePop,
              ),
            ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCapturing) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Processing...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              Icon(Icons.camera_alt,
                  size: 100, color: theme.colorScheme.primary),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
