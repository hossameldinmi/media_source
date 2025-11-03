import 'dart:typed_data';

import 'package:media_source/src/media_type.dart';
import 'package:test/test.dart';

void main() {
  group('MediaType', () {
    group('constants', () {
      test('should have correct values', () {
        expect(MediaType.image, isA<MediaType>());
        expect(MediaType.audio, isA<MediaType>());
        expect(MediaType.video, isA<MediaType>());
        expect(MediaType.document, isA<MediaType>());
        expect(MediaType.url, isA<MediaType>());
        expect(MediaType.other, isA<MediaType>());
      });

      test('should be equatable', () {
        expect(MediaType.image, equals(MediaType.image));
        expect(MediaType.audio, equals(MediaType.audio));
        expect(MediaType.image, isNot(equals(MediaType.audio)));
      });
    });

    group('fromPath', () {
      test('should detect image from path', () {
        final mediaType = MediaType.fromPath('test.jpg', null);
        expect(mediaType, equals(MediaType.image));
      });

      test('should detect video from path', () {
        final mediaType = MediaType.fromPath('test.mp4', null);
        expect(mediaType, equals(MediaType.video));
      });

      test('should detect audio from path', () {
        final mediaType = MediaType.fromPath('test.mp3', null);
        expect(mediaType, equals(MediaType.audio));
      });

      test('should detect document from path', () {
        final mediaType = MediaType.fromPath('test.pdf', null);
        expect(mediaType, equals(MediaType.document));
      });

      test('should use mimeType when provided', () {
        final mediaType = MediaType.fromPath('test.unknown', 'image/png');
        expect(mediaType, equals(MediaType.image));
      });

      test('should detect video from ism path', () {
        final mediaType = MediaType.fromPath('test.ism/manifest', null);
        expect(mediaType, equals(MediaType.video));
      });

      test('should detect video from m3u8 (mpegurl)', () {
        final mediaType = MediaType.fromPath('test.m3u8', null);
        expect(mediaType, equals(MediaType.video));
      });
    });

    group('fromBytes', () {
      test('should detect type from bytes with mimeType', () {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
        final mediaType = MediaType.fromBytes(bytes, 'image/png');
        expect(mediaType, equals(MediaType.image));
      });

      test('should detect image from PNG signature', () {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
        final mediaType = MediaType.fromBytes(bytes, 'image/png');
        expect(mediaType, equals(MediaType.image));
      });

      test('should detect image from JPEG signature', () {
        final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
        final mediaType = MediaType.fromBytes(bytes, 'image/jpeg');
        expect(mediaType, equals(MediaType.image));
      });
    });

    group('isAny', () {
      test('should return true when type is in list', () {
        expect(MediaType.image.isAny([MediaType.image, MediaType.video]), isTrue);
        expect(MediaType.audio.isAny([MediaType.audio]), isTrue);
      });

      test('should return false when type is not in list', () {
        expect(MediaType.image.isAny([MediaType.audio, MediaType.video]), isFalse);
        expect(MediaType.document.isAny([MediaType.image]), isFalse);
      });
    });

    group('when', () {
      test('should call image callback for ImageType', () {
        final imageType = ImageType();
        final result = imageType.when(
          image: (_) => 'image',
          orElse: () => 'other',
        );
        expect(result, equals('image'));
      });

      test('should call audio callback for AudioType', () {
        final audioType = AudioType();
        final result = audioType.when(
          audio: (_) => 'audio',
          orElse: () => 'other',
        );
        expect(result, equals('audio'));
      });

      test('should call video callback for VideoType', () {
        final videoType = VideoType();
        final result = videoType.when(
          video: (_) => 'video',
          orElse: () => 'other',
        );
        expect(result, equals('video'));
      });

      test('should call orElse when no callback matches', () {
        final imageType = ImageType();
        final result = imageType.when(
          audio: (_) => 'audio',
          orElse: () => 'other',
        );
        expect(result, equals('other'));
      });
    });
  });

  group('VideoType', () {
    test('should create with duration', () {
      final duration = const Duration(seconds: 120);
      final videoType = VideoType(duration);
      expect(videoType.duration, equals(duration));
    });

    test('should create without duration', () {
      final videoType = VideoType();
      expect(videoType.duration, isNull);
    });

    test('should be equatable', () {
      final video1 = VideoType(const Duration(seconds: 60));
      final video2 = VideoType(const Duration(seconds: 60));
      final video3 = VideoType(const Duration(seconds: 120));

      expect(video1, equals(video2));
      expect(video1, isNot(equals(video3)));
    });
  });

  group('AudioType', () {
    test('should create with duration', () {
      final duration = const Duration(seconds: 180);
      final audioType = AudioType(duration);
      expect(audioType.duration, equals(duration));
    });

    test('should create without duration', () {
      final audioType = AudioType();
      expect(audioType.duration, isNull);
    });

    test('should be equatable', () {
      final audio1 = AudioType(const Duration(seconds: 60));
      final audio2 = AudioType(const Duration(seconds: 60));
      final audio3 = AudioType(const Duration(seconds: 120));

      expect(audio1, equals(audio2));
      expect(audio1, isNot(equals(audio3)));
    });
  });

  group('ImageType', () {
    test('should create instance', () {
      final imageType = ImageType();
      expect(imageType, isA<ImageType>());
    });

    test('should be equatable', () {
      final image1 = ImageType();
      final image2 = ImageType();
      expect(image1, equals(image2));
    });
  });

  group('DocumentType', () {
    test('should create instance', () {
      final docType = DocumentType();
      expect(docType, isA<DocumentType>());
    });

    test('should be equatable', () {
      final doc1 = DocumentType();
      final doc2 = DocumentType();
      expect(doc1, equals(doc2));
    });
  });

  group('UrlType', () {
    test('should create instance', () {
      final urlType = UrlType();
      expect(urlType, isA<UrlType>());
    });

    test('should be equatable', () {
      final url1 = UrlType();
      final url2 = UrlType();
      expect(url1, equals(url2));
    });
  });

  group('UnSupportedType', () {
    test('should create instance', () {
      final unsupportedType = OtherType();
      expect(unsupportedType, isA<OtherType>());
    });

    test('should be equatable', () {
      final unsupported1 = OtherType();
      final unsupported2 = OtherType();
      expect(unsupported1, equals(unsupported2));
    });
  });

  group('isAnyType', () {
    test('should return true when runtime type is in list', () {
      final imageType = ImageType();
      expect(imageType.isAnyType([ImageType, VideoType]), isTrue);
    });

    test('should return false when runtime type is not in list', () {
      final imageType = ImageType();
      expect(imageType.isAnyType([AudioType, VideoType]), isFalse);
    });
  });
}
