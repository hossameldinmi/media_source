import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:equatable/equatable.dart';

import 'platform_utils/platform_utils_io.dart' if (dart.library.html) 'platform_utils_web.dart';

class PlatformUtils {
  static final _instance = PlatformUtilsFacadeImpl();
  static PlatformUtilsFacade get instance => _instance;
}

abstract class PlatformUtilsFacade {
  Future<bool> deleteFile(XFile file);
  Future<void> createDirectoryIfNotExists(String directoryPath);
  Future<bool> directoryExists(String directoryPath);
  Future<bool> deleteDirectory(String directoryPath);

  Future<bool> fileExists(XFile xFile);
  Future<MediaMetadata?> getMediaMetadata(XFile xFile);
  Future<MediaMetadata?> getMediaMetadataFromBytes(Uint8List bytes, [String? fileName]);
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
