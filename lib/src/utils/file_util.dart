import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart' as metadata;
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

class FileUtil {
  static const uuid = Uuid();
  static String? getMimeTypeFromPath(String path) => lookupMimeType(path);
  static String? getMimeTypeFromBytes(List<int> bytes) => lookupMimeType('test', headerBytes: bytes);

  static String getFileNameFromPath(String path) => path.split('/').last;

  static Future<MediaMetadata?> getFileMetadata(String path, MediaType mediaType) async {
    try {
      late final metadata.Metadata? result;
      if (kIsWeb) {
        result = await metadata.MetadataRetriever.fromBytes(await XFile(path).readAsBytes());
      } else {
        result = await metadata.MetadataRetriever.fromFile(File(path)).timeout(const Duration(seconds: 3));
      }
      return MediaMetadata(mimeType: result.mimeType, durationInMs: result.trackDuration);
    } catch (e) {
      return null;
    }
  }

  static Future<MediaMetadata?> getFileMetadataFromBytes(
    Uint8List bytes,
    MediaType mediaType,
    String? mimeType,
    String? fileName,
  ) async {
    try {
      late final metadata.Metadata? result;
      if (kIsWeb) {
        result = await metadata.MetadataRetriever.fromBytes(bytes);
      } else {
        final directory = await getTemporaryDirectory();
        final path = p.join(directory.path, fileName ?? uuid.v4());
        final xfile = XFile.fromData(bytes, name: path);
        await PlatformUtils.instance.ensureDirectoryExists(path);
        await xfile.saveTo(path);
        final file = File(path);
        if (Platform.isIOS) {
          await _deteteFile(file);
          return null;
        } else {
          result = await metadata.MetadataRetriever.fromFile(file).timeout(const Duration(seconds: 3));
        }
        await _deteteFile(file);
      }
      return MediaMetadata(mimeType: result.mimeType, durationInMs: result.trackDuration);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _deteteFile(File file) async {
    await file.delete();
  }
}

class MediaMetadata extends Equatable {
  final String? mimeType;
  final Duration? duration;

  const MediaMetadata._({this.mimeType, this.duration});
  factory MediaMetadata({String? mimeType, int? durationInMs}) => MediaMetadata._(
        mimeType: mimeType,
        duration: durationInMs != null ? Duration(milliseconds: durationInMs) : null,
      );

  @override
  List<Object?> get props => [mimeType, duration];
}
