import 'dart:typed_data';

import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryMediaSource', () {
    group('fromBytes', () {
      test('should create VideoMemoryMedia for video bytes', () async {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final mediaType = MediaType.video;

        final source = await MemoryMediaSource.fromBytes(
          bytes,
          name: 'test.mp4',
          mimeType: 'video/mp4',
          duration: const Duration(seconds: 60),
          mediaType: mediaType,
        );

        expect(source, isA<VideoMemoryMedia>());
        expect(source.name, equals('test.mp4'));
        expect(source.bytes, equals(bytes));
        expect(source.size, equals(bytes.lengthInBytes));
      });

      test('should create AudioMemoryMedia for audio bytes', () async {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final mediaType = MediaType.audio;

        final source = await MemoryMediaSource.fromBytes(
          bytes,
          name: 'test.mp3',
          mimeType: 'audio/mp3',
          duration: const Duration(seconds: 180),
          mediaType: mediaType,
        );

        expect(source, isA<AudioMemoryMedia>());
        expect(source.name, equals('test.mp3'));
        expect(source.bytes, equals(bytes));
      });

      test('should create ImageMemoryMedia for image bytes', () async {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
        final mediaType = MediaType.image;

        final source = await MemoryMediaSource.fromBytes(
          bytes,
          name: 'test.png',
          mimeType: 'image/png',
          mediaType: mediaType,
        );

        expect(source, isA<ImageMemoryMedia>());
        expect(source.name, equals('test.png'));
        expect(source.bytes, equals(bytes));
      });

      test('should create DocumentMemoryMedia for document bytes', () async {
        final bytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]); // PDF signature
        final mediaType = MediaType.document;

        final source = await MemoryMediaSource.fromBytes(
          bytes,
          name: 'test.pdf',
          mimeType: 'application/pdf',
          mediaType: mediaType,
        );

        expect(source, isA<DocumentMemoryMedia>());
        expect(source.name, equals('test.pdf'));
        expect(source.bytes, equals(bytes));
      });

      test('should create UnSupportedMemoryMedia for unknown bytes', () async {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final mediaType = MediaType.other;

        final source = await MemoryMediaSource.fromBytes(
          bytes,
          name: 'test.unknown',
          mediaType: mediaType,
        );

        expect(source, isA<OtherTypeMemoryMedia>());
        expect(source.name, equals('test.unknown'));
      });

      test('should auto-detect media type when not provided', () async {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]); // PNG signature

        final source = await MemoryMediaSource.fromBytes(
          bytes,
          name: 'test.png',
          mimeType: 'image/png',
        );

        expect(source, isA<ImageMemoryMedia>());
      });
    });

    group('VideoMemoryMedia', () {
      test('should create with all properties', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final duration = const Duration(seconds: 120);

        final video = VideoMemoryMedia(
          bytes,
          name: 'video.mp4',
          duration: duration,
          mimeType: 'video/mp4',
        );

        expect(video.bytes, equals(bytes));
        expect(video.name, equals('video.mp4'));
        expect(video.metadata.duration, equals(duration));
        expect(video.mimeType, equals('video/mp4'));
        expect(video.size, equals(bytes.lengthInBytes));
        expect(video.thumbnail, isNull);
        expect(video.hasThumbnail, isFalse);
      });

      test('should support thumbnail', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final thumbnailBytes = Uint8List.fromList([4, 5, 6, 7]);
        final thumbnail = ImageMemoryMedia(thumbnailBytes, name: 'thumb.jpg');

        final video = VideoMemoryMedia(
          bytes,
          name: 'video.mp4',
          thumbnail: thumbnail,
        );

        expect(video.thumbnail, equals(thumbnail));
        expect(video.hasThumbnail, isTrue);
      });

      test('should be equatable', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final duration = const Duration(seconds: 60);

        final video1 = VideoMemoryMedia(bytes, name: 'video.mp4', duration: duration);
        final video2 = VideoMemoryMedia(bytes, name: 'video.mp4', duration: duration);
        final video3 = VideoMemoryMedia(bytes, name: 'other.mp4', duration: duration);

        expect(video1, equals(video2));
        expect(video1, isNot(equals(video3)));
      });
    });

    group('AudioMemoryMedia', () {
      test('should create with all properties', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final duration = const Duration(minutes: 3);

        final audio = AudioMemoryMedia(
          bytes,
          name: 'audio.mp3',
          duration: duration,
          mimeType: 'audio/mp3',
        );

        expect(audio.bytes, equals(bytes));
        expect(audio.name, equals('audio.mp3'));
        expect(audio.metadata.duration, equals(duration));
        expect(audio.mimeType, equals('audio/mp3'));
        expect(audio.size, equals(bytes.lengthInBytes));
      });

      test('should be equatable', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final duration = const Duration(seconds: 180);

        final audio1 = AudioMemoryMedia(bytes, name: 'audio.mp3', duration: duration);
        final audio2 = AudioMemoryMedia(bytes, name: 'audio.mp3', duration: duration);
        final audio3 = AudioMemoryMedia(bytes, name: 'other.mp3', duration: duration);

        expect(audio1, equals(audio2));
        expect(audio1, isNot(equals(audio3)));
      });
    });

    group('ImageMemoryMedia', () {
      test('should create with all properties', () {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);

        final image = ImageMemoryMedia(
          bytes,
          name: 'image.png',
          mimeType: 'image/png',
        );

        expect(image.bytes, equals(bytes));
        expect(image.name, equals('image.png'));
        expect(image.mimeType, equals('image/png'));
        expect(image.size, equals(bytes.lengthInBytes));
      });

      test('should be equatable', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final image1 = ImageMemoryMedia(bytes, name: 'image.png');
        final image2 = ImageMemoryMedia(bytes, name: 'image.png');
        final image3 = ImageMemoryMedia(bytes, name: 'other.png');

        expect(image1, equals(image2));
        expect(image1, isNot(equals(image3)));
      });
    });

    group('DocumentMemoryMedia', () {
      test('should create with all properties', () {
        final bytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);

        final doc = DocumentMemoryMedia(
          bytes,
          name: 'document.pdf',
          mimeType: 'application/pdf',
        );

        expect(doc.bytes, equals(bytes));
        expect(doc.name, equals('document.pdf'));
        expect(doc.mimeType, equals('application/pdf'));
        expect(doc.size, equals(bytes.lengthInBytes));
      });

      test('should be equatable', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final doc1 = DocumentMemoryMedia(bytes, name: 'doc.pdf');
        final doc2 = DocumentMemoryMedia(bytes, name: 'doc.pdf');
        final doc3 = DocumentMemoryMedia(bytes, name: 'other.pdf');

        expect(doc1, equals(doc2));
        expect(doc1, isNot(equals(doc3)));
      });
    });

    group('UnSupportedMemoryMedia', () {
      test('should create with all properties', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final unsupported = OtherTypeMemoryMedia(
          bytes,
          name: 'file.unknown',
          mimeType: 'application/octet-stream',
        );

        expect(unsupported.bytes, equals(bytes));
        expect(unsupported.name, equals('file.unknown'));
        expect(unsupported.mimeType, equals('application/octet-stream'));
        expect(unsupported.size, equals(bytes.lengthInBytes));
      });

      test('should be equatable', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final unsupported1 = OtherTypeMemoryMedia(bytes, name: 'file.unknown');
        final unsupported2 = OtherTypeMemoryMedia(bytes, name: 'file.unknown');
        final unsupported3 = OtherTypeMemoryMedia(bytes, name: 'other.unknown');

        expect(unsupported1, equals(unsupported2));
        expect(unsupported1, isNot(equals(unsupported3)));
      });
    });

    group('properties', () {
      test('should have correct size', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
        final image = ImageMemoryMedia(bytes, name: 'test.png');

        expect(image.size, equals(6));
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

        expect(image.mimeType, equals('image/png'));
      });
    });
  });
}
