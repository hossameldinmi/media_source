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
///   orElse: () => 'Unknown',
/// );
/// ```
library media_source;

export 'src/sources/file_media_source.dart';
export 'src/sources/memory_media_source.dart';
export 'src/sources/network_media_source.dart';
export 'src/media_type.dart';
export 'src/utils/platform_utils.dart';
export 'src/sources/media_source.dart';
