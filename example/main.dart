import 'dart:typed_data';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/media_source.dart';

/// Example demonstrating the media_source package capabilities.
///
/// This example shows:
/// - Working with file, memory, and network media sources
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

  // Example 4: Pattern Matching with fold
  await patternMatchingExample();

  // Example 5: Converting Between Sources
  await conversionExample();

  // Example 6: Custom Media Types
  customMediaTypeExample();
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

/// Example 4: Pattern Matching with fold
Future<void> patternMatchingExample() async {
  print('--- Example 4: Pattern Matching ---');

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

/// Example 5: Converting Between Sources
Future<void> conversionExample() async {
  print('--- Example 5: Converting Between Sources ---');

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
  // final savedFile = await memoryMedia.saveToFile('/output/video.mp4');
  // print('Saved to file: ${savedFile.file.path}');

  print('');
}

/// Example 6: Custom Media Types and Sources
void customMediaTypeExample() {
  print('--- Example 6: Custom Media Types ---');

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
