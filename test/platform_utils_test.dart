import 'package:flutter_test/flutter_test.dart';
import 'package:media_source/media_source.dart';

const tempDir = 'test/assets/platform_utils_saved_to';

void main() {
  group('PlatformUtilsFacade.createDirectoryIfNotExists', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('delegates to ensureParentDirectoryExists', () async {
      const filePath = '$tempDir/nested/file.txt';

      // ignore: deprecated_member_use_from_same_package
      await PlatformUtils.instance.createDirectoryIfNotExists(filePath);

      expect(await PlatformUtils.instance.directoryExists('$tempDir/nested'), isTrue);
    });
  });
}
