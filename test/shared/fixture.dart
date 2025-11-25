// ignore_for_file: non_constant_identifier_names

import 'package:cross_file/cross_file.dart';
import 'package:file_sized/file_sized.dart';

class Fixture {
  static const pathes = Pathes();

  /// size: 13928213 bytes
  static final sample_image = AssetData.path(
    pathes.sample_image,
    481391.b,
    'image/jpeg',
  );

  /// size: 1763570 bytes
  /// mimeType: video/mp4
  /// duration: 15651 ms, 15 s 651 ms
  static final sample_video = AssetData.path(
    pathes.sample_video,
    1763570.b,
    'video/mp4',
    Duration(milliseconds: 15651),
  );

  /// size: 820 KiB
  /// mimeType: audio/mpeg
  /// duration: 51905 ms, 51 s 905 ms
  static final sample_audio = AssetData.path(
    pathes.sample_audio,
    839530.b,
    'audio/mpeg',
    Duration(milliseconds: 51905),
  );
  static final sample_doc = AssetData.path(
    pathes.sample_document,
    142786.b,
    'application/pdf',
  );
  static final sample_unknown_file = AssetData.path(
    pathes.sample_unknown_file,
    3.b,
    'application/x-sh',
  );
}

class AssetData {
  final XFile file;
  final FileSize size;
  final String mimeType;
  final Duration? duration;

  AssetData.path(
    String path,
    this.size,
    this.mimeType, [
    this.duration,
  ]) : file = XFile(path);
}

class Pathes {
  final sample_image = 'test/assets/sample_image.jpg';
  final sample_video = 'test/assets/sample_video.mp4';
  final sample_audio = 'test/assets/sample_audio.mp3';
  final sample_document = 'test/assets/sample_document.pdf';
  final sample_unknown_file = 'test/assets/sample_unknown_file.sh';
  const Pathes();
}
