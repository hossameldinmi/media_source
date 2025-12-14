import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_source/media_source.dart';

void main() {
  group('ThumbnailMediaSource', () {
    late ImageMemoryMedia original;
    late ImageMemoryMedia thumbnail;

    setUp(() {
      original = ImageMemoryMedia(
        Uint8List.fromList([1, 2, 3]),
        name: 'original.jpg',
      );
      thumbnail = ImageMemoryMedia(
        Uint8List.fromList([4, 5, 6]),
        name: 'thumbnail.jpg',
      );
    });

    test('should forward properties from original source', () {
      final source = ThumbnailMediaSource(original: original);

      expect(source.name, original.name);
      expect(source.size, original.size);
      expect(source.metadata, original.metadata);
      expect(source.mimeType, original.mimeType);
    });

    test('should handle optional thumbnail', () {
      final sourceWithThumbnail = ThumbnailMediaSource(
        original: original,
        thumbnail: thumbnail,
      );
      final sourceWithoutThumbnail = ThumbnailMediaSource(original: original);

      expect(sourceWithThumbnail.hasThumbnail, isTrue);
      expect(sourceWithoutThumbnail.hasThumbnail, isFalse);
    });

    test('should allow specific generic types', () {
      final videoOriginal = VideoMemoryMedia(
        Uint8List.fromList([1, 2, 3]),
        name: 'video.mp4',
      );

      final source = ThumbnailMediaSource<VideoType, VideoType>(original: videoOriginal);

      expect(source.original, isA<MediaSource<VideoType>>());
      expect(source.metadata, isA<VideoType>());
    });

    test('should allow thumbnail of different type', () {
      final videoOriginal = VideoMemoryMedia(
        Uint8List.fromList([1, 2, 3]),
        name: 'video.mp4',
      );
      final source = ThumbnailMediaSource<VideoType, ImageType>(
        original: videoOriginal,
        thumbnail: thumbnail,
      );

      expect(source.original, isA<MediaSource<VideoType>>());
      expect(source.metadata, isA<VideoType>());

      expect(source.thumbnail, isA<MediaSource<ImageType>>());
      expect(source.thumbnail!.metadata, isA<ImageType>());
    });
  });
}
