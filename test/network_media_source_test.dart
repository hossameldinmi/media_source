import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/network_media_source.dart';
import 'package:sized_file/sized_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkMediaSource', () {
    group('fromUrl', () {
      test('should create VideoNetworkMedia for video URL', () {
        final size = 1024000.b;
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video.mp4',
          name: 'video.mp4',
          size: size,
          mimeType: 'video/mp4',
          duration: const Duration(seconds: 120),
          mediaType: FileType.video,
        );

        expect(source, isA<VideoNetworkMedia>());
        expect(source.name, 'video.mp4');
        expect(source.uri.toString(), 'https://example.com/video.mp4');
        expect(source.size, size);
        expect(source.mimeType, 'video/mp4');
      });

      test('should create AudioNetworkMedia for audio URL', () {
        final size = 512000.b;
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/audio.mp3',
          name: 'audio.mp3',
          size: size,
          mimeType: 'audio/mp3',
          duration: const Duration(minutes: 3),
          mediaType: FileType.audio,
        );

        expect(source, isA<AudioNetworkMedia>());
        expect(source.name, 'audio.mp3');
        expect(source.uri.toString(), 'https://example.com/audio.mp3');
      });

      test('should create ImageNetworkMedia for image URL', () {
        final size = 204800.b;
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/image.png',
          name: 'image.png',
          size: size,
          mimeType: 'image/png',
          mediaType: FileType.image,
        );

        expect(source, isA<ImageNetworkMedia>());
        expect(source.name, 'image.png');
        expect(source.uri.toString(), 'https://example.com/image.png');
      });

      test('should create DocumentNetworkMedia for document URL', () {
        final size = 1048576.b;
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/document.pdf',
          name: 'document.pdf',
          size: size,
          mimeType: 'application/pdf',
          mediaType: FileType.document,
        );

        expect(source, isA<DocumentNetworkMedia>());
        expect(source.name, 'document.pdf');
        expect(source.uri.toString(), 'https://example.com/document.pdf');
      });

      test('should create UnSupportedNetworkMedia for unknown URL', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/file.unknown',
          name: 'file.unknown',
          mediaType: FileType.other,
        );

        expect(source, isA<UnSupportedNetworkMedia>());
        expect(source.name, 'file.unknown');
      });

      test('should auto-detect media type from URL when not provided', () {
        final source1 = NetworkMediaSource.fromUrl('https://example.com/video.mp4');
        final source2 = NetworkMediaSource.fromUrl('https://example.com/audio.mp3');
        final source3 = NetworkMediaSource.fromUrl('https://example.com/image.jpg');
        final source4 = NetworkMediaSource.fromUrl('https://example.com/doc.pdf');
        final source5 = NetworkMediaSource.fromUrl('https://example.com');

        expect(source1, isA<VideoNetworkMedia>());
        expect(source1.name, 'video.mp4');

        expect(source2, isA<AudioNetworkMedia>());
        expect(source2.name, 'audio.mp3');

        expect(source3, isA<ImageNetworkMedia>());
        expect(source3.name, 'image.jpg');

        expect(source4, isA<DocumentNetworkMedia>());
        expect(source4.name, 'doc.pdf');

        expect(source5, isA<UnSupportedNetworkMedia>());
      });

      test('should use provided mimeType', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video',
          mimeType: 'video/mp4',
          mediaType: FileType.video,
        );

        expect(source.mimeType, 'video/mp4');
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
        final size = 2048000.b;
        final duration = const Duration(seconds: 180);
        final video = VideoNetworkMedia(
          Uri.parse('https://example.com/video.mp4'),
          name: 'video.mp4',
          size: size,
          mimeType: 'video/mp4',
          duration: duration,
        );

        expect(video.uri.toString(), 'https://example.com/video.mp4');
        expect(video.name, 'video.mp4');
        expect(video.size, size);
        expect(video.metadata.duration, duration);
        expect(video.mimeType, 'video/mp4');
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/video.mp4');
        final duration = const Duration(seconds: 60);

        final video1 = VideoNetworkMedia(uri, name: 'video.mp4', duration: duration, size: 1.kb);
        final video2 = VideoNetworkMedia(uri, name: 'video.mp4', duration: duration, size: 1.kb);
        final video3 = VideoNetworkMedia(uri, name: 'other.mp4', duration: duration, size: 1.kb);

        expect(video1, video2);
        expect(video1, isNot(video3));
      });

      test('should create from url string using .url constructor', () {
        final duration = const Duration(seconds: 120);
        final size = 2048000.b;
        final video = VideoNetworkMedia.url(
          'https://example.com/video.mp4',
          name: 'video.mp4',
          duration: duration,
          size: size,
          mimeType: 'video/mp4',
        );

        expect(video.uri.toString(), 'https://example.com/video.mp4');
        expect(video.name, 'video.mp4');
        expect(video.metadata.duration, duration);
        expect(video.size, size);
        expect(video.mimeType, 'video/mp4');
      });
    });

    group('AudioNetworkMedia', () {
      test('should create with all properties', () {
        final size = 4096000.mb;
        final duration = const Duration(minutes: 4);
        final audio = AudioNetworkMedia(
          Uri.parse('https://example.com/audio.mp3'),
          name: 'audio.mp3',
          size: size,
          mimeType: 'audio/mp3',
          duration: duration,
        );

        expect(audio.uri.toString(), 'https://example.com/audio.mp3');
        expect(audio.name, 'audio.mp3');
        expect(audio.size, size);
        expect(audio.metadata.duration, duration);
        expect(audio.mimeType, 'audio/mp3');
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/audio.mp3');
        final duration = const Duration(seconds: 180);

        final audio1 = AudioNetworkMedia(uri, name: 'audio.mp3', duration: duration, size: 1.kb);
        final audio2 = AudioNetworkMedia(uri, name: 'audio.mp3', duration: duration, size: 1.kb);
        final audio3 = AudioNetworkMedia(uri, name: 'other.mp3', duration: duration, size: 1.kb);

        expect(audio1, audio2);
        expect(audio1, isNot(audio3));
      });

      test('should create from url string using .url constructor', () {
        final duration = const Duration(minutes: 3);
        final size = 4096000.b;
        final audio = AudioNetworkMedia.url(
          'https://example.com/audio.mp3',
          name: 'audio.mp3',
          duration: duration,
          size: size,
          mimeType: 'audio/mp3',
        );

        expect(audio.uri.toString(), 'https://example.com/audio.mp3');
        expect(audio.name, 'audio.mp3');
        expect(audio.metadata.duration, duration);
        expect(audio.size, size);
        expect(audio.mimeType, 'audio/mp3');
      });
    });

    group('ImageNetworkMedia', () {
      test('should create with all properties', () {
        final size = 512000.b;
        final image = ImageNetworkMedia(
          Uri.parse('https://example.com/image.png'),
          name: 'image.png',
          size: size,
          mimeType: 'image/png',
        );

        expect(image.uri.toString(), 'https://example.com/image.png');
        expect(image.name, 'image.png');
        expect(image.size, size);
        expect(image.mimeType, 'image/png');
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/image.png');

        final image1 = ImageNetworkMedia(uri, name: 'image.png', size: 1.kb);
        final image2 = ImageNetworkMedia(uri, name: 'image.png', size: 1.kb);
        final image3 = ImageNetworkMedia(uri, name: 'other.png', size: 1.kb);

        expect(image1, image2);
        expect(image1, isNot(image3));
      });

      test('should create from url string using .url constructor', () {
        final size = 512000.b;
        final image = ImageNetworkMedia.url(
          'https://example.com/image.png',
          name: 'image.png',
          size: size,
          mimeType: 'image/png',
        );

        expect(image.uri.toString(), 'https://example.com/image.png');
        expect(image.name, 'image.png');
        expect(image.size, size);
        expect(image.mimeType, 'image/png');
      });
    });

    group('DocumentNetworkMedia', () {
      test('should create with all properties', () {
        final size = 2048000.b;
        final doc = DocumentNetworkMedia(
          Uri.parse('https://example.com/document.pdf'),
          name: 'document.pdf',
          size: size,
          mimeType: 'application/pdf',
        );

        expect(doc.uri.toString(), 'https://example.com/document.pdf');
        expect(doc.name, 'document.pdf');
        expect(doc.size, size);
        expect(doc.mimeType, 'application/pdf');
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/doc.pdf');

        final doc1 = DocumentNetworkMedia(uri, name: 'doc.pdf', size: 1.kb);
        final doc2 = DocumentNetworkMedia(uri, name: 'doc.pdf', size: 1.kb);
        final doc3 = DocumentNetworkMedia(uri, name: 'other.pdf', size: 1.kb);

        expect(doc1, doc2);
        expect(doc1, isNot(doc3));
      });

      test('should create from url string using .url constructor', () {
        final size = 2048000.b;
        final doc = DocumentNetworkMedia.url(
          'https://example.com/document.pdf',
          name: 'document.pdf',
          size: size,
          mimeType: 'application/pdf',
        );

        expect(doc.uri.toString(), 'https://example.com/document.pdf');
        expect(doc.name, 'document.pdf');
        expect(doc.size, size);
        expect(doc.mimeType, 'application/pdf');
      });
    });

    group('UnSupportedNetworkMedia', () {
      test('should create with all properties', () {
        final size = 1024.b;
        final unsupported = UnSupportedNetworkMedia(
          Uri.parse('https://example.com/file.unknown'),
          name: 'file.unknown',
          size: size,
          mimeType: 'application/octet-stream',
        );

        expect(unsupported.uri.toString(), 'https://example.com/file.unknown');
        expect(unsupported.name, 'file.unknown');
        expect(unsupported.size, size);
        expect(unsupported.mimeType, 'application/octet-stream');
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/file.unknown');

        final unsupported1 = UnSupportedNetworkMedia(uri, name: 'file.unknown', size: 1024.b);
        final unsupported2 = UnSupportedNetworkMedia(uri, name: 'file.unknown', size: 1024.b);
        final unsupported3 = UnSupportedNetworkMedia(uri, name: 'other.unknown', size: 1024.b);

        expect(unsupported1, unsupported2);
        expect(unsupported1, isNot(unsupported3));
      });
    });

    group('UrlMedia', () {
      test('should create with Uri constructor', () {
        final urlMedia = UrlMedia(
          Uri.parse('https://example.com/file.dat'),
        );

        expect(urlMedia.uri.toString(), 'https://example.com/file.dat');
        expect(urlMedia.size, 0.b);
        expect(urlMedia.mimeType, 'url');
        expect(urlMedia.metadata, isA<UrlType>());
      });

      test('should create from url string using .url constructor', () {
        final urlMedia = UrlMedia.url(
          'https://example.com/data.bin',
        );

        expect(urlMedia.uri.toString(), 'https://example.com/data.bin');
        expect(urlMedia.size, 0.b);
        expect(urlMedia.mimeType, 'url');
        expect(urlMedia.metadata, isA<UrlType>());
      });

      test('should be equatable', () {
        final uri = Uri.parse('https://example.com/file.dat');

        final url1 = UrlMedia(uri);
        final url2 = UrlMedia(uri);
        final url3 = UrlMedia(Uri.parse('https://example.com/other.dat'));

        expect(url1, url2);
        expect(url1, isNot(url3));
      });

      test('should override props to use uri and metadata', () {
        final urlMedia = UrlMedia(Uri.parse('https://example.com/test.dat'));

        expect(urlMedia.props, [urlMedia.uri, urlMedia.metadata]);
      });
    });

    group('properties', () {
      test('should parse URI correctly', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com:8080/path/to/video.mp4?param=value',
        );

        expect(source.uri.scheme, 'https');
        expect(source.uri.host, 'example.com');
        expect(source.uri.port, 8080);
        expect(source.uri.path, contains('video.mp4'));
      });

      test('should extract extension from name', () {
        final source = NetworkMediaSource.fromUrl(
          'https://example.com/video.mp4',
        );

        expect(source.extension, '.mp4');
      });
    });
  });
}
