import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:media_source/src/sources/asset_media_source.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/extensions/file_extensions.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'assets/fixture.dart';

const tempDir = 'test/assets/saved_to';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bundle = TestFileAssetBundle();

  group('AssetMediaSource.loadAsset', () {
    test('should load asset from custom bundle', () async {
      final asset = Fixture.sample_image;
      final bytes = await AssetMediaSource.loadAsset(asset.file.path, bundle);

      expect(bytes, await asset.file.readAsBytes());
      expect(bytes.length, asset.size.inBytes);
    });
  });

  group('VideoAssetMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'test_video.mp4',
        duration: asset.duration,
        mimeType: 'video/mp4',
      );

      expect(video.assetPath, asset.file.path);
      expect(video.name, 'test_video.mp4');
      expect(video.metadata.duration, asset.duration);
      expect(video.mimeType, 'video/mp4');
      expect(video.size, asset.size);
      expect(video.bundle, bundle);
    });

    test('should create with custom bundle', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      expect(video.bundle, bundle);
      expect(video.size, asset.size);
    });

    test('should create with provided size to avoid loading', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        size: asset.size,
      );

      expect(video.size, asset.size);
    });

    test('should auto-detect MIME type from path', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(video.mimeType, asset.mimeType);
    });

    test('should use default name from asset path', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(video.name, 'sample_video.mp4');
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_video;
      const duration2 = Duration(seconds: 20);

      final video1 = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );
      final video2 = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );
      final video3 = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: duration2,
      );

      expect(video1, video2);
      expect(video1, isNot(video3));
    });

    test('should include assetPath and bundle in props', () async {
      final asset1 = Fixture.sample_video;
      final asset2 = Fixture.sample_audio;

      final video1 = await VideoAssetMedia.load(asset1.file.path, bundle: bundle);
      final video2 = await VideoAssetMedia.load(asset2.file.path, bundle: bundle);

      expect(video1.props.contains(video1.assetPath), isTrue);
      expect(video1.props.contains(video1.bundle), isTrue);
      expect(video1, isNot(video2)); // Different paths
    });
  });

  group('VideoAssetMedia.saveTo', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save to file system', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final filePath = '$tempDir/saved_video.mp4';
      final savedFile = await video.saveTo(filePath);

      expect(savedFile, isA<VideoFileMedia>());
      expect(savedFile.name, video.name);
      expect(savedFile.metadata.duration, asset.duration);
      expect(savedFile.mimeType, video.mimeType);
      expect(savedFile.size, video.size);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should preserve custom properties when saving', () async {
      final asset = Fixture.sample_video;
      const customName = 'custom_video_name.mp4';

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: customName,
        duration: asset.duration,
        mimeType: 'video/custom',
      );

      final filePath = '$tempDir/custom_video.mp4';
      final savedFile = await video.saveTo(filePath);

      expect(savedFile.name, customName);
      expect(savedFile.metadata.duration, asset.duration);
      expect(savedFile.mimeType, 'video/custom');
    });
  });

  group('VideoAssetMedia.saveToFolder', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save to folder with original name', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(asset.file.path, bundle: bundle);

      final savedFile = await video.saveToFolder(tempDir);

      expect(savedFile, isA<VideoFileMedia>());
      expect(savedFile.file.path, '$tempDir/${video.name}');
      expect(await savedFile.file.exists(), isTrue);
    });
  });

  group('VideoAssetMedia.convertToMemory', () {
    test('should convert to memory representation', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await video.convertToMemory();

      expect(memoryMedia, isA<VideoMemoryMedia>());
      expect(memoryMedia.name, video.name);
      expect(memoryMedia.metadata.duration, asset.duration);
      expect(memoryMedia.mimeType, video.mimeType);
      expect(memoryMedia.size, video.size);
      expect(memoryMedia.bytes.length, video.size!.inBytes);
    });
  });

  group('AudioAssetMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_audio;

      final audio = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'test_audio.mp3',
        duration: asset.duration,
        mimeType: 'audio/mpeg',
      );

      expect(audio.assetPath, asset.file.path);
      expect(audio.name, 'test_audio.mp3');
      expect(audio.metadata.duration, asset.duration);
      expect(audio.mimeType, 'audio/mpeg');
      expect(audio.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_audio;

      final audio1 = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );
      final audio2 = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );
      final audio3 = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'different_name.mp3',
        duration: asset.duration,
      );

      expect(audio1, audio2);
      expect(audio1, isNot(audio3));
    });
  });

  group('AudioAssetMedia.saveTo', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save to file system', () async {
      final asset = Fixture.sample_audio;

      final audio = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final filePath = '$tempDir/saved_audio.mp3';
      final savedFile = await audio.saveTo(filePath);

      expect(savedFile, isA<AudioFileMedia>());
      expect(savedFile.name, audio.name);
      expect(savedFile.metadata.duration, asset.duration);
      expect(savedFile.mimeType, audio.mimeType);
      expect(savedFile.size, audio.size);
      expect(await savedFile.file.exists(), isTrue);
    });
  });

  group('AudioAssetMedia.convertToMemory', () {
    test('should convert to memory representation', () async {
      final asset = Fixture.sample_audio;

      final audio = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await audio.convertToMemory();

      expect(memoryMedia, isA<AudioMemoryMedia>());
      expect(memoryMedia.name, audio.name);
      expect(memoryMedia.metadata.duration, asset.duration);
      expect(memoryMedia.mimeType, audio.mimeType);
      expect(memoryMedia.size, audio.size);
    });
  });

  group('ImageAssetMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_image;

      final image = await ImageAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'test_image.jpg',
        mimeType: asset.mimeType,
      );

      expect(image.assetPath, asset.file.path);
      expect(image.name, 'test_image.jpg');
      expect(image.mimeType, asset.mimeType);
      expect(image.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_image;

      final image1 = await ImageAssetMedia.load(asset.file.path, bundle: bundle);
      final image2 = await ImageAssetMedia.load(asset.file.path, bundle: bundle);
      final image3 = await ImageAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'different.jpg',
      );

      expect(image1, image2);
      expect(image1, isNot(image3));
    });

    test('should auto-detect MIME type', () async {
      final asset = Fixture.sample_image;

      final image = await ImageAssetMedia.load(asset.file.path, bundle: bundle);

      expect(image.mimeType, asset.mimeType);
    });
  });

  group('ImageAssetMedia.saveTo', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save to file system', () async {
      final asset = Fixture.sample_image;

      final image = await ImageAssetMedia.load(asset.file.path, bundle: bundle);

      final filePath = '$tempDir/saved_image.jpg';
      final savedFile = await image.saveTo(filePath);

      expect(savedFile, isA<ImageFileMedia>());
      expect(savedFile.name, image.name);
      expect(savedFile.mimeType, image.mimeType);
      expect(savedFile.size, image.size);
      expect(await savedFile.file.exists(), isTrue);
    });
  });

  group('ImageAssetMedia.convertToMemory', () {
    test('should convert to memory representation', () async {
      final asset = Fixture.sample_image;

      final image = await ImageAssetMedia.load(asset.file.path, bundle: bundle);

      final memoryMedia = await image.convertToMemory();

      expect(memoryMedia, isA<ImageMemoryMedia>());
      expect(memoryMedia.name, image.name);
      expect(memoryMedia.mimeType, image.mimeType);
      expect(memoryMedia.size, image.size);
    });
  });

  group('DocumentAssetMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_doc;

      final doc = await DocumentAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'test_doc.pdf',
        mimeType: asset.mimeType,
      );

      expect(doc.assetPath, asset.file.path);
      expect(doc.name, 'test_doc.pdf');
      expect(doc.mimeType, asset.mimeType);
      expect(doc.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_doc;

      final doc1 = await DocumentAssetMedia.load(asset.file.path, bundle: bundle);
      final doc2 = await DocumentAssetMedia.load(asset.file.path, bundle: bundle);
      final doc3 = await DocumentAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        mimeType: 'application/custom',
      );

      expect(doc1, doc2);
      expect(doc1, isNot(doc3));
    });

    test('should auto-detect MIME type', () async {
      final asset = Fixture.sample_doc;

      final doc = await DocumentAssetMedia.load(asset.file.path, bundle: bundle);

      expect(doc.mimeType, asset.mimeType);
    });
  });

  group('DocumentAssetMedia.saveTo', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save to file system', () async {
      final asset = Fixture.sample_doc;

      final doc = await DocumentAssetMedia.load(asset.file.path, bundle: bundle);

      final filePath = '$tempDir/saved_document.pdf';
      final savedFile = await doc.saveTo(filePath);

      expect(savedFile, isA<DocumentFileMedia>());
      expect(savedFile.name, doc.name);
      expect(savedFile.mimeType, doc.mimeType);
      expect(savedFile.size, doc.size);
      expect(await savedFile.file.exists(), isTrue);
    });
  });

  group('DocumentAssetMedia.convertToMemory', () {
    test('should convert to memory representation', () async {
      final asset = Fixture.sample_doc;

      final doc = await DocumentAssetMedia.load(asset.file.path, bundle: bundle);

      final memoryMedia = await doc.convertToMemory();

      expect(memoryMedia, isA<DocumentMemoryMedia>());
      expect(memoryMedia.name, doc.name);
      expect(memoryMedia.mimeType, doc.mimeType);
      expect(memoryMedia.size, doc.size);
    });
  });

  group('OtherTypeAssetMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'test_file.sh',
        mimeType: 'application/x-sh',
      );

      expect(other.assetPath, asset.file.path);
      expect(other.name, 'test_file.sh');
      expect(other.mimeType, 'application/x-sh');
      expect(other.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_unknown_file;

      final other1 = await OtherTypeAssetMedia.load(asset.file.path, bundle: bundle);
      final other2 = await OtherTypeAssetMedia.load(asset.file.path, bundle: bundle);
      final other3 = await OtherTypeAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: 'different.sh',
      );

      expect(other1, other2);
      expect(other1, isNot(other3));
    });

    test('should auto-detect MIME type', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeAssetMedia.load(asset.file.path, bundle: bundle);

      expect(other.mimeType, asset.mimeType);
    });
  });

  group('OtherTypeAssetMedia.saveTo', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save to file system', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeAssetMedia.load(asset.file.path, bundle: bundle);

      final filePath = '$tempDir/saved_file.sh';
      final savedFile = await other.saveTo(filePath);

      expect(savedFile, isA<OtherTypeFileMedia>());
      expect(savedFile.name, other.name);
      expect(savedFile.mimeType, other.mimeType);
      expect(savedFile.size, other.size);
      expect(await savedFile.file.exists(), isTrue);
    });
  });

  group('OtherTypeAssetMedia.convertToMemory', () {
    test('should convert to memory representation', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeAssetMedia.load(asset.file.path, bundle: bundle);

      final memoryMedia = await other.convertToMemory();

      expect(memoryMedia, isA<OtherTypeMemoryMedia>());
      expect(memoryMedia.name, other.name);
      expect(memoryMedia.mimeType, other.mimeType);
      expect(memoryMedia.size, other.size);
    });
  });

  group('Edge cases and error handling', () {
    test('should handle asset with no extension', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(other.name, isNotEmpty);
      expect(other.size, asset.size);
    });

    test('should handle large asset sizes', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(video.size!, asset.size); // > 1MB
    });

    test('should handle small asset', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(other.size, asset.size);
    });
  });

  group('Custom bundle behavior', () {
    test('should use provided bundle for all operations', () async {
      final asset = Fixture.sample_image;

      final image = await ImageAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(image.bundle, bundle);

      final memory = await image.convertToMemory();
      expect(memory.bytes.length, asset.size.inBytes);
    });

    test('should include bundle in equality check', () async {
      final asset = Fixture.sample_image;
      final bundle1 = TestFileAssetBundle();
      final bundle2 = TestFileAssetBundle();

      final image1 = await ImageAssetMedia.load(asset.file.path, bundle: bundle1);
      final image2 = await ImageAssetMedia.load(asset.file.path, bundle: bundle2);

      expect(image1.assetPath, image2.assetPath);
      expect(image1.bundle, isNot(same(image2.bundle)));
    });
  });

  group('Conversion workflow integration', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should support asset -> file -> memory conversion chain', () async {
      final asset = Fixture.sample_image;

      final assetMedia = await ImageAssetMedia.load(asset.file.path, bundle: bundle);
      expect(assetMedia, isA<ImageAssetMedia>());

      final fileMedia = await assetMedia.saveTo('$tempDir/chain_test.jpg');
      expect(fileMedia, isA<ImageFileMedia>());
      expect(fileMedia.size, assetMedia.size);

      final memoryMedia = await fileMedia.convertToMemory();
      expect(memoryMedia, isA<ImageMemoryMedia>());
      expect(memoryMedia.size, assetMedia.size);
    });

    test('should support asset -> memory -> file conversion chain', () async {
      final asset = Fixture.sample_audio;

      final assetMedia = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await assetMedia.convertToMemory();
      expect(memoryMedia, isA<AudioMemoryMedia>());

      final fileMedia = await memoryMedia.saveTo('$tempDir/chain_audio.mp3');
      expect(fileMedia, isA<AudioFileMedia>());
      expect(fileMedia.size, assetMedia.size);
    });
  });

  group('Metadata preservation', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should preserve video duration through conversions', () async {
      final asset = Fixture.sample_video;

      final assetMedia = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await assetMedia.convertToMemory();
      expect(memoryMedia.metadata.duration, asset.duration);

      final fileMedia = await assetMedia.saveTo('$tempDir/duration_test.mp4');
      expect(fileMedia.metadata.duration, asset.duration);
    });

    test('should preserve audio duration through conversions', () async {
      final asset = Fixture.sample_audio;

      final assetMedia = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await assetMedia.convertToMemory();
      expect(memoryMedia.metadata.duration, asset.duration);

      final fileMedia = await assetMedia.saveTo('$tempDir/audio_duration.mp3');
      expect(fileMedia.metadata.duration, asset.duration);
    });
  });

  group('Metadata preservation', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should preserve video duration through conversions', () async {
      final asset = Fixture.sample_video;

      final assetMedia = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await assetMedia.convertToMemory();
      expect(memoryMedia.metadata.duration, asset.duration);

      final fileMedia = await assetMedia.saveTo('$tempDir/duration_test.mp4');
      expect(fileMedia.metadata.duration, asset.duration);
    });

    test('should preserve audio duration through conversions', () async {
      final asset = Fixture.sample_audio;

      final assetMedia = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await assetMedia.convertToMemory();
      expect(memoryMedia.metadata.duration, asset.duration);

      final fileMedia = await assetMedia.saveTo('$tempDir/audio_duration.mp3');
      expect(fileMedia.metadata.duration, asset.duration);
    });

    test('should preserve custom MIME types through conversions', () async {
      final asset = Fixture.sample_image;
      const customMimeType = 'image/custom-format';

      final assetMedia = await ImageAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        mimeType: customMimeType,
      );

      final memoryMedia = await assetMedia.convertToMemory();
      expect(memoryMedia.mimeType, customMimeType);

      final fileMedia = await assetMedia.saveTo('$tempDir/custom_mime.jpg');
      expect(fileMedia.mimeType, customMimeType);
    });

    test('should preserve custom names through conversions', () async {
      final asset = Fixture.sample_doc;
      const customName = 'my_custom_document.pdf';

      final assetMedia = await DocumentAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        name: customName,
      );

      expect(assetMedia.name, customName);

      final memoryMedia = await assetMedia.convertToMemory();
      expect(memoryMedia.name, customName);

      final fileMedia = await assetMedia.saveTo('$tempDir/custom_name.pdf');
      expect(fileMedia.name, customName);
    });
  });

  group('Real asset files from test/assets/', () {
    test('should load real video asset', () async {
      final asset = Fixture.sample_video;

      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      expect(video.assetPath, asset.file.path);
      expect(video.name, asset.file.name);
      expect(video.mimeType, asset.mimeType);
      expect(video.size, asset.size);
      expect(video.metadata.duration, asset.duration);
    });

    test('should load real audio asset', () async {
      final asset = Fixture.sample_audio;

      final audio = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      expect(audio.assetPath, asset.file.path);
      expect(audio.name, asset.file.name);
      expect(audio.mimeType, asset.mimeType);
      expect(audio.size, asset.size);
      expect(audio.metadata.duration, asset.duration);
    });

    test('should load real image asset', () async {
      final asset = Fixture.sample_image;

      final image = await ImageAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(image.assetPath, asset.file.path);
      expect(image.name, asset.file.name);
      expect(image.mimeType, asset.mimeType);
      expect(image.size, asset.size);
    });

    test('should load real document asset', () async {
      final asset = Fixture.sample_doc;

      final doc = await DocumentAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(doc.assetPath, asset.file.path);
      expect(doc.name, asset.file.name);
      expect(doc.mimeType, asset.mimeType);
      expect(doc.size, asset.size);
    });

    test('should load real unknown file asset', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      expect(other.assetPath, asset.file.path);
      expect(other.name, asset.file.name);
      expect(other.mimeType, asset.mimeType);
      expect(other.size, asset.size);
    });

    test('should convert real video asset to memory', () async {
      final asset = Fixture.sample_video;
      final video = await VideoAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      final memoryMedia = await video.convertToMemory();

      expect(memoryMedia, isA<VideoMemoryMedia>());
      expect(memoryMedia.bytes.length, asset.size.inBytes);
      expect(memoryMedia.size, video.size);
      expect(memoryMedia.metadata.duration, video.metadata.duration);
    });

    test('should save real image asset to file', () async {
      final asset = Fixture.sample_image;

      final image = await ImageAssetMedia.load(
        asset.file.path,
        bundle: bundle,
      );

      final savedFile = await image.saveTo('$tempDir/real_sample_image.jpg');

      expect(savedFile, isA<ImageFileMedia>());
      expect(await savedFile.file.exists(), isTrue);
      expect(savedFile.size, image.size);

      // Verify the saved file has the same content
      final savedBytes = await savedFile.file.readAsBytes();
      expect(savedBytes.lengthInBytes, asset.size.inBytes);
    });

    test('should handle real asset conversion chain', () async {
      final asset = Fixture.sample_audio;

      final audio = await AudioAssetMedia.load(
        asset.file.path,
        bundle: bundle,
        duration: asset.duration,
      );

      // asset -> memory
      final memoryMedia = await audio.convertToMemory();
      expect(memoryMedia.bytes.lengthInBytes, asset.size.inBytes);

      // memory -> file
      final fileMedia = await memoryMedia.saveTo('$tempDir/real_chain_audio.mp3');
      expect(await fileMedia.file.exists(), isTrue);
      expect(fileMedia.size, audio.size);

      // file -> memory again
      final memoryMedia2 = await fileMedia.convertToMemory();
      expect(memoryMedia2.bytes.length, memoryMedia.bytes.length);
      expect(memoryMedia2.bytes, memoryMedia.bytes);
    });

    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });
  });
}
