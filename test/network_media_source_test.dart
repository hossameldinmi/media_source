import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/network_media_source.dart';
import 'package:sized_file/sized_file.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkMediaSource', () {
    group('fromUrl', () {
      test('should create VideoNetworkMedia for video URL', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video.mp4',
          name: 'video.mp4',
          size: 1024000.b,
          mimeType: 'video/mp4',
          duration: const Duration(seconds: 120),
          mediaType: MediaType.video,
        );

        expect(source, isA<VideoNetworkMedia>());
        expect(source.name, equals('video.mp4'));
        expect(source.uri.toString(), equals('https://example.com/video.mp4'));
        expect(source.size, equals(1024000));
        expect(source.mimeType, equals('video/mp4'));
      });

      test('should create AudioNetworkMedia for audio URL', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/audio.mp3',
          name: 'audio.mp3',
          size: 512000.b,
          mimeType: 'audio/mp3',
          duration: const Duration(minutes: 3),
          mediaType: MediaType.audio,
        );

        expect(source, isA<AudioNetworkMedia>());
        expect(source.name, equals('audio.mp3'));
        expect(source.uri.toString(), equals('https://example.com/audio.mp3'));
      });

      test('should create ImageNetworkMedia for image URL', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/image.png',
          name: 'image.png',
          size: 204800.b,
          mimeType: 'image/png',
          mediaType: MediaType.image,
        );

        expect(source, isA<ImageNetworkMedia>());
        expect(source.name, equals('image.png'));
        expect(source.uri.toString(), equals('https://example.com/image.png'));
      });

      test('should create DocumentNetworkMedia for document URL', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/document.pdf',
          name: 'document.pdf',
          size: 1048576.b,
          mimeType: 'application/pdf',
          mediaType: MediaType.document,
        );

        expect(source, isA<DocumentNetworkMedia>());
        expect(source.name, equals('document.pdf'));
        expect(source.uri.toString(), equals('https://example.com/document.pdf'));
      });

      test('should create UnSupportedNetworkMedia for unknown URL', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/file.unknown',
          name: 'file.unknown',
          mediaType: MediaType.other,
        );

        expect(source, isA<UnSupportedNetworkMedia>());
        expect(source.name, equals('file.unknown'));
      });

      test('should auto-detect media type from URL when not provided', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video.mp4',
        );

        expect(source, isA<VideoNetworkMedia>());
      });

      test('should extract filename from URL when name not provided', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/path/to/video.mp4',
        );

        expect(source.name, equals('video.mp4'));
      });

      test('should use provided mimeType', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video',
          mimeType: 'video/mp4',
          mediaType: MediaType.video,
        );

        expect(source.mimeType, equals('video/mp4'));
      });
    });

    group('fromUrlOrNull', () {
      test('should return NetworkMediaSource for valid URL', () {
        final source = NetworkMediaSource.fromUrlOrNull(
          'https://example.com/video.mp4',
        );

        expect(source, isNotNull);
        expect(source, isA<NetworkMediaSource>());
      });

      test('should return null for null URL', () {
        final source = NetworkMediaSource.fromUrlOrNull(null);
        expect(source, isNull);
      });

      test('should return null for empty URL', () {
        final source = NetworkMediaSource.fromUrlOrNull('');
        expect(source, isNull);
      });

      test('should handle invalid URL gracefully', () {
        // This depends on implementation - might throw or return null
        expect(() => NetworkMediaSource.fromUrlOrNull('not a valid url'), returnsNormally);
      });
    });

    group('VideoNetworkMedia', () {
      test('should create with all properties', () {
        final duration = const Duration(seconds: 180);
        final video = VideoNetworkMedia(
          Uri.parse('https://example.com/video.mp4'),
          name: 'video.mp4',
          size: 2048000.b,
          mimeType: 'video/mp4',
          duration: duration,
        );

        expect(video.uri.toString(), equals('https://example.com/video.mp4'));
        expect(video.name, equals('video.mp4'));
        expect(video.size, equals(2048000));
        expect(video.metadata.duration, equals(duration));
        expect(video.mimeType, equals('video/mp4'));
        expect(video.thumbnail, isNull);
        expect(video.hasThumbnail, isFalse);
      });

      test('should support thumbnail', () {
        final thumbnail = ImageNetworkMedia(
          Uri.parse('https://example.com/thumb.jpg'),
          name: 'thumb.jpg',
        );

        final video = VideoNetworkMedia(
          Uri.parse('https://example.com/video.mp4'),
          name: 'video.mp4',
          thumbnail: thumbnail,
        );

        expect(video.thumbnail, equals(thumbnail));
        expect(video.hasThumbnail, isTrue);
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/video.mp4');
        final duration = const Duration(seconds: 60);

        final video1 = VideoNetworkMedia(uri, name: 'video.mp4', duration: duration, size: 1.kb);
        final video2 = VideoNetworkMedia(uri, name: 'video.mp4', duration: duration, size: 1.kb);
        final video3 = VideoNetworkMedia(uri, name: 'other.mp4', duration: duration, size: 1.kb);

        expect(video1, equals(video2));
        expect(video1, isNot(equals(video3)));
      });
    });

    group('AudioNetworkMedia', () {
      test('should create with all properties', () {
        final duration = const Duration(minutes: 4);
        final audio = AudioNetworkMedia(
          Uri.parse('https://example.com/audio.mp3'),
          name: 'audio.mp3',
          size: 4096000.mb,
          mimeType: 'audio/mp3',
          duration: duration,
        );

        expect(audio.uri.toString(), equals('https://example.com/audio.mp3'));
        expect(audio.name, equals('audio.mp3'));
        expect(audio.size, equals(4096000));
        expect(audio.metadata.duration, equals(duration));
        expect(audio.mimeType, equals('audio/mp3'));
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/audio.mp3');
        final duration = const Duration(seconds: 180);

        final audio1 = AudioNetworkMedia(uri, name: 'audio.mp3', duration: duration, size: 1.kb);
        final audio2 = AudioNetworkMedia(uri, name: 'audio.mp3', duration: duration, size: 1.kb);
        final audio3 = AudioNetworkMedia(uri, name: 'other.mp3', duration: duration, size: 1.kb);

        expect(audio1, equals(audio2));
        expect(audio1, isNot(equals(audio3)));
      });
    });

    group('ImageNetworkMedia', () {
      test('should create with all properties', () {
        final image = ImageNetworkMedia(
          Uri.parse('https://example.com/image.png'),
          name: 'image.png',
          size: 512000.b,
          mimeType: 'image/png',
        );

        expect(image.uri.toString(), equals('https://example.com/image.png'));
        expect(image.name, equals('image.png'));
        expect(image.size, equals(512000));
        expect(image.mimeType, equals('image/png'));
      });

      test('should support thumbnail', () {
        final thumbnail = ImageNetworkMedia(
          Uri.parse('https://example.com/thumb.jpg'),
          name: 'thumb.jpg',
        );

        final image = ImageNetworkMedia(
          Uri.parse('https://example.com/image.png'),
          name: 'image.png',
          thumbnail: thumbnail,
        );

        expect(image.thumbnail, equals(thumbnail));
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/image.png');

        final image1 = ImageNetworkMedia(uri, name: 'image.png', size: 1.kb);
        final image2 = ImageNetworkMedia(uri, name: 'image.png', size: 1.kb);
        final image3 = ImageNetworkMedia(uri, name: 'other.png', size: 1.kb);

        expect(image1, equals(image2));
        expect(image1, isNot(equals(image3)));
      });
    });

    group('DocumentNetworkMedia', () {
      test('should create with all properties', () {
        final doc = DocumentNetworkMedia(
          Uri.parse('https://example.com/document.pdf'),
          name: 'document.pdf',
          size: 2048000.b,
          mimeType: 'application/pdf',
        );

        expect(doc.uri.toString(), equals('https://example.com/document.pdf'));
        expect(doc.name, equals('document.pdf'));
        expect(doc.size, equals(2048000));
        expect(doc.mimeType, equals('application/pdf'));
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/doc.pdf');

        final doc1 = DocumentNetworkMedia(uri, name: 'doc.pdf', size: 1.kb);
        final doc2 = DocumentNetworkMedia(uri, name: 'doc.pdf', size: 1.kb);
        final doc3 = DocumentNetworkMedia(uri, name: 'other.pdf', size: 1.kb);

        expect(doc1, equals(doc2));
        expect(doc1, isNot(equals(doc3)));
      });
    });

    group('UnSupportedNetworkMedia', () {
      test('should create with all properties', () {
        final unsupported = UnSupportedNetworkMedia(
          Uri.parse('https://example.com/file.unknown'),
          name: 'file.unknown',
          size: 1024.b,
          mimeType: 'application/octet-stream',
        );

        expect(unsupported.uri.toString(), equals('https://example.com/file.unknown'));
        expect(unsupported.name, equals('file.unknown'));
        expect(unsupported.size, equals(1024));
        expect(unsupported.mimeType, equals('application/octet-stream'));
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/file.unknown');

        final unsupported1 = UnSupportedNetworkMedia(uri, name: 'file.unknown', size: 1024.b);
        final unsupported2 = UnSupportedNetworkMedia(uri, name: 'file.unknown', size: 1024.b);
        final unsupported3 = UnSupportedNetworkMedia(uri, name: 'other.unknown', size: 1024.b);

        expect(unsupported1, equals(unsupported2));
        expect(unsupported1, isNot(equals(unsupported3)));
      });
    });

    group('properties', () {
      test('should parse URI correctly', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com:8080/path/to/video.mp4?param=value',
        );

        expect(source.uri.scheme, equals('https'));
        expect(source.uri.host, equals('example.com'));
        expect(source.uri.port, equals(8080));
        expect(source.uri.path, contains('video.mp4'));
      });

      test('should extract extension from name', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video.mp4',
        );

        expect(source.ext, equals('mp4'));
      });
    });
  });
}
