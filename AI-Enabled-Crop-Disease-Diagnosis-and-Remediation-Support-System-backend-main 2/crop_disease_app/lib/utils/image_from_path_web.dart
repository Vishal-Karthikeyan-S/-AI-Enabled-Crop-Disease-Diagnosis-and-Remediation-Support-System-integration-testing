import 'package:flutter/widgets.dart';

Widget imageFromPath(
  String path, {
  BoxFit fit = BoxFit.cover,
}) {
  if (path.startsWith('http')) {
    return Image.network(path, fit: fit);
  }
  return Image.network(path, fit: fit); // Web always treats paths as URLs/Assets
}
