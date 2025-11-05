import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:media_source/src/utils/platform_utils.dart';
import 'package:sized_file/sized_file.dart';
import 'package:path/path.dart' as p;
import 'package:file_type_plus/file_type_plus.dart';

/// Abstract base class for in-memory media sources.
///
/// Stores media content as a byte array (Uint8List) in memory. This is useful for:
/// - Uploading files without file system access
/// - Processing downloaded media
/// - Caching media in memory
/// - Avoiding file system operations
///
/// Subclasses include:
/// - [VideoMemoryMedia] for video data
/// - [AudioMemoryMedia] for audio data
/// - [ImageMemoryMedia] for image data
/// - [DocumentMemoryMedia] for document data
/// - [OtherTypeMemoryMedia] for unclassified data
abstract class MemoryMediaSource<M extends FileType> extends MediaSource<M> implements ToFileConvertableMedia<M> {
  /// The raw byte data of the media.
  final Uint8List bytes;

  /// Internal constructor for creating in-memory media sources.
  ///
  /// Parameters:
  /// - [bytes]: The media content as a byte array
  /// - [name]: Display name
  /// - [metadata]: Type-specific metadata (VideoType, AudioType, etc.)
  /// - [mimeType]: Optional MIME type, auto-detected from bytes if not provided
  MemoryMediaSource._(
    this.bytes, {
    required super.name,
    required super.metadata,
    String? mimeType,
  }) : super(
          mimeType: mimeType ?? FileUtil.getMimeTypeFromBytes(bytes),
          size: bytes.lengthInBytes.b,
        );

  /// Includes the byte array in equality comparisons.
  @override
  List<Object?> get props => [bytes, ...super.props];

  /// Disables automatic string representation of byte arrays.
  ///
  /// Returns false to prevent printing large byte arrays in debug output.
  @override
  bool? get stringify => false;

  /// Saves this media to a file in the specified folder.
  ///
  /// Uses the original filename and creates directories as needed.
  ///
  /// Parameters:
  /// - [folderPath]: The directory where the file should be saved
  ///
  /// Returns a new [FileMediaSource] pointing to the saved file.
  Future<FileMediaSource<M>> saveToFolder(String folderPath) {
    final path = p.join(folderPath, name);
    return saveToFile(path);
  }
}

/// Represents video data stored in memory.
///
/// Stores video metadata including optional duration information.
/// Can be saved to a file or transmitted without file system operations.
class VideoMemoryMedia extends MemoryMediaSource<VideoType> {
  /// Creates a [VideoMemoryMedia] with video content and optional duration.
  ///
  /// Parameters:
  /// - [bytes]: The video data as a byte array
  /// - [name]: Display name of the video
  /// - [duration]: Optional video duration
  /// - [mimeType]: Optional MIME type override
  VideoMemoryMedia(
    super.bytes, {
    required super.name,
    Duration? duration,
    super.mimeType,
  }) : super._(metadata: VideoType(duration));

  /// Saves this video to a file at the specified path.
  ///
  /// Creates the directory if it doesn't exist, then saves the bytes
  /// and returns a new [VideoFileMedia] instance.
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
      size: size,
    );
  }
}

/// Represents audio data stored in memory.
///
/// Stores audio metadata including optional duration information.
/// Can be saved to a file or transmitted without file system operations.
class AudioMemoryMedia extends MemoryMediaSource<AudioType> {
  /// Creates an [AudioMemoryMedia] with audio content and optional duration.
  ///
  /// Parameters:
  /// - [bytes]: The audio data as a byte array
  /// - [name]: Display name of the audio
  /// - [duration]: Optional audio duration
  /// - [mimeType]: Optional MIME type override
  AudioMemoryMedia(
    super.bytes, {
    required super.name,
    Duration? duration,
    super.mimeType,
  }) : super._(metadata: AudioType(duration));

  /// Saves this audio to a file at the specified path.
  ///
  /// Creates the directory if it doesn't exist, then saves the bytes
  /// and returns a new [AudioFileMedia] instance.
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

/// Represents image data stored in memory.
///
/// Can be saved to a file or transmitted without file system operations.
class ImageMemoryMedia extends MemoryMediaSource<ImageType> {
  /// Creates an [ImageMemoryMedia] with image content.
  ///
  /// Parameters:
  /// - [bytes]: The image data as a byte array
  /// - [name]: Display name of the image
  /// - [mimeType]: Optional MIME type override
  ImageMemoryMedia(
    super.bytes, {
    required super.name,
    super.mimeType,
  }) : super._(metadata: ImageType());

  /// Saves this image to a file at the specified path.
  ///
  /// Creates the directory if it doesn't exist, then saves the bytes
  /// and returns a new [ImageFileMedia] instance.
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

/// Represents document data stored in memory.
///
/// Supports documents like PDF, DOC, XLSX, etc.
/// Can be saved to a file or transmitted without file system operations.
class DocumentMemoryMedia extends MemoryMediaSource<DocumentType> {
  /// Creates a [DocumentMemoryMedia] with document content.
  ///
  /// Parameters:
  /// - [bytes]: The document data as a byte array
  /// - [name]: Display name of the document
  /// - [mimeType]: Optional MIME type override
  @override
  DocumentMemoryMedia(
    super.bytes, {
    required super.name,
    super.mimeType,
  }) : super._(metadata: DocumentType());

  /// Saves this document to a file at the specified path.
  ///
  /// Creates the directory if it doesn't exist, then saves the bytes
  /// and returns a new [DocumentFileMedia] instance.
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

/// Represents unclassified or unknown data stored in memory.
///
/// Used for media that doesn't fit into standard categories
/// (video, audio, image, document).
/// Can be saved to a file or transmitted without file system operations.
class OtherTypeMemoryMedia extends MemoryMediaSource<OtherType> {
  /// Creates an [OtherTypeMemoryMedia] with unclassified content.
  ///
  /// Parameters:
  /// - [bytes]: The media data as a byte array
  /// - [name]: Display name of the media
  /// - [mimeType]: Optional MIME type override
  @override
  OtherTypeMemoryMedia(
    super.bytes, {
    required super.name,
    super.mimeType,
  }) : super._(metadata: OtherType());

  /// Saves this media to a file at the specified path.
  ///
  /// Creates the directory if it doesn't exist, then saves the bytes
  /// and returns a new [OtherTypeFileMedia] instance.
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
