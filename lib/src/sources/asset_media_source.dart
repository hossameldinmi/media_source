import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:path/path.dart' as p;
import 'package:file_sized/file_sized.dart';
import 'package:file_type_plus/file_type_plus.dart';

/// Abstract base class for Flutter asset-based media sources.
///
/// This class manages media content stored in the Flutter asset bundle. It provides:
/// - Asset loading with automatic size detection
/// - Type-specific asset media implementations
/// - Conversion to file or in-memory representation
/// - Factory methods for creating instances from asset paths
///
/// Note: Assets are read-only resources bundled with the app. To get the size,
/// the asset must be loaded, which reads the entire asset into memory.
///
/// Subclasses include:
/// - [VideoAssetMedia] for video assets
/// - [AudioAssetMedia] for audio assets
/// - [ImageAssetMedia] for image assets
/// - [DocumentAssetMedia] for document assets
/// - [OtherTypeAssetMedia] for unclassified assets
abstract class AssetMediaSource<M extends FileType> extends MediaSource<M>
    implements ToFileConvertableMedia<M>, ToMemoryConvertableMedia<M> {
  /// The asset path in the Flutter asset bundle (e.g., 'assets/video.mp4').
  final String assetPath;

  /// Optional custom asset bundle. If null, [rootBundle] is used.
  final AssetBundle? bundle;

  /// Internal constructor for creating asset media sources.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the asset in the bundle
  /// - [bundle]: Optional custom AssetBundle, defaults to rootBundle
  /// - [metadata]: Type-specific metadata (VideoType, AudioType, etc.)
  /// - [name]: Optional custom name, defaults to basename of asset path
  /// - [size]: File size (computed by loading asset if not provided)
  /// - [mimeType]: Optional MIME type, auto-detected from path if not provided
  AssetMediaSource._({
    required this.assetPath,
    this.bundle,
    required super.metadata,
    required String? name,
    required super.size,
    required String? mimeType,
  }) : super(
          mimeType: mimeType ?? FileUtil.getMimeTypeFromPath(assetPath),
          name: name ?? p.basename(assetPath),
        );

  /// Saves this asset to the file system at the specified path.
  ///
  /// Loads the asset bytes and writes them to disk as a file.
  /// Returns a new [FileMediaSource] instance pointing to the saved file.
  ///
  /// Parameters:
  /// - [path]: The destination file path
  Future<FileMediaSource<M>> saveTo(String path);

  /// Saves this asset to a folder, preserving the original filename.
  ///
  /// Convenience method that combines the folder path with the asset's name.
  ///
  /// Parameters:
  /// - [folderPath]: The directory where the file should be saved
  ///
  /// Returns a new [FileMediaSource] instance with the saved file.
  Future<FileMediaSource<M>> saveToFolder(String folderPath) => saveTo(p.join(folderPath, name));

  /// Includes the asset path and bundle in equality comparisons.
  @override
  List<Object?> get props => [assetPath, bundle, ...super.props];

  /// Loads an asset from the bundle and returns its bytes.
  ///
  /// This is a utility method used by all asset media types to load
  /// the raw bytes from the asset bundle.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the asset in the bundle
  /// - [bundle]: Optional custom AssetBundle, defaults to rootBundle
  ///
  /// Returns the asset data as a [Uint8List].
  static Future<Uint8List> loadAsset(String assetPath, [AssetBundle? bundle]) async {
    // coverage:ignore-start
    final assetBundle = bundle ?? rootBundle;
    // coverage:ignore-end

    // Load the asset bytes
    final byteData = await assetBundle.load(assetPath);
    final binary = byteData.buffer.asUint8List();
    return binary;
  }
}

/// Represents video assets from the Flutter asset bundle.
///
/// Stores video metadata including optional duration information.
/// Supports conversion to file (by saving) and in-memory representation.
///
/// Example:
/// ```dart
/// final video = await VideoAssetMedia.load(
///   'assets/videos/intro.mp4',
///   duration: Duration(seconds: 30),
/// );
///
/// // Save to file system
/// final fileMedia = await video.saveTo('/storage/intro.mp4');
///
/// // Or convert to memory
/// final memoryMedia = await video.convertToMemory();
/// ```
class VideoAssetMedia extends AssetMediaSource<VideoType> {
  /// Internal constructor for creating video asset media.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the video asset
  /// - [bundle]: Optional custom AssetBundle
  /// - [name]: Display name
  /// - [duration]: Optional video duration
  /// - [size]: Asset size in bytes
  /// - [mimeType]: MIME type of the video
  VideoAssetMedia._({
    required super.assetPath,
    super.bundle,
    required super.name,
    required Duration? duration,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: VideoType(duration));

  /// Loads a video asset from the Flutter asset bundle.
  ///
  /// This method loads the asset to determine its size. For large assets,
  /// consider providing the size parameter to avoid loading the asset twice.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the video asset (e.g., 'assets/videos/intro.mp4')
  /// - [bundle]: Optional custom AssetBundle, defaults to rootBundle
  /// - [name]: Optional custom display name, defaults to asset filename
  /// - [duration]: Optional video duration
  /// - [mimeType]: Optional MIME type override, auto-detected from path
  /// - [size]: Optional pre-computed asset size to avoid loading asset
  ///
  /// Returns a [VideoAssetMedia] instance.
  static Future<VideoAssetMedia> load(
    String assetPath, {
    AssetBundle? bundle,
    String? name,
    Duration? duration,
    String? mimeType,
    FileSize? size,
  }) async {
    return VideoAssetMedia._(
      assetPath: assetPath,
      bundle: bundle,
      name: name,
      duration: duration,
      size: size ?? (await AssetMediaSource.loadAsset(assetPath, bundle)).lengthInBytes.b,
      mimeType: mimeType,
    );
  }

  /// Saves this video asset to the file system.
  ///
  /// Loads the asset bytes and writes them to the specified path.
  /// Creates the directory structure if it doesn't exist.
  ///
  /// Parameters:
  /// - [path]: The destination file path
  ///
  /// Returns a [VideoFileMedia] instance pointing to the saved file.
  @override
  Future<VideoFileMedia> saveTo(String path) async {
    final bytes = await AssetMediaSource.loadAsset(assetPath, bundle);
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      length: bytes.lengthInBytes,
    );
    final fileMedia = await VideoFileMedia.fromFile(
      file,
      duration: metadata.duration,
      mimeType: mimeType,
      name: name,
      size: size,
    );
    return fileMedia.saveTo(path);
  }

  /// Converts this video asset to an in-memory representation.
  ///
  /// Loads the asset bytes into a [VideoMemoryMedia] instance.
  /// Useful for uploading, processing, or passing to APIs that expect byte arrays.
  ///
  /// Returns a [VideoMemoryMedia] with the asset's data in memory.
  @override
  Future<MemoryMediaSource<VideoType>> convertToMemory() async {
    return VideoMemoryMedia(
      await AssetMediaSource.loadAsset(assetPath, bundle),
      name: name,
      duration: metadata.duration,
      mimeType: mimeType,
    );
  }
}

/// Represents audio assets from the Flutter asset bundle.
///
/// Stores audio metadata including optional duration information.
/// Supports conversion to file (by saving) and in-memory representation.
///
/// Example:
/// ```dart
/// final audio = await AudioAssetMedia.load(
///   'assets/audio/song.mp3',
///   duration: Duration(minutes: 3, seconds: 45),
/// );
/// ```
class AudioAssetMedia extends AssetMediaSource<AudioType> {
  /// Internal constructor for creating audio asset media.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the audio asset
  /// - [bundle]: Optional custom AssetBundle
  /// - [name]: Display name
  /// - [duration]: Optional audio duration
  /// - [size]: Asset size in bytes
  /// - [mimeType]: MIME type of the audio
  AudioAssetMedia._({
    required super.assetPath,
    super.bundle,
    required super.name,
    required Duration? duration,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: AudioType(duration));

  /// Loads an audio asset from the Flutter asset bundle.
  ///
  /// This method loads the asset to determine its size. For large assets,
  /// consider providing the size parameter to avoid loading the asset twice.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the audio asset (e.g., 'assets/audio/song.mp3')
  /// - [bundle]: Optional custom AssetBundle, defaults to rootBundle
  /// - [name]: Optional custom display name, defaults to asset filename
  /// - [duration]: Optional audio duration
  /// - [mimeType]: Optional MIME type override, auto-detected from path
  /// - [size]: Optional pre-computed asset size to avoid loading asset
  ///
  /// Returns an [AudioAssetMedia] instance.
  static Future<AudioAssetMedia> load(
    String assetPath, {
    AssetBundle? bundle,
    String? name,
    Duration? duration,
    String? mimeType,
    FileSize? size,
  }) async {
    return AudioAssetMedia._(
      assetPath: assetPath,
      bundle: bundle,
      name: name,
      duration: duration,
      size: size ?? (await AssetMediaSource.loadAsset(assetPath, bundle)).lengthInBytes.b,
      mimeType: mimeType,
    );
  }

  /// Saves this audio asset to the file system.
  ///
  /// Loads the asset bytes and writes them to the specified path.
  /// Creates the directory structure if it doesn't exist.
  ///
  /// Parameters:
  /// - [path]: The destination file path
  ///
  /// Returns an [AudioFileMedia] instance pointing to the saved file.
  @override
  Future<AudioFileMedia> saveTo(String path) async {
    final bytes = await AssetMediaSource.loadAsset(assetPath, bundle);
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      length: bytes.lengthInBytes,
    );
    final fileMedia = await AudioFileMedia.fromFile(
      file,
      duration: metadata.duration,
      mimeType: mimeType,
      name: name,
      size: size,
    );
    return fileMedia.saveTo(path);
  }

  /// Converts this audio asset to an in-memory representation.
  ///
  /// Loads the asset bytes into an [AudioMemoryMedia] instance.
  /// Useful for uploading, processing, or passing to APIs that expect byte arrays.
  ///
  /// Returns an [AudioMemoryMedia] with the asset's data in memory.
  @override
  Future<MemoryMediaSource<AudioType>> convertToMemory() async {
    return AudioMemoryMedia(
      await AssetMediaSource.loadAsset(assetPath, bundle),
      name: name,
      duration: metadata.duration,
      mimeType: mimeType,
    );
  }
}

/// Represents image assets from the Flutter asset bundle.
///
/// Stores image metadata and supports conversion to file (by saving)
/// and in-memory representation.
///
/// Example:
/// ```dart
/// final image = await ImageAssetMedia.load('assets/images/logo.png');
///
/// // Save to cache directory
/// final cachedFile = await image.saveTo('/cache/logo.png');
/// ```
class ImageAssetMedia extends AssetMediaSource<ImageType> {
  /// Internal constructor for creating image asset media.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the image asset
  /// - [bundle]: Optional custom AssetBundle
  /// - [name]: Display name
  /// - [size]: Asset size in bytes
  /// - [mimeType]: MIME type of the image
  ImageAssetMedia({
    required super.assetPath,
    super.bundle,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: ImageType());

  /// Loads an image asset from the Flutter asset bundle.
  ///
  /// This method loads the asset to determine its size. For large assets,
  /// consider providing the size parameter to avoid loading the asset twice.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the image asset (e.g., 'assets/images/logo.png')
  /// - [bundle]: Optional custom AssetBundle, defaults to rootBundle
  /// - [name]: Optional custom display name, defaults to asset filename
  /// - [mimeType]: Optional MIME type override, auto-detected from path
  /// - [size]: Optional pre-computed asset size to avoid loading asset
  ///
  /// Returns an [ImageAssetMedia] instance.
  static Future<ImageAssetMedia> load(
    String assetPath, {
    AssetBundle? bundle,
    String? name,
    String? mimeType,
    FileSize? size,
  }) async {
    return ImageAssetMedia(
      assetPath: assetPath,
      bundle: bundle,
      name: name,
      size: size ?? (await AssetMediaSource.loadAsset(assetPath, bundle)).lengthInBytes.b,
      mimeType: mimeType,
    );
  }

  /// Saves this image asset to the file system.
  ///
  /// Loads the asset bytes and writes them to the specified path.
  /// Creates the directory structure if it doesn't exist.
  ///
  /// Parameters:
  /// - [path]: The destination file path
  ///
  /// Returns an [ImageFileMedia] instance pointing to the saved file.
  @override
  Future<ImageFileMedia> saveTo(String path) async {
    final bytes = await AssetMediaSource.loadAsset(assetPath, bundle);
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      length: bytes.lengthInBytes,
    );
    final fileMedia = await ImageFileMedia.fromFile(
      file,
      mimeType: mimeType,
      name: name,
      size: size,
    );
    return fileMedia.saveTo(path);
  }

  /// Converts this image asset to an in-memory representation.
  ///
  /// Loads the asset bytes into an [ImageMemoryMedia] instance.
  /// Useful for image processing, uploading, or displaying in widgets.
  ///
  /// Returns an [ImageMemoryMedia] with the asset's data in memory.
  @override
  Future<MemoryMediaSource<ImageType>> convertToMemory() async {
    return ImageMemoryMedia(
      await AssetMediaSource.loadAsset(assetPath, bundle),
      name: name,
      mimeType: mimeType,
    );
  }
}

/// Represents document assets from the Flutter asset bundle.
///
/// Supports documents like PDF, DOCX, XLSX, etc. bundled with the app.
/// Provides conversion to file (by saving) and in-memory representation.
///
/// Example:
/// ```dart
/// final pdf = await DocumentAssetMedia.load('assets/docs/manual.pdf');
/// final fileMedia = await pdf.saveTo('/downloads/manual.pdf');
/// ```
class DocumentAssetMedia extends AssetMediaSource<DocumentType> {
  /// Internal constructor for creating document asset media.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the document asset
  /// - [bundle]: Optional custom AssetBundle
  /// - [name]: Display name
  /// - [size]: Asset size in bytes
  /// - [mimeType]: MIME type of the document
  DocumentAssetMedia._({
    required super.assetPath,
    super.bundle,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: DocumentType());

  /// Loads a document asset from the Flutter asset bundle.
  ///
  /// This method loads the asset to determine its size. For large assets,
  /// consider providing the size parameter to avoid loading the asset twice.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the document asset (e.g., 'assets/docs/manual.pdf')
  /// - [bundle]: Optional custom AssetBundle, defaults to rootBundle
  /// - [name]: Optional custom display name, defaults to asset filename
  /// - [mimeType]: Optional MIME type override, auto-detected from path
  /// - [size]: Optional pre-computed asset size to avoid loading asset
  ///
  /// Returns a [DocumentAssetMedia] instance.
  static Future<DocumentAssetMedia> load(
    String assetPath, {
    AssetBundle? bundle,
    String? name,
    String? mimeType,
    FileSize? size,
  }) async {
    return DocumentAssetMedia._(
      assetPath: assetPath,
      bundle: bundle,
      name: name,
      size: size ?? (await AssetMediaSource.loadAsset(assetPath, bundle)).lengthInBytes.b,
      mimeType: mimeType,
    );
  }

  /// Saves this document asset to the file system.
  ///
  /// Loads the asset bytes and writes them to the specified path.
  /// Creates the directory structure if it doesn't exist.
  ///
  /// Parameters:
  /// - [path]: The destination file path
  ///
  /// Returns a [DocumentFileMedia] instance pointing to the saved file.
  @override
  Future<DocumentFileMedia> saveTo(String path) async {
    final bytes = await AssetMediaSource.loadAsset(assetPath, bundle);
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      length: bytes.lengthInBytes,
    );
    final fileMedia = await DocumentFileMedia.fromFile(
      file,
      mimeType: mimeType,
      name: name,
      size: size,
    );
    return fileMedia.saveTo(path);
  }

  /// Converts this document asset to an in-memory representation.
  ///
  /// Loads the asset bytes into a [DocumentMemoryMedia] instance.
  /// Useful for sharing, uploading, or processing documents.
  ///
  /// Returns a [DocumentMemoryMedia] with the asset's data in memory.
  @override
  Future<MemoryMediaSource<DocumentType>> convertToMemory() async {
    return DocumentMemoryMedia(
      await AssetMediaSource.loadAsset(assetPath, bundle),
      name: name,
      mimeType: mimeType,
    );
  }
}

/// Represents assets of unclassified or unknown types.
///
/// Used for asset files that don't fit into the standard categories
/// (video, audio, image, document). Provides the same operations as
/// other asset media types.
///
/// Example:
/// ```dart
/// final data = await OtherTypeAssetMedia.load('assets/data/config.json');
/// ```
class OtherTypeAssetMedia extends AssetMediaSource<OtherType> {
  /// Internal constructor for creating other type asset media.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the asset
  /// - [bundle]: Optional custom AssetBundle
  /// - [name]: Display name
  /// - [size]: Asset size in bytes
  /// - [mimeType]: MIME type of the asset
  @override
  OtherTypeAssetMedia._({
    required super.assetPath,
    super.bundle,
    required super.name,
    required super.size,
    required super.mimeType,
  }) : super._(metadata: OtherType());

  /// Loads an asset of unknown type from the Flutter asset bundle.
  ///
  /// This method loads the asset to determine its size. For large assets,
  /// consider providing the size parameter to avoid loading the asset twice.
  ///
  /// Parameters:
  /// - [assetPath]: Path to the asset (e.g., 'assets/data/config.json')
  /// - [bundle]: Optional custom AssetBundle, defaults to rootBundle
  /// - [name]: Optional custom display name, defaults to asset filename
  /// - [mimeType]: Optional MIME type override, auto-detected from path
  /// - [size]: Optional pre-computed asset size to avoid loading asset
  ///
  /// Returns an [OtherTypeAssetMedia] instance.
  static Future<OtherTypeAssetMedia> load(
    String assetPath, {
    AssetBundle? bundle,
    String? name,
    String? mimeType,
    FileSize? size,
  }) async {
    return OtherTypeAssetMedia._(
      assetPath: assetPath,
      bundle: bundle,
      name: name,
      size: size ?? (await AssetMediaSource.loadAsset(assetPath, bundle)).lengthInBytes.b,
      mimeType: mimeType,
    );
  }

  /// Saves this asset to the file system.
  ///
  /// Loads the asset bytes and writes them to the specified path.
  /// Creates the directory structure if it doesn't exist.
  ///
  /// Parameters:
  /// - [path]: The destination file path
  ///
  /// Returns an [OtherTypeFileMedia] instance pointing to the saved file.
  @override
  Future<OtherTypeFileMedia> saveTo(String path) async {
    final bytes = await AssetMediaSource.loadAsset(assetPath, bundle);
    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: mimeType,
      length: bytes.lengthInBytes,
    );
    final fileMedia = await OtherTypeFileMedia.fromFile(
      file,
      mimeType: mimeType,
      name: name,
      size: size,
    );
    return fileMedia.saveTo(path);
  }

  /// Converts this asset to an in-memory representation.
  ///
  /// Loads the asset bytes into an [OtherTypeMemoryMedia] instance.
  /// Useful for processing or handling custom file types.
  ///
  /// Returns an [OtherTypeMemoryMedia] with the asset's data in memory.
  @override
  Future<MemoryMediaSource<OtherType>> convertToMemory() async {
    return OtherTypeMemoryMedia(
      await AssetMediaSource.loadAsset(assetPath, bundle),
      name: name,
      mimeType: mimeType,
    );
  }
}
