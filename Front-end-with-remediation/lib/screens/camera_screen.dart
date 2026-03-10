import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/submission.dart';
import '../providers/submission_provider.dart';
import '../providers/connectivity_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

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
                '${l10n.error}: ${kIsWeb ? "Camera not available on web." : e.toString()}'),
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

  Future<void> _takeVideo() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 5),
      );

      if (video != null && mounted) {
        await _handleCapturedMedia(video, type: MediaType.video);
      } else {
        _maybePop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${l10n.error}: ${kIsWeb ? "Camera not available on web." : e.toString()}'),
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

  Future<void> _handleCapturedMedia(XFile media, {MediaType type = MediaType.image}) async {
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
        mediaType: type,
        createdAt: DateTime.now(),
        status: SubmissionStatus.saved,
      );

      // Save to local storage
      await submissionProvider.addSubmission(submission);

      if (mounted) {
        // Haptic feedback
        try {
          // ignore: deprecated_member_use
          // await Vibration.vibrate(duration: 100); or use simpler HapticFeedback
        } catch (_) {}

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

        // Navigate to the results screen with the submission ID
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppConstants.routeResults,
              arguments: submission.id,
            );
          }
        });
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
      } else {
        if (mounted) {
          setState(() {
            _isCapturing = false;
          });
        }
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
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCapturing) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.processing,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ] else ...[
                Text(
                  l10n.capturePhoto,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCaptureOption(
                      icon: Icons.camera_alt,
                      label: l10n.camera,
                      onTap: _takePhoto,
                      theme: theme,
                    ),
                    _buildCaptureOption(
                      icon: Icons.videocam,
                      label: 'Video',
                      onTap: _takeVideo,
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: Text(l10n.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
