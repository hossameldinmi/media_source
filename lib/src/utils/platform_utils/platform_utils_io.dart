import 'dart:io';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart' as metadata;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PlatformUtilsFacadeImpl implements PlatformUtilsFacade {
  static const uuid = Uuid();
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
  Future<void> createDirectoryIfNotExists(String directoryPath) async {
    final directory = Directory(directoryPath).parent;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  @override
  Future<bool> directoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    return directory.exists();
  }

  @override
  Future<bool> deleteDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) return false;

      directory.deleteSync(recursive: true);
      return true;
    } catch (e) {
      return false;
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

  @override
  Future<MediaMetadata?> getMediaMetadata(XFile xFile) async {
    final result = await metadata.MetadataRetriever.fromFile(File(xFile.path)).timeout(const Duration(seconds: 3));
    return MediaMetadata(mimeType: result.mimeType, durationInMs: result.trackDuration);
  }

  @override
  Future<MediaMetadata?> getMediaMetadataFromBytes(Uint8List bytes, [String? fileName]) async {
    late final metadata.Metadata? result;
    if (Platform.isIOS) {
      return null;
    } else {
      final directory = await getTemporaryDirectory();
      final path = p.join(directory.path, fileName ?? uuid.v4());
      final xfile = XFile.fromData(bytes, name: path);
      await PlatformUtils.instance.createDirectoryIfNotExists(path);
      await xfile.saveTo(path);
      final file = File(path);
      result = await metadata.MetadataRetriever.fromFile(file).timeout(const Duration(seconds: 3));
      await _deteteFile(file);
      return MediaMetadata(mimeType: result.mimeType, durationInMs: result.trackDuration);
    }
  }

  Future<void> _deteteFile(File file) async {
    await file.delete();
  }
}
