import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/submission.dart';
import '../providers/submission_provider.dart';
import '../utils/constants.dart';
import '../utils/image_from_path.dart';

class UploadedImagesScreen extends StatelessWidget {
  const UploadedImagesScreen({super.key});

  List<Submission> _uploaded(List<Submission> all) {
    return all
        .where(
          (s) =>
              s.mediaType == MediaType.image &&
              (s.uploadedAt != null ||
                  s.status == SubmissionStatus.submitted ||
                  s.status == SubmissionStatus.diagnosed),
        )
        .toList();
  }

  Widget _image(String path) {
    return imageFromPath(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubmissionProvider>(context);
    final items = _uploaded(provider.submissions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Images'),
        actions: [
          IconButton(
            onPressed: provider.isLoading ? null : () => provider.loadSubmissions(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text('Error: ${provider.error}'))
              : items.isEmpty
                  ? const Center(child: Text('No uploaded images yet'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final s = items[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Material(
                            color: Colors.grey.shade200,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppConstants.routeResults,
                                  arguments: s.id,
                                );
                              },
                              child: _image(s.mediaPath),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
