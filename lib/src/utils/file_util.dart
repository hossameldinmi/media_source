import 'package:cross_file/cross_file.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class FileUtil {
  static const uuid = Uuid();

  static String getFileNameFromPath(String path) => path.split('/').last;

  static Future<FileType> fileTypeFromFile(XFile file, String? mimeType) async {
    return kIsWeb ? FileType.fromBytes(await file.readAsBytes(), mimeType) : FileType.fromPath(file.path, mimeType);
  }
}
