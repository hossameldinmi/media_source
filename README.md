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
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-blue" alt="Platforms">
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
- 📁 **Multiple source types** - `FileMediaSource`, `MemoryMediaSource`, `NetworkMediaSource`, `AssetMediaSource`, `ThumbnailMediaSource`
- 🖼️ **Thumbnail support** - Pair high-quality media with lightweight previews for optimized loading
- 🔍 **Automatic media type detection** - From file paths, MIME types, and byte data
- 💥 **Pattern matching API** - Type-safe `fold()` for elegant source handling
- 🔄 **Seamless conversions** - Convert between source types (file ↔ memory ↔ asset)
- 💾 **Rich file operations** - Move, copy, save, and delete with atomic operations
- 🌐 **Cross-platform support** - Works on Flutter mobile, web, and desktop
- 📦 **Flutter asset integration** - Load and convert media from app asset bundles with custom bundle support
- ⚡ **Lazy loading support** - Optimize performance with size hints to avoid unnecessary data loading
- 📊 **MIME type utilities** - Comprehensive mapping of extensions to media types
- 🧩 **Extension-based lookups** - Quick type checks with pre-built extension sets
- � **Human-readable sizes** - Built-in integration with `file_sized` (1.5.mb, 2.gb, etc.)
- 💪 **Built on `cross_file`** - Seamless cross-platform file handling
- ✅ **100% test coverage** - Production-ready and thoroughly tested
- 🛡️ **Fully type-safe** - Compile-time safety with generic type parameters
- 🔗 **Unified API** - Consistent interface across all media sources

## Getting started

Add `media_source` to your `pubspec.yaml`:

```yaml
dependencies:
  media_source: ^1.3.0
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
import 'package:file_sized/file_sized.dart';

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
  thumbnail: (t) => 'Thumbnail: ${t.name}',
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
import 'package:file_sized/file_sized.dart';

Future<void> processMedia() async {
  // Create a video file media
  final video = await VideoFileMedia.fromPath(
    '/path/to/video.mp4',
    duration: Duration(minutes: 2),
  );
  
  // Create a thumbnail for the video
  final thumb = await ImageFileMedia.fromPath('/path/to/thumbnail.jpg');
  final mediaWithThumb = ThumbnailMediaSource<VideoType, ImageType>(
    original: video,
    thumbnail: thumb,
  );

  // Check media type and handle accordingly
  final result = mediaWithThumb.fold<String>(
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
    thumbnail: (thumbnailMedia) {
      // Handle thumbnail media with preview optimization
      final hasPreview = thumbnailMedia.hasThumbnail ? 'with preview' : 'no preview';
      print('Thumbnail size: ${thumbnailMedia.thumbnail?.size ?? 0} bytes');
      print('Original size: ${thumbnailMedia.original.size} bytes');
      return 'Thumbnail media $hasPreview: ${thumbnailMedia.name}';
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
  thumbnail: (t) => 'Thumbnail: ${t.name}',
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
  FileSize? size,
})
```

**ThumbnailMediaSource**
```dart
ThumbnailMediaSource({
  required MediaSource<M> original,
  MediaSource<T>? thumbnail,
})
```

### Working with **Thumbnail Media Source**

`ThumbnailMediaSource` is a powerful wrapper that pairs high-quality media with lightweight preview thumbnails, enabling optimized user experiences through progressive loading and bandwidth-efficient previews.

#### **When to Use Thumbnails**

✅ **Perfect for:**
- Video galleries (show thumbnail, load video on demand)
- Large image collections (display compressed previews)
- Media-rich feeds (load thumbnails first, full media on interaction)
- Bandwidth-constrained environments (mobile networks, slow connections)
- Progressive enhancement UX patterns

#### **Basic Usage**

```dart
import 'package:media_source/media_source.dart';

// 1. Create your sources
final video = await VideoFileMedia.fromPath('/storage/videos/movie.mp4');
final thumbnail = await ImageFileMedia.fromPath('/storage/cache/thumb_movie.jpg');

// 2. Wrap them in a ThumbnailMediaSource
// Types: <OriginalType, ThumbnailType>
final mediaWithThumb = ThumbnailMediaSource<VideoType, ImageType>(
  original: video,
  thumbnail: thumbnail,
);

// 3. Access properties (delegates to original)
print(mediaWithThumb.name);      // movie.mp4
print(mediaWithThumb.size);      // Size of the video file
print(mediaWithThumb.metadata);  // VideoType metadata

// 4. Check if thumbnail exists
if (mediaWithThumb.hasThumbnail) {
  // Show thumbnail in UI
  final preview = mediaWithThumb.thumbnail!; 
  print('Preview: ${preview.name}');
  print('Preview size: ${preview.size}'); // Much smaller than original
}

// 5. Smart display logic
// Use thumbnail if present, otherwise use original
final sourceToDisplay = mediaWithThumb.thumbnail ?? mediaWithThumb.original;
```

#### **Advanced Usage Patterns**

**Progressive Loading in UI:**
```dart
import 'package:media_source/media_source.dart';
import 'package:flutter/material.dart';

class VideoGalleryItem extends StatefulWidget {
  final ThumbnailMediaSource<VideoType, ImageType> media;
  
  const VideoGalleryItem({required this.media});
  
  @override
  State<VideoGalleryItem> createState() => _VideoGalleryItemState();
}

class _VideoGalleryItemState extends State<VideoGalleryItem> {
  bool _loadingFullVideo = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _loadFullVideo(),
      child: Stack(
        children: [
          // Show thumbnail immediately
          if (widget.media.hasThumbnail)
            Image.memory(widget.media.thumbnail!.bytes),
          
          // Overlay with video info
          Positioned(
            bottom: 8,
            right: 8,
            child: Text('${widget.media.metadata.duration}'),
          ),
          
          // Loading indicator
          if (_loadingFullVideo)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
  
  Future<void> _loadFullVideo() async {
    setState(() => _loadingFullVideo = true);
    // Load and play the full video
    final videoFile = widget.media.original;
    // ... play video ...
    setState(() => _loadingFullVideo = false);
  }
}
```

**Network Media with Thumbnail:**
```dart
import 'package:media_source/media_source.dart';
import 'package:file_sized/file_sized.dart';

// Create network video with thumbnail
final videoUrl = 'https://example.com/videos/movie.mp4';
final thumbUrl = 'https://example.com/thumbnails/movie_thumb.jpg';

final video = VideoNetworkMedia.url(
  videoUrl,
  name: 'movie.mp4',
  size: 150.mb,
  duration: Duration(minutes: 90),
);

final thumbnail = ImageNetworkMedia.url(
  thumbUrl,
  name: 'movie_thumb.jpg',
  size: 50.kb, // Much smaller!
);

// Combine them
final mediaWithThumb = ThumbnailMediaSource<VideoType, ImageType>(
  original: video,
  thumbnail: thumbnail,
);

// In your UI, load thumbnail first (50KB)
// Then load full video only when user clicks (150MB)
```

**Generate Thumbnails from Video:**
```dart
import 'package:media_source/media_source.dart';

// Load original video
final video = await VideoFileMedia.fromPath('/path/to/video.mp4');

// Generate thumbnail (using your preferred video thumbnail package)
// Example: video_thumbnail, flutter_video_thumbnail, etc.
final thumbnailBytes = await generateVideoThumbnail(video.file.path);

final thumbnail = ImageMemoryMedia(
  thumbnailBytes,
  name: 'video_thumb.jpg',
  mimeType: 'image/jpeg',
);

// Create thumbnail media source
final mediaWithThumb = ThumbnailMediaSource<VideoType, ImageType>(
  original: video,
  thumbnail: thumbnail,
);

// Optionally save thumbnail for future use
await thumbnail.saveTo('/cache/thumbnails/video_thumb.jpg');
```

**Handling Missing Thumbnails:**
```dart
import 'package:media_source/media_source.dart';

// Create media source without thumbnail initially
final video = await VideoFileMedia.fromPath('/path/to/video.mp4');
final mediaWithThumb = ThumbnailMediaSource<VideoType, ImageType>(
  original: video,
  // thumbnail: null, // Optional - can be null
);

// Check before using
if (mediaWithThumb.hasThumbnail) {
  // Show thumbnail
  displayThumbnail(mediaWithThumb.thumbnail!);
} else {
  // Show placeholder or generate thumbnail on-demand
  showPlaceholder();
}

// Later, add thumbnail when available
final generatedThumb = await generateThumbnail(video);
final updatedMedia = ThumbnailMediaSource<VideoType, ImageType>(
  original: video,
  thumbnail: generatedThumb,
);
```

**Mixed Media Types:**
```dart
import 'package:media_source/media_source.dart';

// Large image with compressed preview
final highResImage = await ImageFileMedia.fromPath('/photos/4k_photo.jpg');
final compressedPreview = await ImageFileMedia.fromPath('/cache/photo_preview.jpg');

final photoWithPreview = ThumbnailMediaSource<ImageType, ImageType>(
  original: highResImage,
  thumbnail: compressedPreview,
);

// Audio with album art
final audioTrack = await AudioFileMedia.fromPath('/music/song.mp3');
final albumArt = await ImageFileMedia.fromPath('/music/covers/album.jpg');

final musicWithArt = ThumbnailMediaSource<AudioType, ImageType>(
  original: audioTrack,
  thumbnail: albumArt,
);
```

**Pattern Matching with Thumbnails:**
```dart
import 'package:media_source/media_source.dart';

final media = ThumbnailMediaSource<VideoType, ImageType>(
  original: video,
  thumbnail: thumbnail,
);

// Pattern matching works seamlessly
final result = media.fold(
  file: (f) => 'File source: ${f.file.path}',
  memory: (m) => 'Memory source: ${m.size} bytes',
  network: (n) => 'Network source: ${n.uri}',
  asset: (a) => 'Asset source: ${a.assetPath}',
  thumbnail: (t) {
    final hasThumb = t.hasThumbnail ? 'with' : 'without';
    return 'Thumbnail source $hasThumb preview: ${t.name}';
  },
  orElse: () => 'Unknown source',
);
```

#### **Key Features**

- 🎯 **Type-safe dual generics** - Separate types for original and thumbnail
- 📊 **Automatic delegation** - Properties delegate to original media
- 🔄 **Optional thumbnails** - Thumbnails can be null, check with `hasThumbnail`
- 🧩 **Pattern matching** - Full support in `fold()` operations
- ⚡ **Performance optimization** - Load small thumbnails first, full media on demand
- 🌐 **Works with all sources** - File, Memory, Network, and Asset media
- 💾 **Bandwidth efficient** - Ideal for mobile and slow connections

#### **Best Practices**

1. **Always check `hasThumbnail`** before accessing the thumbnail
2. **Use compressed images** for thumbnails (JPEG with lower quality)
3. **Keep thumbnails small** - typically 50-200KB for videos, 10-50KB for images
4. **Cache thumbnails** - Save generated thumbnails to avoid regeneration
5. **Progressive loading** - Show thumbnail immediately, load full media on interaction
6. **Consider aspect ratio** - Maintain original aspect ratio in thumbnails
7. **Lazy generation** - Only generate thumbnails when needed


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
import 'package:file_sized/file_sized.dart';

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
    FileSize? size,
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
    FileSize? size,
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
- Size handling powered by [file_sized](https://pub.dev/packages/file_sized)