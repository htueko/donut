import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Copies the app's `assets/` into the test asset cache so widget tests use the
/// same seed data and artwork as the shipped app. The default test asset bundle
/// only registers files listed in `pubspec.yaml` (`assets/seed/`), so seed
/// images must be copied in for `Image.asset` to resolve them.
Future<void> useDiskAssets() async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  await binding.runAsync(() async {
    final root = Directory.current.path.endsWith('/test')
        ? Directory.current.parent.path
        : Directory.current.path;
    final images = Directory('$root/assets/seed/images');
    final target = Directory('$root/build/unit_test_assets/assets/seed/images');
    await target.create(recursive: true);
    await for (final entity in images.list()) {
      if (entity is! File) {
        continue;
      }
      final bytes = await entity.readAsBytes();
      await File('${target.path}/${entity.uri.pathSegments.last}')
          .writeAsBytes(bytes);
    }
    PaintingBinding.instance.imageCache.clear();
  });
}
