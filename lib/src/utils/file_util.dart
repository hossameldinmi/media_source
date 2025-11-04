import 'package:cross_file/cross_file.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:uuid/uuid.dart';

class FileUtil {
  static const uuid = Uuid();

  static String getFileNameFromPath(String path) => path.split('/').last;

  static Future<MediaMetadata?> getFileMetadata(XFile file, FileType mediaType) =>
      PlatformUtils.instance.getMediaMetadata(file);

  static Future<MediaMetadata?> getFileMetadataFromBytes(Uint8List bytes, String? fileName) =>
      PlatformUtils.instance.getMediaMetadataFromBytes(bytes, fileName);
}
