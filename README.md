<h2 align="center">
  Media Source
</h2>

<p align="center">
   <a href="https://github.com/hossameldinmi/media_source/actions/workflows/dart.yml">
    <img src="https://github.com/hossameldinmi/media_source/actions/workflows/dart.yml/badge.svg?branch=main" alt="Github action">
  </a>
  <a href="https://codecov.io/github/hossameldinmi/media_source">
    <img src="https://codecov.io/github/hossameldinmi/media_source/graph/badge.svg?token=JzTIIzoQOq" alt="Code Coverage">
  </a>
  <a href="https://pub.dev/packages/media_source">
    <img alt="Pub Package" src="https://img.shields.io/pub/v/media_source">
  </a>
   <a href="https://pub.dev/packages/media_source">
    <img alt="Pub Points" src="https://img.shields.io/pub/points/media_source">
  </a>
  <br/>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
</p>

---

A Flutter package for handling different media sources with automatic type detection.

## Motivation

When building media-rich applications, you often need to handle media from multiple sources: files stored locally, data in memory (like camera captures or downloaded content), and URLs from remote servers. Managing these different states becomes complex when you need to:

Inspired by Flutter’s ImageProvider, which unifies images from assets, files, memory, and network under a single API, this library applies the same idea to general media. The goal is to let you swap sources freely without changing your business logic.

- Load a file from disk, process it in memory, then upload it
- Download media from a URL, cache it locally, and convert it between formats
- Handle user-selected files, camera captures, and network resources uniformly
- Switch between sources without rewriting your business logic

This package provides a unified, type-safe API to handle all these scenarios. Whether your media starts as a file, exists in memory, or comes from a network URL, you can work with it consistently and convert between states seamlessly.

## Features

- 🎯 **Type-safe media source abstraction** - Handle files, memory, and network sources uniformly
- 📁 **Multiple source types** - `FileMediaSource`, `MemoryMediaSource`, `NetworkMediaSource`
- 🔍 **Automatic media type detection** - From file paths, MIME types, and byte data
- 🌐 **Cross-platform support** - Works on Flutter mobile, web, and desktop
- 📊 **MIME type utilities** - Comprehensive mapping of extensions to media types
- 🧩 **Extension-based lookups** - Quick checks with pre-built extension sets
- 🔄 **Flexible conversions** - Convert between different source types (e.g., file to memory)
- 💾 **File operations** - Move, copy, save, and delete operations for file-based media
- � **Built on `cross_file`** - Seamless cross-platform file handling
- ✅ **100% test coverage** - Thoroughly tested and reliable

## Getting started

Add `media_source` to your `pubspec.yaml`:

```yaml
dependencies:
  media_source: ^0.2.0-alpha.2
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Media Type Detection

```dart
import 'package:media_source/media_source.dart';

// Detect from file path
final imageType = MediaType.fromPath('/path/to/photo.jpg', 'image/jpeg');
print(imageType); // ImageType

// Detect from bytes
final bytes = await file.readAsBytes();
final videoType = MediaType.fromBytes(bytes, 'video/mp4');
print(videoType); // VideoType
```

### Working with File Media Source

```dart
import 'package:media_source/media_source.dart';

// Create from file path
final video = await VideoFileMedia.fromPath(
  '/path/to/video.mp4',
  duration: Duration(seconds: 120),
);

// Access properties
print(video.name); // video.mp4
print(video.size); // File size
print(video.metadata.duration); // Duration(seconds: 120)

// File operations
await video.saveTo('/backup/video.mp4');
await video.moveTo('/new/location/video.mp4');
final memoryMedia = await video.convertToMemory();
await video.delete();

// Create from XFile
final file = XFile('/path/to/audio.mp3');
final audio = await AudioFileMedia.fromFile(
  file,
  name: 'song.mp3',
  duration: Duration(minutes: 3),
);
```

### Working with Memory Media Source

```dart
import 'package:media_source/media_source.dart';
import 'dart:typed_data';

// Create from byte data
final bytes = Uint8List.fromList([/* your data */]);
final image = ImageMemoryMedia(
  bytes,
  name: 'photo.jpg',
  mimeType: 'image/jpeg',
);

// Access properties
print(image.bytes); // Uint8List
print(image.size); // Size in bytes
print(image.name); // photo.jpg

// Save to file system
final fileMedia = await image.saveToFolder('/images');
print(fileMedia.file.path); // /images/photo.jpg

// Convert to different types
final videoMemory = VideoMemoryMedia(
  videoBytes,
  name: 'clip.mp4',
  duration: Duration(seconds: 10),
);
```

### Working with Network Media Source

```dart
import 'package:media_source/media_source.dart';
import 'package:sized_file/sized_file.dart';

// Create from URL with automatic type detection
final media = NetworkMediaSource.fromUrl(
  'https://example.com/video.mp4',
  mediaType: FileType.video,
  size: 5.mb,
  name: 'video.mp4',
);

// Create type-specific network media
final video = VideoNetworkMedia.url(
  'https://example.com/movie.mp4',
  name: 'movie.mp4',
  size: 150.mb,
  duration: Duration(minutes: 90),
);

final audio = AudioNetworkMedia(
  Uri.parse('https://example.com/song.mp3'),
  name: 'song.mp3',
  size: 5.mb,
  duration: Duration(minutes: 3, seconds: 45),
);

final image = ImageNetworkMedia.url(
  'https://example.com/photo.jpg',
  name: 'photo.jpg',
  size: 2.mb,
);

// Access properties
print(video.uri); // Uri object
print(video.name); // movie.mp4
print(video.size); // 150 MB
print(video.metadata.duration); // Duration
```

### Complete Example

```dart
import 'package:media_source/media_source.dart';
import 'package:sized_file/sized_file.dart';

Future<void> processMedia() async {
  // Create a video file media
  final video = await VideoFileMedia.fromPath(
    '/path/to/video.mp4',
    duration: Duration(minutes: 2),
  );

  // Check media type and handle accordingly
  final result = video.fold<String>(
    file: (fileMedia) async {
      // Save a backup
      await fileMedia.saveTo('/backup/video.mp4');
      
      // Convert to memory for processing
      final memoryMedia = await fileMedia.convertToMemory();
      
      // Process the bytes
      print('Processing ${memoryMedia.bytes.length} bytes');
      
      return 'File processed: ${fileMedia.name}';
    },
    memory: (memoryMedia) {
      return 'Memory media: ${memoryMedia.size}';
    },
    network: (networkMedia) {
      return 'Network media: ${networkMedia.uri}';
    },
    orElse: () => 'Unknown media type',
  );

  print(result);
}
```

### Type-Specific Operations with Pattern Matching

```dart
import 'package:media_source/media_source.dart';

// Pattern matching on MediaType
final mediaType = MediaType.fromPath('song.mp3', 'audio/mpeg');

final description = mediaType.fold(
  audio: (audio) => 'Audio file with duration: ${audio.duration}',
  video: (video) => 'Video file with duration: ${video.duration}',
  image: (image) => 'Image file',
  document: (doc) => 'Document file',
  url: (url) => 'URL reference',
  orElse: () => 'Other file type',
);

print(description);

// Pattern matching on MediaSource
final media = await VideoFileMedia.fromPath('/path/to/video.mp4');

final info = media.fold(
  file: (f) => 'File: ${f.file.path}',
  memory: (m) => 'Memory: ${m.size}',
  network: (n) => 'URL: ${n.uri}',
  orElse: () => 'Unknown source',
);

print(info); // File: /path/to/video.mp4
```

### Extension Methods on XFile

```dart
import 'package:media_source/media_source.dart';
import 'package:cross_file/cross_file.dart';

final file = XFile('/path/to/document.pdf');

// Get media type
print(file.mediaType); // DocumentType

// Get file name
print(file.name); // document.pdf

// Get size
final size = await file.size();

// Check existence
if (await file.exists()) {
  // Delete if exists
  await file.delete();
}
```

## API Reference

### MediaType

Base class for media type classification:

- `MediaType.image` - Image files
- `MediaType.audio` - Audio files
- `MediaType.video` - Video files
- `MediaType.document` - PDF documents
- `MediaType.url` - URL references
- `MediaType.other` - Other file types

**Subtypes:**
- `ImageType` - Image media
- `AudioType` - Audio media with optional duration
- `VideoType` - Video media with optional duration
- `DocumentType` - Document media (PDF)
- `UrlType` - URL references
- `OtherType` - Unclassified media

**Methods:**
- `MediaType.fromPath(String path, String? mimeType)` - Create from file path
- `MediaType.fromBytes(Uint8List bytes, String? mimeType)` - Create from byte data
- `when<T>({...})` - Pattern matching for type-specific operations
- `isAny(List<MediaType> list)` - Check if type is in list
- `isAnyType(List<Type> list)` - Check if runtime type is in list

### MediaSource Implementations

**FileMediaSource**
```dart
FileMediaSource(XFile file)
```

**MemoryMediaSource**
```dart
MemoryMediaSource(
  Uint8List bytes, {
  String? mimeType,
  String? name,
})
```

**NetworkMediaSource**
```dart
NetworkMediaSource(String url)
```

### MIME Groups Utilities

**Maps:**
- `extensionToMediaType` - Map<String, MediaType>
- `mediaTypeExtensions` - Map<MediaType, Set<String>>

**Sets:**
- `imageExtensions` - All image file extensions
- `audioExtensions` - All audio file extensions
- `videoExtensions` - All video file extensions
- `documentExtensions` - All document file extensions
- `otherExtensions` - All other file extensions

**Functions:**
- `MediaType mediaTypeForExtension(String extension)` - Get MediaType for an extension
- `bool isExtensionOfType(String extension, MediaType type)` - Check if extension matches type

## Supported Media Types

The package automatically detects and categorizes hundreds of file extensions including:

**Images**: jpg, jpeg, png, gif, bmp, webp, svg, ico, tiff, avif, heic, heif, and more

**Audio**: mp3, aac, wav, flac, ogg, m4a, wma, opus, and more

**Video**: mp4, mov, avi, mkv, webm, flv, wmv, m4v, 3gp, and more

**Documents**: pdf

**Other**: All other MIME types and extensions

## Extensibility

You can extend the package to fit custom domain needs:

- Create a new media type by extending `FileTypeImpl` (see `lib/src/media_type.dart`).
- Create a new media source by extending `MediaSource<M extends FileType>` or by
  implementing the conversion mixins (`ToFileConvertableMedia`, `ToMemoryConvertableMedia`).

Example — custom type and source:

```dart
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:media_source/media_source.dart';

class StickerType extends FileTypeImpl {
  StickerType() : super.copy(FileType.other);
  @override
  List<Object?> get props => const [];
}

class StickerMemoryMedia extends MemoryMediaSource<StickerType> {
  StickerMemoryMedia(Uint8List bytes, {required String name})
      : super._(bytes, name: name, metadata: StickerType());

  @override
  Future<FileMediaSource<StickerType>> saveToFile(String path) async {
    final file = XFile.fromData(bytes, name: name, path: path);
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    // Return your own FileMediaSource<StickerType> implementation here
    throw UnimplementedError();
  }
}
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## Additional information

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

If you encounter any issues or have suggestions, please file them in the [issue tracker](https://github.com/hossameldinmi/media_source/issues).

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Author

Hossam Eldin - [GitHub](https://github.com/hossameldinmi)

### Acknowledgments

- Uses [cross_file](https://pub.dev/packages/cross_file) for cross-platform file handling
- Built with [file_type_plus](https://pub.dev/packages/file_type_plus) for file type detection
- Size handling powered by [sized_file](https://pub.dev/packages/sized_file)