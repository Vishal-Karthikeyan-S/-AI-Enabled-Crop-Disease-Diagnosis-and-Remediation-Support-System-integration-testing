import 'package:flutter/widgets.dart';

import 'image_from_path_web.dart'
    if (dart.library.io) 'image_from_path_io.dart' as impl;

Widget imageFromPath(
  String path, {
  BoxFit fit = BoxFit.cover,
}) {
  return impl.imageFromPath(path, fit: fit);
}
