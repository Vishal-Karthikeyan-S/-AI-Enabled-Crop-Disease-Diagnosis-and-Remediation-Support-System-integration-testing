import 'package:flutter/material.dart';

Widget imageFromPath(
  String path, {
  BoxFit fit = BoxFit.cover,
}) {
  return Image.network(
    path,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    },
  );
}
