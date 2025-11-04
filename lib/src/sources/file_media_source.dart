import 'dart:developer';
import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/utils/file_extensions.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:path/path.dart' as p;
import 'package:sized_file/sized_file.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/utils/file_util.dart' as file_util;

abstract class FileMediaSource<M extends FileType> extends MediaSource<M> implements ToMemoryConvertableMedia<M> {
  final XFile file;

  FileMediaSource._({
    required this.file,
    required super.metadata,
    required String? name,
    required super.size,
    required String? mimeType,
  }) : super(
          mimeType: mimeType ?? file.mimeType ?? FileUtil.getMimeTypeFromPath(file.path),
          name: name ?? file.name,
        );

  Future<FileMediaSource<M>> saveTo(String path);
  Future<FileMediaSource<M>> saveToFolder(String folderPath) => saveTo(p.join(folderPath, name));
  Future<FileMediaSource<M>> moveTo(String path) async {
    if (file.path == path) return this;
    final newPathFile = XFile(path);
    if (await newPathFile.exists()) {
      await newPathFile.delete();
    }
    final saved = await saveTo(path);
    await delete();
    return saved;
  }

  Future<FileMediaSource<M>> moveToFolder(String folderPath) => moveTo(p.join(folderPath, name));

  Future<bool> delete() => file.delete();

  static Future<FileMediaSource> fromPath(
    String path, {
    String? name,
    SizedFile? size,
    String? mimeType,
    Duration? duration,
    FileType? mediaType,
  }) =>
      fromFile(
        XFile(
          path,
          mimeType: mimeType,
          length: size?.inBytes,
        ),
        name: name,
        mimeType: mimeType,
        duration: duration,
        mediaType: mediaType,
        size: size,
      );

  static Future<FileMediaSource> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    Duration? duration,
    FileType? mediaType,
    SizedFile? size,
  }) async {
    mediaType ??= await file_util.FileUtil.fileTypeFromFile(file, mimeType);
    if (mediaType.isAny([FileType.audio])) {
      return AudioFileMedia.fromFile(
        file,
        name: name,
        duration: duration,
        mimeType: mimeType,
        size: size,
      );
    }
    if (mediaType.isAny([FileType.video])) {
      return VideoFileMedia.fromFile(
        file,
        name: name,
        duration: duration,
        mimeType: mimeType,
        size: size,
      );
    }
    if (mediaType.isAny([FileType.image])) {
      return ImageFileMedia.fromFile(
        file,
        name: name,
        mimeType: mimeType,
        size: size,
      );
    }
    if (mediaType.isAny([FileType.document])) {
      return DocumentFileMedia.fromFile(
        file,
        name: name,
        mimeType: mimeType,
        size: size,
      );
    }
    return OtherTypeFileMedia.fromFile(
      file,
      name: name,
      mimeType: mimeType,
      size: size,
    );
  }

  @override
  List<Object?> get props => [file, ...super.props];
}

class VideoFileMedia extends FileMediaSource<VideoType> {
  VideoFileMedia._({
    required super.file,
    required super.name,
    required Duration? duration,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: VideoType(duration));
  static Future<VideoFileMedia> fromPath(
    String path, {
    String? name,
    Duration? duration,
    String? mimeType,
    SizedFile? size,
  }) async {
    final file = XFile(
      path,
      name: name,
      mimeType: mimeType,
      length: size?.inBytes,
    );
    return fromFile(
      file,
      name: name,
      duration: duration,
      mimeType: mimeType,
      size: size,
    );
  }

  static Future<VideoFileMedia> fromFile(
    XFile file, {
    String? name,
    Duration? duration,
    String? mimeType,
    SizedFile? size,
  }) async {
    try {
      size ??= await file.size();
    } catch (e) {
      log('Failed to get file length: $e');
    }
    return VideoFileMedia._(
      file: file,
      size: size,
      name: name,
      duration: duration,
      mimeType: mimeType,
    );
  }

  @override
  Future<VideoFileMedia> saveTo(String path) async {
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return VideoFileMedia._(
      file: XFile(path, name: name, mimeType: mimeType),
      size: size ?? await file.size(),
      name: name,
      duration: metadata.duration,
      mimeType: mimeType,
    );
  }

  @override
  Future<MemoryMediaSource<VideoType>> convertToMemory() async {
    return VideoMemoryMedia(
      await file.readAsBytes(),
      name: name,
      duration: metadata.duration,
      mimeType: mimeType,
    );
  }
}

class AudioFileMedia extends FileMediaSource<AudioType> {
  AudioFileMedia._({
    required super.file,
    required super.name,
    required Duration? duration,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: AudioType(duration));

  static Future<AudioFileMedia> fromPath(
    String path, {
    String? name,
    Duration? duration,
    String? mimeType,
    SizedFile? size,
  }) async {
    final file = XFile(
      path,
      mimeType: mimeType,
      name: name,
      length: size?.inBytes,
    );
    return fromFile(
      file,
      name: name,
      duration: duration,
      mimeType: mimeType,
      size: size,
    );
  }

  static Future<AudioFileMedia> fromFile(
    XFile file, {
    String? name,
    Duration? duration,
    String? mimeType,
    SizedFile? size,
  }) async {
    return AudioFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      duration: duration,
      mimeType: mimeType,
    );
  }

  @override
  Future<AudioFileMedia> saveTo(String path) async {
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return AudioFileMedia._(
      file: XFile(
        path,
        name: super.name,
        mimeType: super.mimeType,
        length: size?.inBytes,
      ),
      size: size ?? await file.size(),
      name: name,
      duration: metadata.duration,
      mimeType: mimeType,
    );
  }

  @override
  Future<MemoryMediaSource<AudioType>> convertToMemory() async {
    return AudioMemoryMedia(
      await file.readAsBytes(),
      name: name,
      duration: metadata.duration,
      mimeType: mimeType,
    );
  }
}

class ImageFileMedia extends FileMediaSource<ImageType> {
  ImageFileMedia._({
    required super.file,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: ImageType());
  static Future<ImageFileMedia> fromPath(
    String path, {
    String? name,
    String? mimeType,
    SizedFile? size,
  }) async {
    final file = XFile(
      path,
      name: name,
      mimeType: mimeType,
      length: size?.inBytes,
    );
    return fromFile(
      file,
      name: name,
      mimeType: mimeType,
      size: size,
    );
  }

  static Future<ImageFileMedia> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    SizedFile? size,
  }) async {
    return ImageFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<ImageFileMedia> saveTo(String path) async {
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return ImageFileMedia._(
      file: XFile(
        path,
        name: super.name,
        mimeType: super.mimeType,
        length: size?.inBytes,
      ),
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<MemoryMediaSource<ImageType>> convertToMemory() async {
    return ImageMemoryMedia(
      await file.readAsBytes(),
      name: name,
      mimeType: mimeType,
    );
  }
}

class DocumentFileMedia extends FileMediaSource<DocumentType> {
  DocumentFileMedia._({
    required super.file,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: DocumentType());
  static Future<DocumentFileMedia> fromPath(
    String path, {
    String? name,
    String? mimeType,
    SizedFile? size,
  }) async {
    final file = XFile(
      path,
      name: name,
      mimeType: mimeType,
      length: size?.inBytes,
    );
    return fromFile(
      file,
      name: name,
      mimeType: mimeType,
      size: size,
    );
  }

  static Future<DocumentFileMedia> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    SizedFile? size,
  }) async {
    return DocumentFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<DocumentFileMedia> saveTo(String path) async {
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return DocumentFileMedia._(
      file: XFile(
        path,
        name: super.name,
        mimeType: super.mimeType,
        length: size?.inBytes,
      ),
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<MemoryMediaSource<DocumentType>> convertToMemory() async {
    return DocumentMemoryMedia(
      await file.readAsBytes(),
      name: name,
      mimeType: mimeType,
    );
  }
}

class OtherTypeFileMedia extends FileMediaSource<OtherType> {
  @override
  OtherTypeFileMedia._({
    required super.file,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: OtherType());
  static Future<OtherTypeFileMedia> fromPath(
    String path, {
    String? name,
    String? mimeType,
    SizedFile? size,
  }) {
    final file = XFile(
      path,
      name: name,
      mimeType: mimeType,
      length: size?.inBytes,
    );
    return fromFile(
      file,
      name: name,
      mimeType: mimeType,
      size: size,
    );
  }

  static Future<OtherTypeFileMedia> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    SizedFile? size,
  }) async {
    return OtherTypeFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<OtherTypeFileMedia> saveTo(String path) async {
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return OtherTypeFileMedia._(
      file: XFile(path, name: super.name, mimeType: super.mimeType),
      size: await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<MemoryMediaSource<OtherType>> convertToMemory() async {
    return OtherTypeMemoryMedia(
      await file.readAsBytes(),
      name: name,
      mimeType: mimeType,
    );
  }
}
