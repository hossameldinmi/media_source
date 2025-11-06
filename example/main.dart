import 'dart:typed_data';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/media_source.dart';

/// Example demonstrating the media_source package capabilities.
///
/// This example shows:
/// - Working with file, memory, network, and asset media sources
/// - Type-safe pattern matching with fold
/// - Converting between different source types
/// - Custom media type and source implementation
void main() async {
  print('=== Media Source Package Examples ===\n');

  // Example 1: Working with File Media
  await fileMediaExample();

  // Example 2: Working with Memory Media
  await memoryMediaExample();

  // Example 3: Working with Network Media
  networkMediaExample();

  // Example 4: Working with Asset Media (Flutter only)
  // await assetMediaExample();

  // Example 5: Pattern Matching with fold
  await patternMatchingExample();

  // Example 6: Converting Between Sources
  await conversionExample();

  // Example 7: Custom Media Types
  customMediaTypeExample();

  // Example 8: Custom Media Factory
  await customMediaFactoryExample();
}

/// Example 1: Working with File Media Sources
Future<void> fileMediaExample() async {
  print('--- Example 1: File Media ---');

  // Create a video file media
  final video = await VideoFileMedia.fromPath(
    '/path/to/video.mp4',
    name: 'my_video.mp4',
    duration: const Duration(minutes: 5, seconds: 30),
    size: 50.mb,
  );

  print('Video name: ${video.name}');
  print('Video size: ${video.size}');
  print('Video duration: ${video.metadata.duration}');
  print('Video path: ${video.file.path}');

  // File operations (commented out to avoid actual file system operations)
  // await video.saveTo('/backup/video.mp4');
  // await video.moveTo('/new/location/video.mp4');
  // await video.delete();

  print('');
}

/// Example 2: Working with Memory Media Sources
Future<void> memoryMediaExample() async {
  print('--- Example 2: Memory Media ---');

  // Simulate image bytes
  final imageBytes = Uint8List.fromList(List.generate(1024, (i) => i % 256));

  final image = ImageMemoryMedia(
    imageBytes,
    name: 'photo.jpg',
    mimeType: 'image/jpeg',
  );

  print('Image name: ${image.name}');
  print('Image size: ${image.size}');
  print('Image bytes length: ${image.bytes.length}');
  print('Stringify disabled: ${image.stringify}');

  // Save to file (commented out)
  // final savedFile = await image.saveToFolder('/images');
  // print('Saved to: ${savedFile.file.path}');

  print('');
}

/// Example 3: Working with Network Media Sources
void networkMediaExample() {
  print('--- Example 3: Network Media ---');

  // Create network media from URL
  final video = VideoNetworkMedia.url(
    'https://example.com/movie.mp4',
    name: 'movie.mp4',
    size: 150.mb,
    duration: const Duration(minutes: 90),
  );

  print('Video URL: ${video.uri}');
  print('Video name: ${video.name}');
  print('Video size: ${video.size}');
  print('Video duration: ${video.metadata.duration}');

  // Create audio from URI
  final audio = AudioNetworkMedia(
    Uri.parse('https://example.com/song.mp3'),
    name: 'song.mp3',
    size: 5.mb,
    duration: const Duration(minutes: 3, seconds: 45),
  );

  print('Audio URL: ${audio.uri}');
  print('Audio name: ${audio.name}');

  // Create image
  final image = ImageNetworkMedia.url(
    'https://example.com/photo.jpg',
    name: 'photo.jpg',
    size: 2.mb,
  );

  print('Image URL: ${image.uri}');

  // Safe creation from nullable URL
  final maybeMedia = NetworkMediaSource.fromUrlOrNull(null);
  print('Nullable URL result: $maybeMedia');

  print('');
}

/// Example 4: Working with Asset Media Sources (Flutter only)
///
/// Note: This example requires:
/// 1. Adding assets to pubspec.yaml:
///    ```yaml
///    flutter:
///      assets:
///        - assets/videos/
///        - assets/audio/
///        - assets/images/
///    ```
/// 2. Placing actual media files in those directories
Future<void> assetMediaExample() async {
  print('--- Example 4: Asset Media (Flutter only) ---');

  // Load a video asset from the bundle
  final video = await VideoAssetMedia.load(
    'assets/videos/intro.mp4',
    name: 'Intro Video',
    duration: const Duration(seconds: 30),
  );

  print('Video Asset:');
  print('  Asset path: ${video.assetPath}');
  print('  Name: ${video.name}');
  print('  Size: ${video.size}');
  print('  Duration: ${video.metadata.duration}');
  print('');

  // Load an audio asset
  final audio = await AudioAssetMedia.load(
    'assets/audio/background.mp3',
    duration: const Duration(minutes: 3, seconds: 45),
  );

  print('Audio Asset:');
  print('  Asset path: ${audio.assetPath}');
  print('  Name: ${audio.name}');
  print('  Duration: ${audio.metadata.duration}');
  print('');

  // Load an image asset with optimized loading (size provided)
  final image = await ImageAssetMedia.load(
    'assets/images/logo.png',
    size: 150.kb, // Avoids loading asset just to get size
  );

  print('Image Asset:');
  print('  Asset path: ${image.assetPath}');
  print('  Size: ${image.size}');
  print('');

  // Convert asset to memory
  final memoryVideo = await video.convertToMemory();
  print('Converted to memory: ${memoryVideo.bytes.length} bytes');
  print('');

  // Save asset to file (commented out to avoid file I/O)
  // final savedVideo = await video.saveTo('/storage/intro.mp4');
  // print('Saved to: ${savedVideo.file.path}');

  print('Assets can be saved to file system:');
  print('  await video.saveTo(\'/storage/intro.mp4\');');
  print('  await audio.saveToFolder(\'/music\');');
  print('');
}

/// Example 5: Pattern Matching with fold
Future<void> patternMatchingExample() async {
  print('--- Example 5: Pattern Matching ---');

  // Create different media sources
  final fileMedia = await VideoFileMedia.fromPath('/path/to/video.mp4');
  final memoryMedia = ImageMemoryMedia(
    Uint8List(100),
    name: 'image.jpg',
  );
  final networkMedia = AudioNetworkMedia.url('https://example.com/audio.mp3');

  // Pattern match on source type
  final List<MediaSource> mediaSources = [fileMedia, memoryMedia, networkMedia];
  for (final media in mediaSources) {
    final description = media.fold<String>(
      file: (f) => 'File: ${f.file.path}',
      memory: (m) => 'Memory: ${m.size} (${m.bytes.length} bytes)',
      network: (n) => 'Network: ${n.uri}',
      asset: (a) => 'Asset: ${a.assetPath}',
      orElse: () => 'Unknown source',
    );
    print(description);
  }

  // Pattern match on media type
  final mediaType = VideoType(const Duration(seconds: 120));
  final typeDescription = mediaType.fold(
    video: (v) => 'Video with duration: ${v.duration}',
    audio: (a) => 'Audio with duration: ${a.duration}',
    image: (i) => 'Image file',
    document: (d) => 'Document file',
    url: (u) => 'URL reference',
    orElse: () => 'Other type',
  );
  print('Media type: $typeDescription');

  print('');
}

/// Example 6: Converting Between Sources
Future<void> conversionExample() async {
  print('--- Example 6: Converting Between Sources ---');

  // Start with file media
  final fileMedia = await VideoFileMedia.fromPath(
    '/path/to/video.mp4',
    duration: const Duration(minutes: 2),
  );

  print('Original: File media at ${fileMedia.file.path}');

  // Convert to memory (commented out to avoid file system operations)
  // final memoryMedia = await fileMedia.convertToMemory();
  // print('Converted to memory: ${memoryMedia.bytes.length} bytes');

  // Create memory media and save to file
  final memoryMedia = VideoMemoryMedia(
    Uint8List(1024),
    name: 'video.mp4',
    duration: const Duration(seconds: 30),
  );

  print('Memory media: ${memoryMedia.size}');
  // final savedFile = await memoryMedia.saveTo('/output/video.mp4');
  // print('Saved to file: ${savedFile.file.path}');

  print('');
}

/// Example 7: Custom Media Types and Sources
void customMediaTypeExample() {
  print('--- Example 7: Custom Media Types ---');

  // Create custom sticker type
  final stickerType = StickerType();

  print('Custom media type:');
  print('  Type name: ${stickerType.runtimeType}');
  print('  Base type: ${stickerType.value}');

  // You can use custom types with the existing media sources
  // by creating type-specific wrappers or directly with OtherTypeMemoryMedia
  final stickerBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
  final stickerMedia = OtherTypeMemoryMedia(
    stickerBytes,
    name: 'emoji.webp',
    mimeType: 'image/webp',
  );

  print('Custom sticker media:');
  print('  Name: ${stickerMedia.name}');
  print('  Size: ${stickerMedia.size}');
  print('  Bytes: ${stickerMedia.bytes.length}');

  // Pattern match on custom type
  final typeDescription = stickerType.fold(
    video: (_) => 'Video',
    audio: (_) => 'Audio',
    image: (_) => 'Image',
    document: (_) => 'Document',
    url: (_) => 'URL',
    orElse: () => 'Custom sticker type! 🎨',
  );
  print('  Pattern match result: $typeDescription');

  print('');
  print('💡 Tip: To create a fully custom MediaSource, extend MediaSource<M>');
  print('   and implement ToFileConvertableMedia/ToMemoryConvertableMedia as needed.');
}

/// Example 8: Custom Media Factory
///
/// This example demonstrates how to create a custom factory that instantiates
/// different media source types based on custom conditions or business logic.
Future<void> customMediaFactoryExample() async {
  print('--- Example 7: Custom Media Factory ---');

  // Create a factory instance
  final factory = MediaFactory();

  // Create media from different sources based on conditions
  final fileMedia = await factory.createMedia(
    source: MediaSourceType.file,
    path: '/path/to/document.pdf',
    name: 'report.pdf',
  );

  final memoryMedia = factory.createMedia(
    source: MediaSourceType.memory,
    bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF]), // JPEG header
    name: 'photo.jpg',
    mimeType: 'image/jpeg',
  );

  final networkMedia = factory.createMedia(
    source: MediaSourceType.network,
    url: 'https://example.com/video.mp4',
    name: 'video.mp4',
    size: 100.mb,
  );

  print('File media: ${fileMedia?.name} (${fileMedia?.runtimeType})');
  print('Memory media: ${memoryMedia?.name} (${memoryMedia?.runtimeType})');
  print('Network media: ${networkMedia?.name} (${networkMedia?.runtimeType})');

  // Use factory with auto-detection based on input
  final autoDetected1 = await factory.createFromPath('/path/to/audio.mp3');
  final autoDetected2 = factory.createFromUrl('https://example.com/image.png', size: 2.mb);

  print('Auto-detected from path: ${autoDetected1?.runtimeType}');
  print('Auto-detected from URL: ${autoDetected2?.runtimeType}');

  // Factory with custom business logic
  final smartFactory = SmartMediaFactory(
    preferMemoryForSmallFiles: true,
    smallFileSizeThresholdMB: 5,
  );

  // This will choose memory or file based on size
  final optimizedMedia = await smartFactory.createOptimized(
    path: '/path/to/small-image.jpg',
    size: 2.mb, // Small file, might prefer memory
  );

  print('Optimized media type: ${optimizedMedia?.runtimeType}');

  print('');
  print('💡 Tip: Custom factories are useful for:');
  print('   - Centralizing media creation logic');
  print('   - Applying business rules (e.g., size limits, caching strategies)');
  print('   - Testing with mock media sources');
  print('   - Handling complex multi-source scenarios');
}

// ============================================================================
// Custom Media Type Implementation Example
// ============================================================================

/// Custom media type for stickers/emojis
///
/// This demonstrates how to create a custom media type by extending FileTypeImpl.
/// You can then use this type with existing media sources or create your own
/// specialized source classes.
class StickerType extends FileTypeImpl {
  StickerType() : super.copy(FileType.other);

  @override
  List<Object?> get props => const [];
}

// ============================================================================
// Custom Media Factory Implementation Example
// ============================================================================

/// Enum to specify media source type
enum MediaSourceType { file, memory, network }

/// Custom media factory that creates media instances based on conditions
///
/// This demonstrates how to centralize media creation logic and apply
/// business rules or optimizations when creating media sources.
class MediaFactory {
  /// Creates media based on the specified source type
  dynamic createMedia({
    required MediaSourceType source,
    String? path,
    Uint8List? bytes,
    String? url,
    String? name,
    String? mimeType,
    SizedFile? size,
    Duration? duration,
  }) async {
    switch (source) {
      case MediaSourceType.file:
        if (path == null) return null;
        return await _createFileMedia(
          path: path,
          name: name,
          duration: duration,
          size: size,
        );

      case MediaSourceType.memory:
        if (bytes == null) return null;
        return _createMemoryMedia(
          bytes: bytes,
          name: name,
          mimeType: mimeType,
          duration: duration,
        );

      case MediaSourceType.network:
        if (url == null) return null;
        return _createNetworkMedia(
          url: url,
          name: name,
          size: size,
          duration: duration,
        );
    }
  }

  /// Auto-detect media type from file path
  Future<MediaSource?> createFromPath(
    String path, {
    String? name,
    Duration? duration,
    SizedFile? size,
  }) async {
    return await _createFileMedia(
      path: path,
      name: name,
      duration: duration,
      size: size,
    );
  }

  /// Auto-detect media type from URL
  MediaSource? createFromUrl(
    String url, {
    String? name,
    SizedFile? size,
    Duration? duration,
  }) {
    return _createNetworkMedia(
      url: url,
      name: name,
      size: size,
      duration: duration,
    );
  }

  Future<MediaSource?> _createFileMedia({
    required String path,
    String? name,
    Duration? duration,
    SizedFile? size,
  }) async {
    final fileType = await FileType.fromPath(path);

    if (fileType is! FileTypeImpl) {
      return OtherTypeFileMedia.fromPath(path, name: name, size: size);
    }

    return fileType.fold(
      video: (_) => VideoFileMedia.fromPath(
        path,
        name: name,
        duration: duration,
        size: size,
      ),
      audio: (_) => AudioFileMedia.fromPath(
        path,
        name: name,
        duration: duration,
        size: size,
      ),
      image: (_) => ImageFileMedia.fromPath(path, name: name, size: size),
      document: (_) => DocumentFileMedia.fromPath(path, name: name, size: size),
      orElse: () => OtherTypeFileMedia.fromPath(path, name: name, size: size),
    );
  }

  MediaSource? _createMemoryMedia({
    required Uint8List bytes,
    String? name,
    String? mimeType,
    Duration? duration,
  }) {
    final fileType = FileType.fromBytes(bytes, mimeType);

    if (fileType is! FileTypeImpl) {
      return OtherTypeMemoryMedia(
        bytes,
        name: name ?? 'file.bin',
        mimeType: mimeType,
      );
    }

    return fileType.fold(
      video: (_) => VideoMemoryMedia(
        bytes,
        name: name ?? 'video.mp4',
        mimeType: mimeType,
        duration: duration,
      ),
      audio: (_) => AudioMemoryMedia(
        bytes,
        name: name ?? 'audio.mp3',
        mimeType: mimeType,
        duration: duration,
      ),
      image: (_) => ImageMemoryMedia(
        bytes,
        name: name ?? 'image.jpg',
        mimeType: mimeType,
      ),
      document: (_) => DocumentMemoryMedia(
        bytes,
        name: name ?? 'document.pdf',
        mimeType: mimeType,
      ),
      orElse: () => OtherTypeMemoryMedia(
        bytes,
        name: name ?? 'file.bin',
        mimeType: mimeType,
      ),
    );
  }

  MediaSource? _createNetworkMedia({
    required String url,
    String? name,
    SizedFile? size,
    Duration? duration,
  }) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final fileType = FileType.fromPath(url);

    if (fileType is! FileTypeImpl) {
      return null;
    }

    return fileType.fold(
      video: (_) => VideoNetworkMedia.url(
        url,
        name: name,
        size: size,
        duration: duration,
      ),
      audio: (_) => AudioNetworkMedia.url(
        url,
        name: name,
        size: size,
        duration: duration,
      ),
      image: (_) => ImageNetworkMedia.url(url, name: name, size: size),
      document: (_) => DocumentNetworkMedia.url(url, name: name, size: size),
      orElse: () => null,
    );
  }
}

/// Smart factory with business logic for optimal media handling
///
/// This factory applies custom rules to decide the best media source type
/// based on file size, availability, and other criteria.
class SmartMediaFactory {
  final bool preferMemoryForSmallFiles;
  final double smallFileSizeThresholdMB;

  SmartMediaFactory({
    this.preferMemoryForSmallFiles = true,
    this.smallFileSizeThresholdMB = 5.0,
  });

  /// Creates media with optimization based on file size
  Future<MediaSource?> createOptimized({
    required String path,
    SizedFile? size,
    Duration? duration,
  }) async {
    // If file is small and we prefer memory, load it into memory
    if (preferMemoryForSmallFiles && size != null && size.inBytes / (1024 * 1024) < smallFileSizeThresholdMB) {
      try {
        // In a real app, you would read the file and create memory media
        print(
          'Optimizing: Small file detected (${(size.inBytes / (1024 * 1024)).toStringAsFixed(2)}MB < ${smallFileSizeThresholdMB}MB), '
          'considering memory source for better performance',
        );

        // For demo purposes, return file media
        // In production, you'd load the file and return MemoryMediaSource
        return await _createFileMedia(path: path, size: size);
      } catch (e) {
        // Fallback to file media if reading fails
        return await _createFileMedia(path: path, size: size);
      }
    }

    // For large files, use file media
    return await _createFileMedia(path: path, size: size, duration: duration);
  }

  Future<MediaSource?> _createFileMedia({
    required String path,
    String? name,
    Duration? duration,
    SizedFile? size,
  }) async {
    final fileType = await FileType.fromPath(path);

    if (fileType is! FileTypeImpl) {
      return OtherTypeFileMedia.fromPath(path, name: name, size: size);
    }

    return fileType.fold(
      video: (_) => VideoFileMedia.fromPath(
        path,
        name: name,
        duration: duration,
        size: size,
      ),
      audio: (_) => AudioFileMedia.fromPath(
        path,
        name: name,
        duration: duration,
        size: size,
      ),
      image: (_) => ImageFileMedia.fromPath(path, name: name, size: size),
      document: (_) => DocumentFileMedia.fromPath(path, name: name, size: size),
      orElse: () => OtherTypeFileMedia.fromPath(path, name: name, size: size),
    );
  }
}
