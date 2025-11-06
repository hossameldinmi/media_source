import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:media_source/src/extensions/file_extensions.dart';

/// Test AssetBundle that loads from actual test files
class TestFileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // Handle both patterns:
    // - "test/assets/..." from Fixture.sample_*.file.path
    // - "assets/..." from hardcoded string paths
    String filePath = key;
    if (key.startsWith('assets/') && !key.startsWith('test/assets/')) {
      filePath = 'test/$key';
    }

    final file = XFile(filePath);

    if (!await file.exists()) {
      throw Exception('Asset not found: $key');
    }

    final bytes = await file.readAsBytes();
    return ByteData.sublistView(bytes);
  }
}
