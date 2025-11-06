/// A comprehensive media source management library for Flutter and Dart.
///
/// This library provides a unified API for handling media files from different sources
/// including local files, in-memory data, and network URLs. It supports various media
/// types such as video, audio, images, and documents.
///
/// ## Features
///
/// - **Multiple Source Types**: Work with files, memory buffers, or network URLs
/// - **Type-Safe Media Classification**: Strongly-typed media types (Video, Audio, Image, Document)
/// - **Cross-Platform Support**: Works on mobile, web, and desktop platforms
/// - **Size-Aware**: Built-in file size handling with [SizedFile] support
/// - **Flexible Conversions**: Convert between different source types (e.g., file to memory)
/// - **File Operations**: Move, copy, save, and delete operations for file-based media
///
/// ## Extensibility
///
/// You can extend this library in three ways:
///
/// 1. **Define your own media type** by extending `FileTypeImpl` (see `src/media_type.dart`).
///    This is useful when your domain has custom classifications (e.g., StickerType, SubtitleType).
///
/// 2. **Create new media sources** by extending `MediaSource<M>` or implementing the conversion
///    mixins (`ToFileConvertableMedia`, `ToMemoryConvertableMedia`) to fit your storage/transport
///    needs.
///
/// 3. **Create custom media factories** to centralize media instantiation logic and apply
///    business rules, optimizations, or testing strategies.
///
/// Example – custom media type and memory source:
/// ```dart
/// class StickerType extends FileTypeImpl {
///   StickerType() : super.copy(FileType.other);
///   @override
///   List<Object?> get props => const [];
/// }
///
/// class StickerMemoryMedia extends MemoryMediaSource<StickerType> {
///   StickerMemoryMedia(Uint8List bytes, {required String name})
///       : super._(bytes, name: name, metadata: StickerType());
///
///   @override
///   Future<FileMediaSource<StickerType>> saveTo(String path) async {
///     final file = XFile.fromData(bytes, name: name, path: path);
///     await PlatformUtils.instance.createDirectoryIfNotExists(path);
///     await file.saveTo(path);
///     // Provide your own FileMediaSource implementation for StickerType
///     throw UnimplementedError('Provide a FileMediaSource<StickerType>');
///   }
/// }
/// ```
///
/// Example – custom media factory:
/// ```dart
/// class MediaFactory {
///   dynamic createMedia({
///     required MediaSourceType source,
///     String? path,
///     Uint8List? bytes,
///     String? url,
///   }) async {
///     switch (source) {
///       case MediaSourceType.file:
///         if (path != null) {
///           final fileType = await FileType.fromPath(path);
///           // Create appropriate media based on type
///           if (fileType is VideoType) {
///             return VideoFileMedia.fromPath(path);
///           }
///           // Handle other types...
///         }
///         break;
///       // Handle memory and network cases...
///     }
///   }
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// // Working with file media
/// final video = await VideoFileMedia.fromPath('path/to/video.mp4');
/// await video.saveTo('backup/video.mp4');
///
/// // Working with memory media
/// final image = ImageMemoryMedia(imageBytes, name: 'photo.jpg');
/// final savedFile = await image.saveToFolder('images');
///
/// // Working with network media
/// final audio = AudioNetworkMedia.url(
///   'https://example.com/song.mp3',
///   name: 'song.mp3',
///   size: 5.mb,
/// );
///
/// // Type-safe pattern matching with fold
/// final result = media.fold(
///   file: (f) => 'File: ${f.file.path}',
///   memory: (m) => 'Memory: ${m.size}',
///   network: (n) => 'URL: ${n.uri}',
///   asset: (a) => 'Asset: ${a.assetPath}',
///   orElse: () => 'Unknown',
/// );
/// ```
library media_source;

export 'src/sources/asset_media_source.dart';
export 'src/sources/file_media_source.dart';
export 'src/sources/memory_media_source.dart';
export 'src/sources/network_media_source.dart';
export 'src/media_type.dart';
export 'src/utils/platform_utils.dart';
export 'src/sources/media_source.dart';
export 'package:sized_file/sized_file.dart';
