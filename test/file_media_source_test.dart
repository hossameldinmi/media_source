import 'package:flutter/services.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/extensions/file_extensions.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'assets/fixture.dart';

const channel = MethodChannel('flutter_media_metadata');
final tempDir = 'test/assets/file_media_test';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoFileMedia', () {
    test('should create from path with all properties', () async {
      final asset = Fixture.sample_video;
      final duration = asset.duration!;

      final video = await VideoFileMedia.fromPath(
        asset.file.path,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(video.file.path, asset.file.path);
      expect(video.name, asset.file.name);
      expect(video.metadata.duration, duration);
      expect(video.mimeType, asset.mimeType);
      expect(video.size, asset.size);
    });

    test('should create from file with all properties', () async {
      final asset = Fixture.sample_video;
      final duration = asset.duration!;

      final video = await VideoFileMedia.fromFile(
        asset.file,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(video.file, asset.file);
      expect(video.name, asset.file.name);
      expect(video.metadata.duration, duration);
      expect(video.mimeType, asset.mimeType);
      expect(video.size, asset.size);
    });

    test('should have consistent properties', () async {
      final asset = Fixture.sample_video;
      final duration = const Duration(seconds: 60);

      final video1 = await VideoFileMedia.fromPath(
        asset.file.path,
        name: 'video.mp4',
        duration: duration,
      );
      final video2 = await VideoFileMedia.fromPath(
        asset.file.path,
        name: 'video.mp4',
        duration: duration,
      );
      final video3 = await VideoFileMedia.fromPath(
        asset.file.path,
        name: 'other.mp4',
        duration: duration,
      );

      expect(video1.file.path, video2.file.path);
      expect(video1.name, video2.name);
      expect(video1.metadata, video2.metadata);
      expect(video1.name, isNot(video3.name));
    });

    test('should include file in props', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);

      expect(video.props.first, video.file);
    });
  });

  group('AudioFileMedia', () {
    test('should create from path with all properties', () async {
      final asset = Fixture.sample_audio;
      final duration = const Duration(minutes: 3);

      final audio = await AudioFileMedia.fromPath(
        asset.file.path,
        name: 'audio.mp3',
        duration: duration,
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(audio.file.path, asset.file.path);
      expect(audio.name, 'audio.mp3');
      expect(audio.metadata.duration, duration);
      expect(audio.mimeType, asset.mimeType);
      expect(audio.size, asset.size);
    });

    test('should create from file with all properties', () async {
      final asset = Fixture.sample_audio;
      final duration = asset.duration!;

      final audio = await AudioFileMedia.fromFile(
        asset.file,
        name: asset.file.name,
        duration: duration,
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(audio.file, asset.file);
      expect(audio.name, asset.file.name);
      expect(audio.metadata.duration, duration);
      expect(audio.mimeType, asset.mimeType);
      expect(audio.size, asset.size);
    });

    test('should have consistent properties', () async {
      final asset = Fixture.sample_audio;
      final duration = asset.duration!;

      final audio1 = await AudioFileMedia.fromPath(
        asset.file.path,
        name: 'audio.mp3',
        duration: duration,
      );
      final audio2 = await AudioFileMedia.fromPath(
        asset.file.path,
        name: 'audio.mp3',
        duration: duration,
        mimeType: asset.mimeType,
      );
      final audio3 = await AudioFileMedia.fromPath(
        asset.file.path,
        name: 'other.mp3',
        duration: duration,
      );

      expect(audio1.file.path, audio2.file.path);
      expect(audio1.name, audio2.name);
      expect(audio1.metadata, audio2.metadata);
      expect(audio1.name, isNot(audio3.name));
    });
  });

  group('ImageFileMedia', () {
    test('should create from path with all properties', () async {
      final asset = Fixture.sample_image;

      final image = await ImageFileMedia.fromPath(
        asset.file.path,
        name: 'image.png',
        mimeType: 'image/png',
        size: asset.size,
      );

      expect(image.file.path, asset.file.path);
      expect(image.name, 'image.png');
      expect(image.mimeType, 'image/png');
      expect(image.size, asset.size);
    });

    test('should create from file with all properties', () async {
      final asset = Fixture.sample_image;

      final image = await ImageFileMedia.fromFile(
        asset.file,
        name: asset.file.name,
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(image.file, asset.file);
      expect(image.name, asset.file.name);
      expect(image.mimeType, asset.mimeType);
      expect(image.size, asset.size);
    });

    test('should have consistent properties', () async {
      final asset = Fixture.sample_image;

      final image1 = await ImageFileMedia.fromPath(asset.file.path, name: 'test.png');
      final image2 = await ImageFileMedia.fromPath(asset.file.path, name: 'test.png');
      final image3 = await ImageFileMedia.fromPath(asset.file.path, name: 'other.png');

      expect(image1.file.path, image2.file.path);
      expect(image1.name, image2.name);
      expect(image1.name, isNot(image3.name));
    });
  });

  group('DocumentFileMedia', () {
    test('should create from path with all properties', () async {
      final asset = Fixture.sample_doc;

      final doc = await DocumentFileMedia.fromPath(
        asset.file.path,
        name: 'document.pdf',
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(doc.file.path, asset.file.path);
      expect(doc.name, 'document.pdf');
      expect(doc.mimeType, asset.mimeType);
      expect(doc.size, asset.size);
    });

    test('should create from file with all properties', () async {
      final asset = Fixture.sample_doc;

      final doc = await DocumentFileMedia.fromFile(
        asset.file,
        name: asset.file.name,
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(doc.file, asset.file);
      expect(doc.name, asset.file.name);
      expect(doc.mimeType, asset.mimeType);
      expect(doc.size, asset.size);
    });

    test('should have consistent properties', () async {
      final asset = Fixture.sample_doc;

      final doc1 = await DocumentFileMedia.fromPath(asset.file.path, name: 'test.pdf');
      final doc2 = await DocumentFileMedia.fromPath(asset.file.path, name: 'test.pdf');
      final doc3 = await DocumentFileMedia.fromPath(asset.file.path, name: 'other.pdf');

      expect(doc1.file.path, doc2.file.path);
      expect(doc1.name, doc2.name);
      expect(doc1.name, isNot(doc3.name));
    });
  });

  group('OtherTypeFileMedia', () {
    test('should create from path with all properties', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeFileMedia.fromPath(
        asset.file.path,
        name: 'unknown.xyz',
        mimeType: 'application/octet-stream',
        size: asset.size,
      );

      expect(other.file.path, asset.file.path);
      expect(other.name, 'unknown.xyz');
      expect(other.mimeType, 'application/octet-stream');
      expect(other.size, asset.size);
    });

    test('should create from file with all properties', () async {
      final asset = Fixture.sample_unknown_file;

      final other = await OtherTypeFileMedia.fromFile(
        asset.file,
        name: asset.file.name,
        mimeType: asset.mimeType,
        size: asset.size,
      );

      expect(other.file, asset.file);
      expect(other.name, asset.file.name);
      expect(other.mimeType, asset.mimeType);
      expect(other.size, asset.size);
    });

    test('should have consistent properties', () async {
      final asset = Fixture.sample_unknown_file;

      final other1 = await OtherTypeFileMedia.fromPath(asset.file.path, name: 'test.xyz');
      final other2 = await OtherTypeFileMedia.fromPath(asset.file.path, name: 'test.xyz');
      final other3 = await OtherTypeFileMedia.fromPath(asset.file.path, name: 'other.xyz');

      expect(other1.file.path, other2.file.path);
      expect(other1.name, other2.name);
      expect(other1.name, isNot(other3.name));
    });
  });

  group('FileMediaSource.fromPath', () {
    test('should create VideoFileMedia for video files', () async {
      final asset = Fixture.sample_video;
      final media1 = await FileMediaSource.fromPath(asset.file.path);
      final media2 = await FileMediaSource.fromPath(asset.file.path, size: asset.size);

      expect(media1, isA<VideoFileMedia>());
      expect(media1.name, asset.file.name);
      expect(media1.size, media2.size);
    });

    test('should create AudioFileMedia for audio files', () async {
      final asset = Fixture.sample_audio;
      final media = await FileMediaSource.fromPath(asset.file.path);

      expect(media, isA<AudioFileMedia>());
      expect(media.name, asset.file.name);
    });

    test('should create ImageFileMedia for image files', () async {
      final asset = Fixture.sample_image;
      final media = await FileMediaSource.fromPath(asset.file.path);

      expect(media, isA<ImageFileMedia>());
      expect(media.name, asset.file.name);
    });

    test('should create DocumentFileMedia for document files', () async {
      final asset = Fixture.sample_doc;
      final media = await FileMediaSource.fromPath(asset.file.path);

      expect(media, isA<DocumentFileMedia>());
      expect(media.name, asset.file.name);
    });

    test('should create OtherTypeFileMedia for unknown files', () async {
      final asset = Fixture.sample_unknown_file;
      final media = await FileMediaSource.fromPath(asset.file.path);

      expect(media, isA<OtherTypeFileMedia>());
      expect(media.name, asset.file.name);
    });
  });

  group('FileMediaSource.fromFile', () {
    test('should create VideoFileMedia for video files', () async {
      final asset = Fixture.sample_video;
      final media = await FileMediaSource.fromFile(asset.file);

      expect(media, isA<VideoFileMedia>());
      expect(media.name, asset.file.name);
    });

    test('should create AudioFileMedia for audio files', () async {
      final asset = Fixture.sample_audio;
      final media = await FileMediaSource.fromFile(asset.file);

      expect(media, isA<AudioFileMedia>());
      expect(media.name, asset.file.name);
    });

    test('should create ImageFileMedia for image files', () async {
      final asset = Fixture.sample_image;
      final media = await FileMediaSource.fromFile(asset.file);

      expect(media, isA<ImageFileMedia>());
      expect(media.name, asset.file.name);
    });

    test('should create DocumentFileMedia for document files', () async {
      final asset = Fixture.sample_doc;
      final media = await FileMediaSource.fromFile(asset.file);

      expect(media, isA<DocumentFileMedia>());
      expect(media.name, asset.file.name);
    });

    test('should create OtherTypeFileMedia for unknown files', () async {
      final asset = Fixture.sample_unknown_file;
      final media = await FileMediaSource.fromFile(asset.file);

      expect(media, isA<OtherTypeFileMedia>());
      expect(media.name, asset.file.name);
    });
  });

  group('saveTo', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save VideoFileMedia to new path', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);
      final newPath = '$tempDir/saved_video.mp4';

      final savedFile = await video.saveTo(newPath);

      expect(savedFile, isA<VideoFileMedia>());
      expect(savedFile.file.path, newPath);
      expect(savedFile.name, video.name);
      expect(savedFile.metadata, video.metadata);
      expect(savedFile.size, video.size);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save AudioFileMedia to new path', () async {
      final asset = Fixture.sample_audio;
      final audio = await AudioFileMedia.fromPath(asset.file.path);
      final newPath = '$tempDir/saved_audio.mp3';

      final savedFile = await audio.saveTo(newPath);

      expect(savedFile, isA<AudioFileMedia>());
      expect(savedFile.file.path, newPath);
      expect(savedFile.name, audio.name);
      expect(savedFile.metadata, audio.metadata);
      expect(savedFile.size, audio.size);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save ImageFileMedia to new path', () async {
      final asset = Fixture.sample_image;
      final image = await ImageFileMedia.fromPath(asset.file.path);
      final newPath = '$tempDir/saved_image.jpg';

      final savedFile = await image.saveTo(newPath);

      expect(savedFile, isA<ImageFileMedia>());
      expect(savedFile.file.path, newPath);
      expect(savedFile.name, image.name);
      expect(savedFile.size, image.size);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save DocumentFileMedia to new path', () async {
      final asset = Fixture.sample_doc;
      final doc = await DocumentFileMedia.fromPath(asset.file.path);
      final newPath = '$tempDir/saved_document.pdf';

      final savedFile = await doc.saveTo(newPath);

      expect(savedFile, isA<DocumentFileMedia>());
      expect(savedFile.file.path, newPath);
      expect(savedFile.name, doc.name);
      expect(savedFile.size, doc.size);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save OtherTypeFileMedia to new path', () async {
      final asset = Fixture.sample_unknown_file;
      final other = await OtherTypeFileMedia.fromPath(asset.file.path);
      final newPath = '$tempDir/saved_unknown.sh';

      final savedFile = await other.saveTo(newPath);

      expect(savedFile, isA<OtherTypeFileMedia>());
      expect(savedFile.file.path, newPath);
      expect(savedFile.name, other.name);
      expect(savedFile.size, other.size);
      expect(await savedFile.file.exists(), isTrue);
    });
  });

  group('saveToFolder', () {
    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should save VideoFileMedia to folder', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);
      final folderPath = '$tempDir/folder';

      final savedFile = await video.saveToFolder(folderPath);

      expect(savedFile, isA<VideoFileMedia>());
      expect(savedFile.file.path, '$folderPath/${video.name}');
      expect(savedFile.name, video.name);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save AudioFileMedia to folder', () async {
      final asset = Fixture.sample_audio;
      final audio = await AudioFileMedia.fromPath(asset.file.path);
      final folderPath = '$tempDir/folder';

      final savedFile = await audio.saveToFolder(folderPath);

      expect(savedFile, isA<AudioFileMedia>());
      expect(savedFile.file.path, '$folderPath/${audio.name}');
      expect(savedFile.name, audio.name);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save ImageFileMedia to folder', () async {
      final asset = Fixture.sample_image;
      final image = await ImageFileMedia.fromPath(asset.file.path);
      final folderPath = '$tempDir/folder';

      final savedFile = await image.saveToFolder(folderPath);

      expect(savedFile, isA<ImageFileMedia>());
      expect(savedFile.file.path, '$folderPath/${image.name}');
      expect(savedFile.name, image.name);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save DocumentFileMedia to folder', () async {
      final asset = Fixture.sample_doc;
      final doc = await DocumentFileMedia.fromPath(asset.file.path);
      final folderPath = '$tempDir/folder';

      final savedFile = await doc.saveToFolder(folderPath);

      expect(savedFile, isA<DocumentFileMedia>());
      expect(savedFile.file.path, '$folderPath/${doc.name}');
      expect(savedFile.name, doc.name);
      expect(await savedFile.file.exists(), isTrue);
    });

    test('should save OtherTypeFileMedia to folder', () async {
      final asset = Fixture.sample_unknown_file;
      final other = await OtherTypeFileMedia.fromPath(asset.file.path);
      final folderPath = '$tempDir/folder';

      final savedFile = await other.saveToFolder(folderPath);

      expect(savedFile, isA<OtherTypeFileMedia>());
      expect(savedFile.file.path, '$folderPath/${other.name}');
      expect(savedFile.name, other.name);
      expect(await savedFile.file.exists(), isTrue);
    });
  });

  group('moveTo', () {
    setUp(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should move VideoFileMedia to new path', () async {
      final asset = Fixture.sample_video;
      final bytes = await asset.file.readAsBytes();
      final video = await VideoFileMedia.fromPath(asset.file.path);

      // Save to temp location first
      final tempPath = '$tempDir/temp_video.mp4';
      final tempVideo = await video.saveTo(tempPath);
      expect(await tempVideo.file.exists(), isTrue);

      // Move to new location
      final newPath = '$tempDir/moved_video.mp4';
      final movedFile = await tempVideo.moveTo(newPath);

      expect(movedFile, isA<VideoFileMedia>());
      expect(movedFile.file.path, newPath);
      expect(await movedFile.file.exists(), isTrue);
      expect(await tempVideo.file.exists(), isFalse);
      expect(await movedFile.file.readAsBytes(), bytes);
    });

    test('should move AudioFileMedia to new path', () async {
      final asset = Fixture.sample_audio;
      final bytes = await asset.file.readAsBytes();
      final audio = await AudioFileMedia.fromPath(asset.file.path);

      final tempPath = '$tempDir/temp_audio.mp3';
      final tempAudio = await audio.saveTo(tempPath);
      expect(await tempAudio.file.exists(), isTrue);

      final newPath = '$tempDir/moved_audio.mp3';
      final movedFile = await tempAudio.moveTo(newPath);

      expect(movedFile, isA<AudioFileMedia>());
      expect(movedFile.file.path, newPath);
      expect(await movedFile.file.exists(), isTrue);
      expect(await tempAudio.file.exists(), isFalse);
      expect(await movedFile.file.readAsBytes(), bytes);
    });

    test('should return same instance if path is identical', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);

      final tempPath = '$tempDir/same_video.mp4';
      final tempVideo = await video.saveTo(tempPath);

      final movedFile = await tempVideo.moveTo(tempPath);

      expect(movedFile, tempVideo);
      expect(await movedFile.file.exists(), isTrue);
    });

    test('should delete existing file at target before moving', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);

      // Create two temp files
      final tempPath1 = '$tempDir/move_video1.mp4';
      final tempPath2 = '$tempDir/move_video2.mp4';

      final tempVideo1 = await video.saveTo(tempPath1);
      await video.saveTo(tempPath2); // Create existing file at target

      // Move tempVideo1 to tempPath2 (should delete existing file first)
      final movedFile = await tempVideo1.moveTo(tempPath2);

      expect(movedFile.file.path, tempPath2);
      expect(await movedFile.file.exists(), isTrue);
      expect(await tempVideo1.file.exists(), isFalse);
    });
  });

  group('moveToFolder', () {
    setUp(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should move VideoFileMedia to folder', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);

      final tempPath = '$tempDir/temp/video.mp4';
      final tempVideo = await video.saveTo(tempPath);

      final folderPath = '$tempDir/moved';
      final movedFile = await tempVideo.moveToFolder(folderPath);

      expect(movedFile.file.path, '$folderPath/${tempVideo.name}');
      expect(await movedFile.file.exists(), isTrue);
      expect(await tempVideo.file.exists(), isFalse);
    });

    test('should move AudioFileMedia to folder', () async {
      final asset = Fixture.sample_audio;
      final audio = await AudioFileMedia.fromPath(asset.file.path);

      final tempPath = '$tempDir/temp/audio.mp3';
      final tempAudio = await audio.saveTo(tempPath);

      final folderPath = '$tempDir/moved';
      final movedFile = await tempAudio.moveToFolder(folderPath);

      expect(movedFile.file.path, '$folderPath/${tempAudio.name}');
      expect(await movedFile.file.exists(), isTrue);
      expect(await tempAudio.file.exists(), isFalse);
    });
  });

  group('delete', () {
    setUp(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    tearDownAll(() async {
      await PlatformUtils.instance.deleteDirectory(tempDir);
    });

    test('should delete VideoFileMedia', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);

      final tempPath = '$tempDir/delete_video.mp4';
      final tempVideo = await video.saveTo(tempPath);
      expect(await tempVideo.file.exists(), isTrue);

      final deleted = await tempVideo.delete();

      expect(deleted, isTrue);
      expect(await tempVideo.file.exists(), isFalse);
    });

    test('should delete AudioFileMedia', () async {
      final asset = Fixture.sample_audio;
      final audio = await AudioFileMedia.fromPath(asset.file.path);

      final tempPath = '$tempDir/delete_audio.mp3';
      final tempAudio = await audio.saveTo(tempPath);
      expect(await tempAudio.file.exists(), isTrue);

      final deleted = await tempAudio.delete();

      expect(deleted, isTrue);
      expect(await tempAudio.file.exists(), isFalse);
    });
  });

  group('convertToMemory', () {
    test('should convert VideoFileMedia to VideoMemoryMedia', () async {
      final asset = Fixture.sample_video;
      final video = await VideoFileMedia.fromPath(asset.file.path);

      final memoryMedia = await video.convertToMemory();

      expect(memoryMedia, isA<VideoMemoryMedia>());
      expect(memoryMedia.name, video.name);
      expect(memoryMedia.metadata, video.metadata);
      expect(memoryMedia.size, video.size);
      expect(memoryMedia.bytes, await asset.file.readAsBytes());
    });

    test('should convert AudioFileMedia to AudioMemoryMedia', () async {
      final asset = Fixture.sample_audio;
      final audio = await AudioFileMedia.fromPath(asset.file.path);

      final memoryMedia = await audio.convertToMemory();

      expect(memoryMedia, isA<AudioMemoryMedia>());
      expect(memoryMedia.name, audio.name);
      expect(memoryMedia.metadata, audio.metadata);
      expect(memoryMedia.size, audio.size);
      expect(memoryMedia.bytes, await asset.file.readAsBytes());
    });

    test('should convert ImageFileMedia to ImageMemoryMedia', () async {
      final asset = Fixture.sample_image;
      final image = await ImageFileMedia.fromPath(asset.file.path);

      final memoryMedia = await image.convertToMemory();

      expect(memoryMedia, isA<ImageMemoryMedia>());
      expect(memoryMedia.name, image.name);
      expect(memoryMedia.size, image.size);
      expect(memoryMedia.bytes, await asset.file.readAsBytes());
    });

    test('should convert DocumentFileMedia to DocumentMemoryMedia', () async {
      final asset = Fixture.sample_doc;
      final doc = await DocumentFileMedia.fromPath(asset.file.path);

      final memoryMedia = await doc.convertToMemory();

      expect(memoryMedia, isA<DocumentMemoryMedia>());
      expect(memoryMedia.name, doc.name);
      expect(memoryMedia.size, doc.size);
      expect(memoryMedia.bytes, await asset.file.readAsBytes());
    });

    test('should convert OtherTypeFileMedia to OtherTypeMemoryMedia', () async {
      final asset = Fixture.sample_unknown_file;
      final other = await OtherTypeFileMedia.fromPath(asset.file.path);

      final memoryMedia = await other.convertToMemory();

      expect(memoryMedia, isA<OtherTypeMemoryMedia>());
      expect(memoryMedia.name, other.name);
      expect(memoryMedia.size, other.size);
      expect(memoryMedia.bytes, await asset.file.readAsBytes());
    });
  });
}
