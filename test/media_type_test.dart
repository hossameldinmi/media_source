import 'dart:typed_data';

import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/media_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileType', () {
    group('fromPath', () {
      test('should detect image from path', () {
        final mediaType = FileType.fromPath('test.jpg', null);
        expect(mediaType, FileType.image);
      });

      test('should detect video from path', () {
        final mediaType = FileType.fromPath('test.mp4', null);
        expect(mediaType, FileType.video);
      });

      test('should detect audio from path', () {
        final mediaType = FileType.fromPath('test.mp3', null);
        expect(mediaType, FileType.audio);
      });

      test('should detect document from path', () {
        final mediaType = FileType.fromPath('test.pdf', null);
        expect(mediaType, FileType.document);
      });

      test('should use mimeType when provided', () {
        final mediaType = FileType.fromPath('test.unknown', 'image/png');
        expect(mediaType, FileType.image);
      });

      test('should detect video from ism path', () {
        final mediaType = FileType.fromPath('test.ism/manifest', null);
        expect(mediaType, FileType.video);
      }, skip: 'ISM detection not implemented'); // Skipped as ISM detection is not implemented

      test('should detect video from m3u8 (mpegurl)', () {
        final mediaType = FileType.fromPath('test.m3u8', null);
        expect(mediaType, FileType.video);
      });
    });

    group('fromBytes', () {
      test('should detect type from bytes with mimeType', () {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
        final mediaType = FileType.fromBytes(bytes, 'image/png');
        expect(mediaType, FileType.image);
      });

      test('should detect image from PNG signature', () {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
        final mediaType = FileType.fromBytes(bytes, 'image/png');
        expect(mediaType, FileType.image);
      });

      test('should detect image from JPEG signature', () {
        final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
        final mediaType = FileType.fromBytes(bytes, 'image/jpeg');
        expect(mediaType, FileType.image);
      });
    });

    group('isAny', () {
      test('should return true when type is in list', () {
        expect(FileType.image.isAny([FileType.image, FileType.video]), isTrue);
        expect(FileType.audio.isAny([FileType.audio]), isTrue);
      });

      test('should return false when type is not in list', () {
        expect(FileType.image.isAny([FileType.audio, FileType.video]), isFalse);
        expect(FileType.document.isAny([FileType.image]), isFalse);
      });
    });

    group('when', () {
      test('should call image callback for ImageType', () {
        final imageType = ImageType();
        final result = imageType.fold(
          image: (_) => 'image',
          orElse: () => 'other',
        );
        expect(result, 'image');
      });

      test('should call audio callback for AudioType', () {
        final audioType = AudioType();
        final result = audioType.fold(
          audio: (_) => 'audio',
          orElse: () => 'other',
        );
        expect(result, 'audio');
      });

      test('should call video callback for VideoType', () {
        final videoType = VideoType();
        final result = videoType.fold(
          video: (_) => 'video',
          orElse: () => 'other',
        );
        expect(result, 'video');
      });

      test('should call document callback for DocumentType', () {
        final documentType = DocumentType();
        final result = documentType.fold(
          document: (_) => 'document',
          orElse: () => 'other',
        );
        expect(result, 'document');
      });

      test('should call orElse when no callback matches', () {
        final imageType = ImageType();
        final result = imageType.fold(
          audio: (_) => 'audio',
          orElse: () => 'other',
        );
        expect(result, 'other');
      });

      test('should call url callback for UrlType', () {
        final urlType = UrlType();
        final result = urlType.fold(
          url: (_) => 'url',
          orElse: () => 'other',
        );
        expect(result, 'url');
      });
    });
  });

  group('VideoType', () {
    test('should create with duration', () {
      final duration = const Duration(seconds: 120);
      final videoType = VideoType(duration);
      expect(videoType.duration, duration);
    });

    test('should create without duration', () {
      final videoType = VideoType();
      expect(videoType.duration, isNull);
    });

    test('should be equatable', () {
      final video1 = VideoType(const Duration(seconds: 60));
      final video2 = VideoType(const Duration(seconds: 60));
      final video3 = VideoType(const Duration(seconds: 120));

      expect(video1, video2);
      expect(video1, isNot(video3));
    });
  });

  group('AudioType', () {
    test('should create with duration', () {
      final duration = const Duration(seconds: 180);
      final audioType = AudioType(duration);
      expect(audioType.duration, duration);
    });

    test('should create without duration', () {
      final audioType = AudioType();
      expect(audioType.duration, isNull);
    });

    test('should be equatable', () {
      final audio1 = AudioType(const Duration(seconds: 60));
      final audio2 = AudioType(const Duration(seconds: 60));
      final audio3 = AudioType(const Duration(seconds: 120));

      expect(audio1, audio2);
      expect(audio1, isNot(audio3));
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
      expect(image1, image2);
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
      expect(doc1, doc2);
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
      expect(url1, url2);
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
      expect(unsupported1, unsupported2);
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
