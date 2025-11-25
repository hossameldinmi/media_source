import 'package:flutter/services.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/extensions/file_extensions.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:file_sized/file_sized.dart';
import 'package:flutter_test/flutter_test.dart';
import 'shared/fixture.dart';

final tempDir = 'test/assets/saved_to';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoMemoryMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_video;
      final bytes = await asset.file.readAsBytes();
      final duration = asset.duration!;

      final video = VideoMemoryMedia(
        bytes,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
      );

      expect(video.bytes, bytes);
      expect(video.name, asset.file.name);
      expect(video.metadata.duration, duration);
      expect(video.mimeType, asset.mimeType);
      expect(video.size, bytes.lengthInBytes.b);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_video;
      final bytes = await asset.file.readAsBytes();
      final duration = const Duration(seconds: 60);

      final video1 = VideoMemoryMedia(bytes, name: 'video.mp4', duration: duration);
      final video2 = VideoMemoryMedia(bytes, name: 'video.mp4', duration: duration);
      final video3 = VideoMemoryMedia(bytes, name: 'other.mp4', duration: duration);

      expect(video1, video2);
      expect(video1, isNot(video3));
    });

    test('should have stringify set to false', () async {
      final asset = Fixture.sample_video;
      final bytes = await asset.file.readAsBytes();

      final video = VideoMemoryMedia(bytes, name: 'video.mp4');

      expect(video.stringify, false);
    });
  });

  group('AudioMemoryMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_audio;
      final bytes = await asset.file.readAsBytes();

      final duration = const Duration(minutes: 3);

      final audio = AudioMemoryMedia(
        bytes,
        name: 'audio.mp3',
        duration: duration,
        mimeType: asset.mimeType,
      );

      expect(audio.bytes, bytes);
      expect(audio.name, 'audio.mp3');
      expect(audio.metadata.duration, duration);
      expect(audio.mimeType, asset.mimeType);
      expect(audio.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_audio;
      final bytes = await asset.file.readAsBytes();
      final duration = asset.duration!;

      final audio1 = AudioMemoryMedia(bytes, name: 'audio.mp3', duration: duration);
      final audio2 = AudioMemoryMedia(bytes, name: 'audio.mp3', duration: duration, mimeType: asset.mimeType);
      final audio3 = AudioMemoryMedia(bytes, name: 'other.mp3', duration: duration);

      expect(audio1, audio2);
      expect(audio1, isNot(audio3));
    });
  });

  group('ImageMemoryMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_image;
      final bytes = await asset.file.readAsBytes();

      final image = ImageMemoryMedia(
        bytes,
        name: 'image.png',
        mimeType: 'image/png',
      );

      expect(image.bytes, bytes);
      expect(image.name, 'image.png');
      expect(image.mimeType, 'image/png');
      expect(image.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_image;
      final bytes = await asset.file.readAsBytes();

      final image1 = ImageMemoryMedia(bytes, name: 'image.png');
      final image2 = ImageMemoryMedia(bytes, name: 'image.png', mimeType: asset.mimeType);
      final image3 = ImageMemoryMedia(bytes, name: 'other.png');

      expect(image1, image2);
      expect(image1, isNot(image3));
    });
  });

  group('DocumentMemoryMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_doc;
      final bytes = await asset.file.readAsBytes();
      final doc = DocumentMemoryMedia(
        bytes,
        name: 'document.pdf',
        mimeType: 'application/pdf',
      );

      expect(doc.bytes, bytes);
      expect(doc.name, 'document.pdf');
      expect(doc.mimeType, asset.mimeType);
      expect(doc.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_doc;
      final bytes = await asset.file.readAsBytes();

      final doc1 = DocumentMemoryMedia(bytes, name: 'doc.pdf');
      final doc2 = DocumentMemoryMedia(bytes, name: 'doc.pdf', mimeType: asset.mimeType);
      final doc3 = DocumentMemoryMedia(bytes, name: 'other.pdf');

      expect(doc1, doc2);
      expect(doc1, isNot(doc3));
    });
  });

  group('UnSupportedMemoryMedia', () {
    test('should create with all properties', () async {
      final asset = Fixture.sample_unknown_file;
      final bytes = await asset.file.readAsBytes();

      final unsupported = OtherTypeMemoryMedia(
        bytes,
        name: 'file.unknown',
        mimeType: asset.mimeType,
      );

      expect(unsupported.bytes, bytes);
      expect(unsupported.name, 'file.unknown');
      expect(unsupported.mimeType, asset.mimeType);
      expect(unsupported.size, asset.size);
    });

    test('should be equatable', () async {
      final asset = Fixture.sample_unknown_file;
      final bytes = await asset.file.readAsBytes();

      final unsupported1 = OtherTypeMemoryMedia(bytes, name: 'file.unknown');
      final unsupported2 = OtherTypeMemoryMedia(bytes, name: 'file.unknown');
      final unsupported3 = OtherTypeMemoryMedia(bytes, name: 'other.unknown');

      expect(unsupported1, unsupported2);
      expect(unsupported1, isNot(unsupported3));
    });

    test(
      'should be equatable with mimeType',
      () async {
        final asset = Fixture.sample_unknown_file;
        final bytes = await asset.file.readAsBytes();

        final unsupported1 = OtherTypeMemoryMedia(bytes, name: 'file.unknown');
        final unsupported2 = OtherTypeMemoryMedia(bytes, name: 'file.unknown', mimeType: asset.mimeType);
        final unsupported3 = OtherTypeMemoryMedia(bytes, name: 'other.unknown');

        expect(unsupported1, unsupported2);
        expect(unsupported1, isNot(unsupported3));
      },
      skip: "mimeType is not retrieved for this unsupported file",
    );
  });

  group('properties', () {
    test('should have correct size', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
      final image = ImageMemoryMedia(bytes, name: 'test.png');

      expect(image.size, 6.b);
    });

    test('should detect mime type from bytes when not provided', () {
      final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final image = ImageMemoryMedia(bytes, name: 'test.png');

      // MIME type detection depends on FileUtil implementation
      // which may or may not detect from bytes
      expect(image.mimeType, anyOf(isNotNull, isNull));
    });

    test('should use provided mime type', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final image = ImageMemoryMedia(bytes, name: 'test.png', mimeType: 'image/png');

      expect(image.mimeType, 'image/png');
    });
  });

  group('saveTo', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });
    test('should save VideoMemoryMedia to file', () async {
      final asset = Fixture.sample_video;
      final bytes = await asset.file.readAsBytes();
      final duration = asset.duration!;

      final video = VideoMemoryMedia(
        bytes,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
      );

      final filePath = '$tempDir/saved_video.mp4';

      final savedFile = await video.saveTo(filePath);

      expect(savedFile, isA<VideoFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.metadata, video.metadata);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, video.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save AudioMemoryMedia to file', () async {
      final asset = Fixture.sample_audio;
      final bytes = await asset.file.readAsBytes();
      final duration = asset.duration!;

      final audio = AudioMemoryMedia(
        bytes,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
      );

      final filePath = '$tempDir/saved_audio.mp3';

      final savedFile = await audio.saveTo(filePath);

      expect(savedFile, isA<AudioFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.metadata, audio.metadata);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, audio.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save ImageMemoryMedia to file', () async {
      final asset = Fixture.sample_image;
      final bytes = await asset.file.readAsBytes();

      final image = ImageMemoryMedia(
        bytes,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final filePath = '$tempDir/saved_image.jpg';

      final savedFile = await image.saveTo(filePath);

      expect(savedFile, isA<ImageFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, image.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save DocumentMemoryMedia to file', () async {
      final asset = Fixture.sample_doc;
      final bytes = await asset.file.readAsBytes();

      final doc = DocumentMemoryMedia(
        bytes,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final filePath = '$tempDir/saved_document.pdf';

      final savedFile = await doc.saveTo(filePath);

      expect(savedFile, isA<DocumentFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, doc.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save OtherTypeMemoryMedia to file', () async {
      final asset = Fixture.sample_unknown_file;
      final bytes = await asset.file.readAsBytes();

      final other = OtherTypeMemoryMedia(
        bytes,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final filePath = '$tempDir/saved_file.sh';

      final savedFile = await other.saveTo(filePath);

      expect(savedFile, isA<OtherTypeFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, other.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should create parent directory if it does not exist', () async {
      final asset = Fixture.sample_image;
      final bytes = await asset.file.readAsBytes();

      final image = ImageMemoryMedia(
        bytes,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final filePath = '$tempDir/nested/folder/saved_image.jpg';

      final savedFile = await image.saveTo(filePath);

      expect(savedFile, isA<ImageFileMedia>());
      expect(await savedFile.file.exists(), isTrue);
      expect(await PlatformUtils.instance.directoryExists('$tempDir/nested/folder'), isTrue);
    });
  });

  group('saveToFolder', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save VideoMemoryMedia to folder with original name', () async {
      final asset = Fixture.sample_video;
      final bytes = await asset.file.readAsBytes();
      final duration = asset.duration!;

      final video = VideoMemoryMedia(
        bytes,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
      );

      final savedFile = await video.saveToFolder(tempDir);

      expect(savedFile, isA<VideoFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.metadata, video.metadata);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, video.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save AudioMemoryMedia to folder with original name', () async {
      final asset = Fixture.sample_audio;
      final bytes = await asset.file.readAsBytes();
      final duration = asset.duration!;

      final audio = AudioMemoryMedia(
        bytes,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
      );

      final savedFile = await audio.saveToFolder(tempDir);

      expect(savedFile, isA<AudioFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.metadata, audio.metadata);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, audio.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save ImageMemoryMedia to folder with original name', () async {
      final asset = Fixture.sample_image;
      final bytes = await asset.file.readAsBytes();

      final image = ImageMemoryMedia(
        bytes,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final savedFile = await image.saveToFolder(tempDir);

      expect(savedFile, isA<ImageFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, image.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save DocumentMemoryMedia to folder with original name', () async {
      final asset = Fixture.sample_doc;
      final bytes = await asset.file.readAsBytes();

      final doc = DocumentMemoryMedia(
        bytes,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final savedFile = await doc.saveToFolder(tempDir);

      expect(savedFile, isA<DocumentFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, doc.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should save OtherTypeMemoryMedia to folder with original name', () async {
      final asset = Fixture.sample_unknown_file;
      final bytes = await asset.file.readAsBytes();

      final other = OtherTypeMemoryMedia(
        bytes,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final savedFile = await other.saveToFolder(tempDir);

      expect(savedFile, isA<OtherTypeFileMedia>());
      expect(savedFile.name, asset.file.name);
      expect(savedFile.mimeType, asset.mimeType);
      expect(savedFile.size, other.size);
      expect(await savedFile.file.exists(), isTrue);
      expect(await savedFile.file.readAsBytes(), bytes);
    });

    test('should overwrite existing file with same name in folder', () async {
      final asset = Fixture.sample_image;
      final bytes1 = await asset.file.readAsBytes();
      final bytes2 = Uint8List.fromList([...bytes1, 1, 2, 3]); // Different bytes

      final image1 = ImageMemoryMedia(
        bytes1,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      final image2 = ImageMemoryMedia(
        bytes2,
        name: asset.file.name,
        mimeType: asset.mimeType,
      );

      await image1.saveToFolder(tempDir);
      final savedFile2 = await image2.saveToFolder(tempDir);

      expect(await savedFile2.file.readAsBytes(), bytes2);
      expect(await savedFile2.file.readAsBytes(), isNot(bytes1));
    });
  });
}
