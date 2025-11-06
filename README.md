<img src="https://github.com/hossameldinmi/media_source/raw/main/assets/wallpaper.png" alt="wallpaper" />


<h2 align="center">
  Media Source
</h2>

<p align="center">
   <a href="https://github.com/hossameldinmi/media_source/actions/workflows/build.yml">
    <img src="https://github.com/hossameldinmi/media_source/actions/workflows/build.yml/badge.svg?branch=main" alt="Github action">
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

A **type-safe**, **cross-platform** Flutter package that unifies media handling from **files**, **memory**, and **network** sources with **automatic type detection** and **seamless conversions**.

## Motivation

When building **media-rich applications**, you often need to handle media from **multiple sources**: **files** stored locally, data in **memory** (like camera captures or downloaded content), **URLs** from remote servers, and **assets** bundled with your app. Managing these different states becomes complex when you need to:

Inspired by Flutter's ```ImageProvider```, which unifies images from **assets**, **files**, **memory**, and **network** under a single API, this library applies the same idea to general media. The goal is to let you **swap sources freely** without changing your business logic.

- Load a **file** from disk, process it in **memory**, then **upload** it
- **Download** media from a URL, **cache** it locally, and **convert** it between formats
- Use bundled **assets** during development, then switch to **network** sources in production
- Handle **user-selected files**, **camera captures**, **network resources**, and **app assets** uniformly
- Switch between sources **without rewriting** your business logic

This package provides a **unified**, **type-safe API** to handle all these scenarios. Whether your media starts as a file, exists in memory, or comes from a network URL, you can work with it **consistently** and **convert between states** seamlessly.

## Features

- 🎯 **Type-safe media source abstraction** - Handle files, memory, network, and assets uniformly
- 📁 **Multiple source types** - `FileMediaSource`, `MemoryMediaSource`, `NetworkMediaSource`, `AssetMediaSource`
- 🔍 **Automatic media type detection** - From file paths, MIME types, and byte data
- � **Pattern matching API** - Type-safe `fold()` for elegant source handling
- 🔄 **Seamless conversions** - Convert between source types (file ↔ memory ↔ asset)
- 💾 **Rich file operations** - Move, copy, save, and delete with atomic operations
- �🌐 **Cross-platform support** - Works on Flutter mobile, web, and desktop
- 📦 **Flutter asset integration** - Load and convert media from app asset bundles with custom bundle support
- ⚡ **Lazy loading support** - Optimize performance with size hints to avoid unnecessary data loading
- 📊 **MIME type utilities** - Comprehensive mapping of extensions to media types
- 🧩 **Extension-based lookups** - Quick type checks with pre-built extension sets
- � **Human-readable sizes** - Built-in integration with `sized_file` (1.5.mb, 2.gb, etc.)
- 💪 **Built on `cross_file`** - Seamless cross-platform file handling
- ✅ **100% test coverage** - Production-ready and thoroughly tested
- 🛡️ **Fully type-safe** - Compile-time safety with generic type parameters
- 🔗 **Unified API** - Consistent interface across all media sources

## Getting started

Add `media_source` to your `pubspec.yaml`:

```yaml
dependencies:
  media_source: ^1.0.0
```

Then run:

```bash
flutter pub get
```

> 💡 **Quick Start**: Check out the complete [example/main.dart](example/main.dart) file for a comprehensive demonstration of all features.

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

### Working with **File Media Source**

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

### Working with **Memory Media Source**

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

### Working with **Network Media Source**

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

### Working with **Asset Media Source**

```dart
import 'package:media_source/media_source.dart';
import 'package:flutter/services.dart' show rootBundle;

// First, declare assets in your pubspec.yaml:
// flutter:
//   assets:
//     - assets/videos/
//     - assets/audio/
//     - assets/images/

// Load video asset
final video = await VideoAssetMedia.load(
  'assets/videos/intro.mp4',
  duration: Duration(seconds: 30),
  bundle: rootBundle, // optional, defaults to rootBundle
);

// Load audio asset
final audio = await AudioAssetMedia.load(
  'assets/audio/song.mp3',
  duration: Duration(minutes: 3, seconds: 45),
);

// Load image asset
final image = await ImageAssetMedia.load(
  'assets/images/logo.png',
);

// Access properties
print(video.assetPath); // assets/videos/intro.mp4
print(video.name); // intro.mp4
print(video.size); // Size in bytes
print(video.metadata.duration); // Duration(seconds: 30)

// Optimized loading with size hint (avoids loading entire asset)
final largeVideo = await VideoAssetMedia.load(
  'assets/videos/movie.mp4',
  duration: Duration(minutes: 90),
  size: 150.mb, // Provide size to avoid loading asset just to get size
);

// Convert to memory for processing
final memoryMedia = await video.convertToMemory();
print(memoryMedia.bytes.length); // Full asset loaded in memory

// Save asset to file system
final fileMedia = await video.saveTo('/path/to/save/intro.mp4');
print(fileMedia.file.path); // /path/to/save/intro.mp4

// Pattern matching works with asset media
final result = video.fold(
  file: (f) => 'File: ${f.file.path}',
  memory: (m) => 'Memory: ${m.size}',
  network: (n) => 'Network: ${n.uri}',
  asset: (a) => 'Asset: ${a.assetPath}',
  orElse: () => 'Unknown source',
);
print(result); // Asset: assets/videos/intro.mp4
```

**Asset Media Features:**
- 📦 **Flutter asset bundle integration** - Load media from app assets
- 🎯 **Type-safe asset loading** - Video, Audio, Image, Document asset types
- 🔄 **Seamless conversions** - Convert assets to memory or file sources
- 💾 **Lazy loading** - Provide size hint to avoid loading entire asset
- 🧩 **Pattern matching support** - Works with fold() for consistent API
- ✅ **Cross-platform** - Works on all Flutter platforms

> 💡 **Interactive Example**: Check out [example/asset_media_example.dart](example/asset_media_example.dart) for a complete Flutter app demonstrating all asset media features with an interactive UI.

### **Complete Example**

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
    asset: (assetMedia) {
      return 'Asset media: ${assetMedia.assetPath}';
    },
    orElse: () => 'Unknown media type',
  );

  print(result);
}
```

### **Type-Specific Operations** with **Pattern Matching**

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
  asset: (a) => 'Asset: ${a.assetPath}',
  orElse: () => 'Unknown source',
);

print(info); // File: /path/to/video.mp4
```

### **Extension Methods** on **XFile**

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

### **MediaType**

Base class for **media type classification**:

- `MediaType.image` - Image files
- `MediaType.audio` - Audio files
- `MediaType.video` - Video files
- `MediaType.document` - PDF documents
- `MediaType.url` - URL references
- `MediaType.other` - Other file types

**Subtypes:**
- `ImageType` - Image media
- `AudioType` - Audio media with **optional duration**
- `VideoType` - Video media with **optional duration**
- `DocumentType` - Document media (PDF)
- `UrlType` - URL references
- `OtherType` - Unclassified media

**Methods:**
- `MediaType.fromPath(String path, String? mimeType)` - Create from **file path**
- `MediaType.fromBytes(Uint8List bytes, String? mimeType)` - Create from **byte data**
- `when<T>({...})` - **Pattern matching** for type-specific operations
- `isAny(List<MediaType> list)` - Check if type is in list
- `isAnyType(List<Type> list)` - Check if runtime type is in list

### **MediaSource Implementations**

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

**AssetMediaSource**
```dart
AssetMediaSource.load(
  String assetPath, {
  AssetBundle? bundle,
  SizedFile? size,
})
```

### **MIME Groups Utilities**

**Maps:**
- `extensionToMediaType` - Map<String, MediaType>
- `mediaTypeExtensions` - Map<MediaType, Set<String>>

**Sets:**
- `imageExtensions` - All **image** file extensions
- `audioExtensions` - All **audio** file extensions
- `videoExtensions` - All **video** file extensions
- `documentExtensions` - All **document** file extensions
- `otherExtensions` - All **other** file extensions

**Functions:**
- `MediaType mediaTypeForExtension(String extension)` - Get MediaType for an extension
- `bool isExtensionOfType(String extension, MediaType type)` - Check if extension matches type

## Supported Media Types

The package **automatically detects** and categorizes **hundreds of file extensions** including:

**Images**: jpg, jpeg, png, gif, bmp, webp, svg, ico, tiff, avif, heic, heif, and more

**Audio**: mp3, aac, wav, flac, ogg, m4a, wma, opus, and more

**Video**: mp4, mov, avi, mkv, webm, flv, wmv, m4v, 3gp, and more

**Documents**: pdf

**Other**: All other MIME types and extensions

## Extensibility

You can **extend** the package to fit **custom domain needs**:

- Create a **new media type** by extending `FileTypeImpl` (see `lib/src/media_type.dart`).
- Create a **new media source** by extending `MediaSource<M extends FileType>` or by
  implementing the **conversion mixins** (`ToFileConvertableMedia`, `ToMemoryConvertableMedia`).
- Create a **custom media factory** to centralize media creation logic and apply business rules.

### Custom Type and Source Example

Example — **custom type** and **source**:

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
  Future<FileMediaSource<StickerType>> saveTo(String path) async {
    final file = XFile.fromData(bytes, name: name, path: path);
    await PlatformUtils.instance.createDirectoryIfNotExists(path);
    await file.saveTo(path);
    // Return your own FileMediaSource<StickerType> implementation here
    throw UnimplementedError();
  }
}
```

### Custom Media Factory Example

You can create **custom factories** to centralize media instantiation logic and apply business rules:

```dart
import 'dart:typed_data';
import 'package:media_source/media_source.dart';
import 'package:sized_file/sized_file.dart';

/// Enum to specify media source type
enum MediaSourceType { file, memory, network }

/// Custom factory that creates media based on conditions
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
        if (path != null) {
          final fileType = await FileType.fromPath(path);
          if (fileType is VideoType) {
            return VideoFileMedia.fromPath(path, name: name, duration: duration);
          }
          // Handle other types...
        }
        break;
      case MediaSourceType.memory:
        if (bytes != null) {
          final fileType = FileType.fromBytes(bytes, mimeType);
          if (fileType is ImageType) {
            return ImageMemoryMedia(bytes, name: name ?? 'image.jpg');
          }
          // Handle other types...
        }
        break;
      case MediaSourceType.network:
        if (url != null) {
          return VideoNetworkMedia.url(url, name: name, size: size);
        }
        break;
    }
    return null;
  }
}

/// Smart factory with optimization logic
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
  }) async {
    // For small files, prefer memory for better performance
    if (preferMemoryForSmallFiles && 
        size != null && 
        size.inMB < smallFileSizeThresholdMB) {
      // Load into memory for fast access
      // In production: read file and return MemoryMediaSource
    }
    
    // For large files, use file media
    return await VideoFileMedia.fromPath(path, size: size);
  }
}
```

**Benefits of custom factories:**
- **Centralize** media creation logic
- Apply **business rules** (size limits, caching strategies)
- Enable **testing** with mock media sources
- Handle **complex multi-source** scenarios
- Implement **optimization strategies** (memory vs. file based on size)

> 💡 See the complete factory example in [example/main.dart](example/main.dart)

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

Hossam Eldin Mahmoud - [GitHub](https://github.com/hossameldinmi), [LinkedIn](https://linkedin.com/in/hossameldinmi)

### Acknowledgments

- Uses [cross_file](https://pub.dev/packages/cross_file) for cross-platform file handling
- Built with [file_type_plus](https://pub.dev/packages/file_type_plus) for file type detection
- Size handling powered by [sized_file](https://pub.dev/packages/sized_file)