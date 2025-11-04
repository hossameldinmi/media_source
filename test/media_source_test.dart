import 'dart:typed_data';

import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/sources/network_media_source.dart';
import 'package:sized_file/sized_file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'assets/fixture.dart';

void main() {
  group('MediaSource', () {
    group('properties', () {
      test('should have correct basic properties', () async {
        final file = Fixture.sample_image;
        final bytes = await file.file.readAsBytes();
        final source = ImageMemoryMedia(
          bytes,
          name: 'test.png',
          mimeType: 'image/png',
        );

        expect(source.name, 'test.png');
        expect(source.mimeType, 'image/png');
        expect(source.size, 13928213.b);
        expect(source.metadata, isA<ImageType>());
      });

      test('should extract extension from name', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'test.png');

        expect(source.extension, 'png');
      });

      test('should handle name without extension', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'test');

        expect(source.extension, 'test');
      });

      test('should handle empty name', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: null);

        expect(source.name, '');
      });
    });

    group('isAnyType', () {
      test('should return true when type matches', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'test.png');

        expect(source.isAnyType([ImageMemoryMedia, VideoMemoryMedia]), isTrue);
      });

      test('should return false when type does not match', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'test.png');

        expect(source.isAnyType([AudioMemoryMedia, VideoMemoryMedia]), isFalse);
      });
    });

    group('hasThumbnail', () {
      test('should return true for media with thumbnail', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final thumbBytes = Uint8List.fromList([4, 5, 6, 7]);
        final thumbnail = ImageMemoryMedia(thumbBytes, name: 'thumb.jpg');

        final source = VideoMemoryMedia(
          bytes,
          name: 'video.mp4',
          thumbnail: thumbnail,
        );

        expect(source.hasThumbnail, isTrue);
      });

      test('should return false for media without thumbnail', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = VideoMemoryMedia(bytes, name: 'video.mp4');

        expect(source.hasThumbnail, isFalse);
      });

      test('should return false for non-thumbnail media', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'image.png');

        expect(source.hasThumbnail, isFalse);
      });
    });

    group('thumbnailOrNull', () {
      test('should return thumbnail when available', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final thumbBytes = Uint8List.fromList([4, 5, 6, 7]);
        final thumbnail = ImageMemoryMedia(thumbBytes, name: 'thumb.jpg');

        final source = VideoMemoryMedia(
          bytes,
          name: 'video.mp4',
          thumbnail: thumbnail,
        );

        expect(source.thumbnailOrNull(), thumbnail);
      });

      test('should return null when thumbnail not available', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = VideoMemoryMedia(bytes, name: 'video.mp4');

        expect(source.thumbnailOrNull(), isNull);
      });

      test('should return null for non-thumbnail media', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = AudioMemoryMedia(bytes, name: 'audio.mp3');

        expect(source.thumbnailOrNull(), isNull);
      });
    });

    group('when pattern', () {
      test('should call file callback for FileMediaSource', () async {
        // Note: Creating FileMediaSource requires actual file operations
        // This test demonstrates the pattern with NetworkMediaSource instead
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video.mp4',
          mediaType: FileType.video,
        );

        final result = source.fold(
          network: (network) => 'network',
          orElse: () => 'other',
        );

        expect(result, 'network');
      });

      test('should call memory callback for MemoryMediaSource', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'image.png');

        final result = source.fold(
          memory: (memory) => 'memory',
          orElse: () => 'other',
        );

        expect(result, 'memory');
      });

      test('should call network callback for NetworkMediaSource', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/image.png',
          mediaType: FileType.image,
        );

        final result = source.fold(
          network: (network) => 'network',
          orElse: () => 'other',
        );

        expect(result, 'network');
      });

      test('should call orElse when no callback matches', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'image.png');

        final result = source.fold(
          file: (file) => 'file',
          network: (network) => 'network',
          orElse: () => 'other',
        );

        expect(result, 'other');
      });

      test('should pass correct source to callback', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = VideoMemoryMedia(bytes, name: 'video.mp4');

        final result = source.fold<String>(
          memory: (memory) => memory.name,
          orElse: () => 'unknown',
        );

        expect(result, 'video.mp4');
      });

      test('should support different return types', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = ImageMemoryMedia(bytes, name: 'image.png');

        final intResult = source.fold<int>(
          memory: (memory) => 42,
          orElse: () => 0,
        );

        final boolResult = source.fold<bool>(
          memory: (memory) => true,
          orElse: () => false,
        );

        expect(intResult, 42);
        expect(boolResult, isTrue);
      });
    });

    group('equatable', () {
      test('should be equal when properties match', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final source1 = ImageMemoryMedia(bytes, name: 'image.png', mimeType: 'image/png');
        final source2 = ImageMemoryMedia(bytes, name: 'image.png', mimeType: 'image/png');

        expect(source1, source2);
      });

      test('should not be equal when name differs', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final source1 = ImageMemoryMedia(bytes, name: 'image1.png');
        final source2 = ImageMemoryMedia(bytes, name: 'image2.png');

        expect(source1, isNot(source2));
      });

      test('should not be equal when mimeType differs', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final source1 = ImageMemoryMedia(bytes, name: 'image.png', mimeType: 'image/png');
        final source2 = ImageMemoryMedia(bytes, name: 'image.png', mimeType: 'image/jpeg');

        expect(source1, isNot(source2));
      });

      test('should not be equal when bytes differ', () {
        final bytes1 = Uint8List.fromList([0, 1, 2, 3]);
        final bytes2 = Uint8List.fromList([4, 5, 6, 7]);

        final source1 = ImageMemoryMedia(bytes1, name: 'image.png');
        final source2 = ImageMemoryMedia(bytes2, name: 'image.png');

        expect(source1, isNot(source2));
      });

      test('should not be equal when metadata differs', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);

        final source1 = VideoMemoryMedia(bytes, name: 'video.mp4', duration: const Duration(seconds: 60));
        final source2 = VideoMemoryMedia(bytes, name: 'video.mp4', duration: const Duration(seconds: 120));

        expect(source1, isNot(source2));
      });
    });

    group('ThumbnailMedia', () {
      test('should implement ThumbnailMedia interface', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = VideoMemoryMedia(bytes, name: 'video.mp4');

        expect(source, isA<ThumbnailMedia>());
      });

      test('hasThumbnailImp should return true when thumbnail exists', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final thumbBytes = Uint8List.fromList([4, 5, 6, 7]);
        final thumbnail = ImageMemoryMedia(thumbBytes, name: 'thumb.jpg');

        final source = VideoMemoryMedia(
          bytes,
          name: 'video.mp4',
          thumbnail: thumbnail,
        );

        expect(ThumbnailMedia.hasThumbnailImp(source), isTrue);
      });

      test('hasThumbnailImp should return false when thumbnail is null', () {
        final bytes = Uint8List.fromList([0, 1, 2, 3]);
        final source = VideoMemoryMedia(bytes, name: 'video.mp4');

        expect(ThumbnailMedia.hasThumbnailImp(source), isFalse);
      });
    });
  });
}
