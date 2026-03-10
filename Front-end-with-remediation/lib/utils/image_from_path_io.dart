import 'dart:io';

import 'package:flutter/widgets.dart';

Widget imageFromPath(
  String path, {
  BoxFit fit = BoxFit.cover,
}) {
  return Image.file(File(path), fit: fit);
}
