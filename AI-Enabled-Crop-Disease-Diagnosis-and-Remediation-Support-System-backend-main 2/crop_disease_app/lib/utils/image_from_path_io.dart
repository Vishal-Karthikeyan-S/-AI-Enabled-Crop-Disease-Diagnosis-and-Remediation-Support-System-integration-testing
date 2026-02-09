import 'dart:io';

import 'package:flutter/widgets.dart';

Widget imageFromPath(
  String path, {
  BoxFit fit = BoxFit.cover,
}) {
  if (path.startsWith('http')) {
    return Image.network(path, fit: fit);
  }
  return Image.file(File(path), fit: fit);
}
