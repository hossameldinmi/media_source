import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/utils/platform_utils.dart';

class PlatformUtilsFacadeImpl implements PlatformUtilsFacade {
  @override
  Future<bool> deleteFile(XFile file) async {
    try {
      if (!await fileExists(file)) return false;

      final fileToDelete = File(file.path);
      await fileToDelete.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath).parent;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  @override
  Future<bool> fileExists(XFile file) async {
    try {
      final path = file.path;
      if (path.isEmpty) return false; // If path is empty, the file cannot exist
      return File(path).exists();
    } catch (e) {
      return false;
    }
  }
}
