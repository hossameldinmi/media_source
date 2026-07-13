import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/extensions/file_extensions.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:path/path.dart' as p;
import 'package:file_sized/file_sized.dart';
import 'package:file_type_plus/file_type_plus.dart';

/// Abstract base class for file-based media sources.
///
/// This class manages media content stored on the file system. It provides:
/// - File I/O operations (save, move, delete)
/// - Type-specific file media implementations
/// - Conversion to in-memory representation
/// - Factory methods for creating instances from file paths or XFile objects
///
/// Subclasses include:
/// - [VideoFileMedia] for video files
/// - [AudioFileMedia] for audio files
/// - [ImageFileMedia] for image files
/// - [DocumentFileMedia] for document files
/// - [OtherTypeFileMedia] for unclassified files
abstract class FileMediaSource<M extends FileType> extends MediaSource<M> implements ToMemoryConvertableMedia<M> {
  /// The underlying cross-platform file object.
  final XFile file;

  /// Internal constructor for creating file media sources.
  ///
  /// Parameters:
  /// - [file]: The XFile representing the media file
  /// - [metadata]: Type-specific metadata (VideoType, AudioType, etc.)
  /// - [name]: Optional custom name, defaults to file name
  /// - [size]: Optional file size, auto-detected if not provided
  /// - [mimeType]: Optional MIME type, auto-detected if not provided
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

  /// Creates a copy of this media source pointing at [file] with [size].
  ///
  /// Template hook used by [saveTo] and [moveTo] to recreate the concrete
  /// subclass after the underlying file changes location.
  @protected
  FileMediaSource<M> copyWithFile(XFile file, FileSize? size);

  /// Creates the in-memory counterpart of this media source for [bytes].
  ///
  /// Template hook used by [convertToMemory].
  @protected
  MemoryMediaSource<M> createMemoryMedia(Uint8List bytes);

  /// Saves this media to the specified file path.
  ///
  /// Creates the directory if it doesn't exist, then saves the file
  /// and returns a new [FileMediaSource] instance pointing to the saved
  /// location. Subclasses narrow the return type via [copyWithFile].
  Future<FileMediaSource<M>> saveTo(String path) async {
    await PlatformUtils.instance.ensureParentDirectoryExists(path);
    await file.saveTo(path);
    final newSize = size ?? await file.size();
    return copyWithFile(
      XFile(path, name: name, mimeType: mimeType, length: newSize.inBytes),
      newSize,
    );
  }

  /// Saves this media to a folder, preserving the original filename.
  ///
  /// Parameters:
  /// - [folderPath]: The directory where the file should be saved
  ///
  /// Returns a new [FileMediaSource] instance with the file in the folder.
  Future<FileMediaSource<M>> saveToFolder(String folderPath) => saveTo(p.join(folderPath, name));

  /// Moves this media to a new file path.
  ///
  /// Uses a fast platform rename when available and falls back to
  /// copy + delete otherwise. If the destination already exists, it will be
  /// deleted before moving. Returns early if the source path matches the
  /// destination.
  ///
  /// Throws a [StateError] on native platforms when the fallback copy
  /// succeeds but the original file cannot be deleted (both files exist at
  /// that point). On web the original is left in place silently, since
  /// deleting arbitrary browser resources is not supported.
  ///
  /// Parameters:
  /// - [path]: The destination file path
  ///
  /// Returns a new [FileMediaSource] instance at the new location.
  Future<FileMediaSource<M>> moveTo(String path) async {
    if (file.path == path) return this;
    final newPathFile = XFile(path);
    if (await newPathFile.exists()) {
      await newPathFile.delete();
    }
    if (await PlatformUtils.instance.moveFile(file.path, path)) {
      final moved = XFile(path, name: name, mimeType: mimeType, length: size?.inBytes);
      return copyWithFile(moved, size ?? await moved.size());
    }
    final saved = await saveTo(path);
    final deleted = await delete();
    if (!deleted && !kIsWeb) {
      throw StateError('moveTo: copied "${file.path}" to "$path" but failed to delete the original file.');
    }
    return saved;
  }

  /// Moves this media to a folder, preserving the original filename.
  ///
  /// Parameters:
  /// - [folderPath]: The directory where the file should be moved
  ///
  /// Returns a new [FileMediaSource] instance with the file in the folder.
  Future<FileMediaSource<M>> moveToFolder(String folderPath) => moveTo(p.join(folderPath, name));

  /// Deletes the file from the file system.
  ///
  /// Returns true if deletion was successful, false otherwise.
  Future<bool> delete() => file.delete();

  /// Converts this media to an in-memory representation.
  ///
  /// Loads the entire file content into memory as a byte array.
  /// Useful for uploading or processing without file system access.
  @override
  Future<MemoryMediaSource<M>> convertToMemory() async => createMemoryMedia(await file.readAsBytes());

  /// Creates a [FileMediaSource] from a file path.
  ///
  /// Automatically detects the media type and returns the appropriate subclass.
  /// If media type is not provided, it will be determined from the file.
  ///
  /// Parameters:
  /// - [path]: The file system path to the media file
  /// - [name]: Optional custom display name
  /// - [size]: Optional pre-computed file size
  /// - [mimeType]: Optional MIME type
  /// - [duration]: Optional duration for audio/video files
  /// - [mediaType]: Optional explicit media type (for type narrowing)
  ///
  /// Returns the appropriate [FileMediaSource] subclass based on media type.
  static Future<FileMediaSource> fromPath(
    String path, {
    String? name,
    FileSize? size,
    String? mimeType,
    Duration? duration,
    FileType? mediaType,
  }) =>
      fromFile(
        XFile(
          path,
          mimeType: mimeType,
          length: size?.inBytes,
          name: name,
        ),
        name: name,
        mimeType: mimeType,
        duration: duration,
        mediaType: mediaType,
        size: size,
      );

  /// Creates a [FileMediaSource] from an XFile object.
  ///
  /// Automatically detects the media type and returns the appropriate subclass.
  /// Supports:
  /// - [AudioFileMedia] for audio files
  /// - [VideoFileMedia] for video files
  /// - [ImageFileMedia] for image files
  /// - [DocumentFileMedia] for document files
  /// - [OtherTypeFileMedia] for unclassified files
  ///
  /// Parameters:
  /// - [file]: The XFile object representing the media
  /// - [name]: Optional custom display name
  /// - [mimeType]: Optional MIME type override
  /// - [duration]: Optional duration for audio/video files
  /// - [mediaType]: Optional explicit media type
  /// - [size]: Optional pre-computed file size
  ///
  /// Returns the appropriate [FileMediaSource] subclass.
  static Future<FileMediaSource> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    Duration? duration,
    FileType? mediaType,
    FileSize? size,
  }) async {
    mediaType ??= await file.getMediaType(mimeType);
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

  /// Includes the file object in equality comparisons.
  @override
  List<Object?> get props => [file, ...super.props];
}

/// Represents video files stored on the file system.
///
/// Stores video metadata including optional duration information.
/// Supports saving, moving, deleting, and conversion to in-memory representation.
class VideoFileMedia extends FileMediaSource<VideoType> {
  /// Internal constructor for creating video file media.
  ///
  /// Parameters:
  /// - [file]: The video file
  /// - [name]: Display name
  /// - [duration]: Optional video duration
  /// - [size]: File size
  /// - [mimeType]: MIME type of the video
  VideoFileMedia._({
    required super.file,
    required super.name,
    required Duration? duration,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: VideoType(duration));

  /// Creates a [VideoFileMedia] from a file path.
  ///
  /// Parameters:
  /// - [path]: The file system path to the video
  /// - [name]: Optional custom display name
  /// - [duration]: Optional video duration
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size
  static Future<VideoFileMedia> fromPath(
    String path, {
    String? name,
    Duration? duration,
    String? mimeType,
    FileSize? size,
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

  /// Creates a [VideoFileMedia] from an XFile object.
  ///
  /// Parameters:
  /// - [file]: The XFile representing the video
  /// - [name]: Optional custom display name
  /// - [duration]: Optional video duration
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size, auto-detected if not provided
  static Future<VideoFileMedia> fromFile(
    XFile file, {
    String? name,
    Duration? duration,
    String? mimeType,
    FileSize? size,
  }) async {
    return VideoFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      duration: duration,
      mimeType: mimeType,
    );
  }

  @override
  Future<VideoFileMedia> saveTo(String path) async => await super.saveTo(path) as VideoFileMedia;

  @override
  VideoFileMedia copyWithFile(XFile file, FileSize? size) => VideoFileMedia._(
        file: file,
        size: size,
        name: name,
        duration: metadata.duration,
        mimeType: mimeType,
      );

  @override
  VideoMemoryMedia createMemoryMedia(Uint8List bytes) => VideoMemoryMedia(
        bytes,
        name: name,
        duration: metadata.duration,
        mimeType: mimeType,
      );
}

/// Represents audio files stored on the file system.
///
/// Stores audio metadata including optional duration information.
/// Supports saving, moving, deleting, and conversion to in-memory representation.
class AudioFileMedia extends FileMediaSource<AudioType> {
  /// Internal constructor for creating audio file media.
  ///
  /// Parameters:
  /// - [file]: The audio file
  /// - [name]: Display name
  /// - [duration]: Optional audio duration
  /// - [size]: File size
  /// - [mimeType]: MIME type of the audio
  AudioFileMedia._({
    required super.file,
    required super.name,
    required Duration? duration,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: AudioType(duration));

  /// Creates an [AudioFileMedia] from a file path.
  ///
  /// Parameters:
  /// - [path]: The file system path to the audio file
  /// - [name]: Optional custom display name
  /// - [duration]: Optional audio duration
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size
  static Future<AudioFileMedia> fromPath(
    String path, {
    String? name,
    Duration? duration,
    String? mimeType,
    FileSize? size,
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

  /// Creates an [AudioFileMedia] from an XFile object.
  ///
  /// Parameters:
  /// - [file]: The XFile representing the audio
  /// - [name]: Optional custom display name
  /// - [duration]: Optional audio duration
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size, auto-detected if not provided
  static Future<AudioFileMedia> fromFile(
    XFile file, {
    String? name,
    Duration? duration,
    String? mimeType,
    FileSize? size,
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
  Future<AudioFileMedia> saveTo(String path) async => await super.saveTo(path) as AudioFileMedia;

  @override
  AudioFileMedia copyWithFile(XFile file, FileSize? size) => AudioFileMedia._(
        file: file,
        size: size,
        name: name,
        duration: metadata.duration,
        mimeType: mimeType,
      );

  @override
  AudioMemoryMedia createMemoryMedia(Uint8List bytes) => AudioMemoryMedia(
        bytes,
        name: name,
        duration: metadata.duration,
        mimeType: mimeType,
      );
}

/// Represents image files stored on the file system.
///
/// Stores image metadata and supports saving, moving, deleting,
/// and conversion to in-memory representation.
class ImageFileMedia extends FileMediaSource<ImageType> {
  /// Internal constructor for creating image file media.
  ///
  /// Parameters:
  /// - [file]: The image file
  /// - [name]: Display name
  /// - [size]: File size
  /// - [mimeType]: MIME type of the image
  ImageFileMedia._({
    required super.file,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: ImageType());

  /// Creates an [ImageFileMedia] from a file path.
  ///
  /// Parameters:
  /// - [path]: The file system path to the image
  /// - [name]: Optional custom display name
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size
  static Future<ImageFileMedia> fromPath(
    String path, {
    String? name,
    String? mimeType,
    FileSize? size,
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

  /// Creates an [ImageFileMedia] from an XFile object.
  ///
  /// Parameters:
  /// - [file]: The XFile representing the image
  /// - [name]: Optional custom display name
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size, auto-detected if not provided
  static Future<ImageFileMedia> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    FileSize? size,
  }) async {
    return ImageFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<ImageFileMedia> saveTo(String path) async => await super.saveTo(path) as ImageFileMedia;

  @override
  ImageFileMedia copyWithFile(XFile file, FileSize? size) => ImageFileMedia._(
        file: file,
        size: size,
        name: name,
        mimeType: mimeType,
      );

  @override
  ImageMemoryMedia createMemoryMedia(Uint8List bytes) => ImageMemoryMedia(
        bytes,
        name: name,
        mimeType: mimeType,
      );
}

/// Represents document files stored on the file system.
///
/// Supports documents like PDF, DOC, XLSX, etc. Provides saving, moving,
/// deleting, and conversion to in-memory representation.
class DocumentFileMedia extends FileMediaSource<DocumentType> {
  /// Internal constructor for creating document file media.
  ///
  /// Parameters:
  /// - [file]: The document file
  /// - [name]: Display name
  /// - [size]: File size
  /// - [mimeType]: MIME type of the document
  DocumentFileMedia._({
    required super.file,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: DocumentType());

  /// Creates a [DocumentFileMedia] from a file path.
  ///
  /// Parameters:
  /// - [path]: The file system path to the document
  /// - [name]: Optional custom display name
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size
  static Future<DocumentFileMedia> fromPath(
    String path, {
    String? name,
    String? mimeType,
    FileSize? size,
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

  /// Creates a [DocumentFileMedia] from an XFile object.
  ///
  /// Parameters:
  /// - [file]: The XFile representing the document
  /// - [name]: Optional custom display name
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size, auto-detected if not provided
  static Future<DocumentFileMedia> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    FileSize? size,
  }) async {
    return DocumentFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<DocumentFileMedia> saveTo(String path) async => await super.saveTo(path) as DocumentFileMedia;

  @override
  DocumentFileMedia copyWithFile(XFile file, FileSize? size) => DocumentFileMedia._(
        file: file,
        size: size,
        name: name,
        mimeType: mimeType,
      );

  @override
  DocumentMemoryMedia createMemoryMedia(Uint8List bytes) => DocumentMemoryMedia(
        bytes,
        name: name,
        mimeType: mimeType,
      );
}

/// Represents files of unclassified or unknown types.
///
/// Used for media files that don't fit into the standard categories
/// (video, audio, image, document). Provides the same operations as
/// other file media types.
class OtherTypeFileMedia extends FileMediaSource<OtherType> {
  /// Internal constructor for creating other type file media.
  ///
  /// Parameters:
  /// - [file]: The file
  /// - [name]: Display name
  /// - [size]: File size
  /// - [mimeType]: MIME type of the file
  OtherTypeFileMedia._({
    required super.file,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: OtherType());

  /// Creates an [OtherTypeFileMedia] from a file path.
  ///
  /// Parameters:
  /// - [path]: The file system path to the file
  /// - [name]: Optional custom display name
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size
  static Future<OtherTypeFileMedia> fromPath(
    String path, {
    String? name,
    String? mimeType,
    FileSize? size,
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

  /// Creates an [OtherTypeFileMedia] from an XFile object.
  ///
  /// Parameters:
  /// - [file]: The XFile representing the file
  /// - [name]: Optional custom display name
  /// - [mimeType]: Optional MIME type override
  /// - [size]: Optional pre-computed file size, auto-detected if not provided
  static Future<OtherTypeFileMedia> fromFile(
    XFile file, {
    String? name,
    String? mimeType,
    FileSize? size,
  }) async {
    return OtherTypeFileMedia._(
      file: file,
      size: size ?? await file.size(),
      name: name,
      mimeType: mimeType,
    );
  }

  @override
  Future<OtherTypeFileMedia> saveTo(String path) async => await super.saveTo(path) as OtherTypeFileMedia;

  @override
  OtherTypeFileMedia copyWithFile(XFile file, FileSize? size) => OtherTypeFileMedia._(
        file: file,
        size: size,
        name: name,
        mimeType: mimeType,
      );

  @override
  OtherTypeMemoryMedia createMemoryMedia(Uint8List bytes) => OtherTypeMemoryMedia(
        bytes,
        name: name,
        mimeType: mimeType,
      );
}
