import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:sized_file/sized_file.dart';
import 'package:path/path.dart' as p;
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/utils/file_util.dart' as file_util;

abstract class MemoryMediaSource<M extends FileType> extends MediaSource<M> implements ToFileConvertableMedia<M> {
  final Uint8List bytes;

  MemoryMediaSource._(
    this.bytes, {
    required super.name,
    required super.metadata,
    String? mimeType,
  }) : super(
          mimeType: mimeType ?? FileUtil.getMimeTypeFromBytes(bytes),
          size: bytes.lengthInBytes.b,
        );

  @override
  List<Object?> get props => [bytes, ...super.props];
  @override
  bool? get stringify => false;

  Future<FileMediaSource<M>> saveToFolder(String folderPath) {
    final path = p.join(folderPath, name);
    return saveToFile(path);
  }

  static Future<MemoryMediaSource<FileType>> fromBytes(
    Uint8List bytes, {
    String? name,
    String? mimeType,
    Duration? duration,
    MediaSource? thumbnail,
    FileType? mediaType,
  }) async {
    mediaType ??= FileType.fromBytes(bytes, mimeType);
    if ([
      if (mediaType.isAny([FileType.audio, FileType.video])) duration,
      mimeType
    ].contains(null)) {
      final metadata = await file_util.FileUtil.getFileMetadataFromBytes(bytes, name);
      mimeType ??= metadata?.mimeType;
      duration ??= metadata?.duration;
    }
    if (mediaType.isAny([FileType.audio])) {
      return AudioMemoryMedia(
        bytes,
        name: name,
        duration: duration,
        mimeType: mimeType,
      );
    }
    if (mediaType.isAny([FileType.video])) {
      return VideoMemoryMedia(
        bytes,
        name: name,
        duration: duration,
        thumbnail: thumbnail,
        mimeType: mimeType,
      );
    }
    if (mediaType.isAny([FileType.image])) {
      return ImageMemoryMedia(
        bytes,
        name: name,
        mimeType: mimeType,
      );
    }
    if (mediaType.isAny([FileType.document])) {
      return DocumentMemoryMedia(
        bytes,
        name: name,
        mimeType: mimeType,
      );
    }
    return OtherTypeMemoryMedia(
      bytes,
      name: name,
      mimeType: mimeType,
    );
  }
}

class VideoMemoryMedia extends MemoryMediaSource<VideoType> implements ThumbnailMedia {
  @override
  final MediaSource? thumbnail;
  @override
  bool get hasThumbnail => ThumbnailMedia.hasThumbnailImp(this);

  VideoMemoryMedia(
    super.bytes, {
    required super.name,
    this.thumbnail,
    Duration? duration,
    super.mimeType,
  }) : super._(metadata: VideoType(duration));

  @override
  Future<VideoFileMedia> saveToFile(String path) async {
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      path: path,
      length: size?.inBytes,
    );
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return VideoFileMedia.fromFile(
      file,
      duration: metadata.duration,
      mimeType: mimeType,
      name: name,
      thumbnail: thumbnail,
      size: size,
    );
  }
}

class AudioMemoryMedia extends MemoryMediaSource<AudioType> {
  AudioMemoryMedia(
    super.bytes, {
    required super.name,
    Duration? duration,
    super.mimeType,
  }) : super._(metadata: AudioType(duration));

  @override
  Future<AudioFileMedia> saveToFile(String path) async {
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      path: path,
      length: size?.inBytes,
    );
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return AudioFileMedia.fromFile(
      file,
      duration: metadata.duration,
      mimeType: mimeType,
      name: name,
      size: size,
    );
  }
}

class ImageMemoryMedia extends MemoryMediaSource<ImageType> {
  ImageMemoryMedia(
    super.bytes, {
    required super.name,
    super.mimeType,
  }) : super._(metadata: ImageType());

  @override
  Future<ImageFileMedia> saveToFile(String path) async {
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      path: path,
      length: size?.inBytes,
    );
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return ImageFileMedia.fromFile(
      file,
      mimeType: mimeType,
      name: name,
      size: size,
    );
  }
}

class DocumentMemoryMedia extends MemoryMediaSource<DocumentType> {
  @override
  DocumentMemoryMedia(
    super.bytes, {
    required super.name,
    super.mimeType,
  }) : super._(metadata: DocumentType());

  @override
  Future<DocumentFileMedia> saveToFile(String path) async {
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      path: path,
    );
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return DocumentFileMedia.fromFile(
      file,
      mimeType: mimeType,
      name: name,
      size: size,
    );
  }
}

class OtherTypeMemoryMedia extends MemoryMediaSource<OtherType> {
  @override
  OtherTypeMemoryMedia(
    super.bytes, {
    required super.name,
    super.mimeType,
  }) : super._(metadata: OtherType());

  @override
  Future<OtherTypeFileMedia> saveToFile(String path) async {
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      path: path,
      length: size?.inBytes,
    );
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    return OtherTypeFileMedia.fromFile(
      file,
      mimeType: mimeType,
      name: name,
      size: size,
    );
  }
}
