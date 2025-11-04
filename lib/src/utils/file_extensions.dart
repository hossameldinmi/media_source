import 'dart:async';
import 'package:cross_file/cross_file.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:sized_file/sized_file.dart';

extension FileExtensions on XFile {
  Future<bool> delete() async {
    if (await exists()) return PlatformUtils.instance.deleteFile(this);
    return false;
  }

  Future<SizedFile> size() => length().then((v) => v.b);
  Future<bool> exists() => PlatformUtils.instance.fileExists(this);

  FileType get mediaType => FileType.fromPath(path, mimeType);
  String? get name => path.split('/').last;
}
