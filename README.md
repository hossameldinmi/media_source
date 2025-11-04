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

A Flutter package for handling different media sources with automatic type detection and metadata extraction.

## Features

- 🎯 **Type-safe media source abstraction** - Handle files, memory, and network sources uniformly
- 📁 **Multiple source types** - `FileMediaSource`, `MemoryMediaSource`, `NetworkMediaSource`
- 🔍 **Automatic media type detection** - From file paths, MIME types, and byte data
- ⏱️ **Duration metadata extraction** - Get duration for audio/video files
- 🌐 **Cross-platform support** - Works on Flutter mobile, web, and desktop
- 📊 **MIME type utilities** - Comprehensive mapping of extensions to media types
- 🧩 **Extension-based lookups** - Quick checks with pre-built extension sets
- 🔗 **Built on `cross_file`** - Seamless cross-platform file handling

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
import 'package:cross_file/cross_file.dart';

// Create a file media source
final file = XFile('/path/to/video.mp4');
final mediaSource = FileMediaSource(file);

// Access media type and metadata
print(mediaSource.mediaType); // VideoType with duration
print(await file.size()); // File size in bytes
print(await file.exists()); // Check if file exists

// Delete file
await file.delete();
```

### Working with Memory Media Source

```dart
import 'package:media_source/media_source.dart';
import 'dart:typed_data';

// Create from byte data
final bytes = Uint8List.fromList([/* your data */]);
final memorySource = MemoryMediaSource(
  bytes,
  mimeType: 'audio/mpeg',
  name: 'song.mp3',
);

print(memorySource.mediaType); // AudioType
```

### Working with Network Media Source

```dart
import 'package:media_source/media_source.dart';

// Create from URL
final networkSource = NetworkMediaSource(
  'https://example.com/video.mp4',
);

print(networkSource.mediaType); // VideoType
print(networkSource.url); // https://example.com/video.mp4
```

### Using MIME Groups Utility

```dart
import 'package:media_source/src/utils/mime_groups.dart';

// Check if an extension is of a specific type
if (isExtensionOfType('mp4', MediaType.video)) {
  print('MP4 is a video file');
}

// Get media type from extension
final type = mediaTypeForExtension('.jpg');
print(type); // MediaType.image

// Use pre-built extension sets
print(imageExtensions.contains('png')); // true
print(audioExtensions.contains('mp3')); // true
print(videoExtensions.contains('mkv')); // true

// All available sets:
// - imageExtensions
// - audioExtensions
// - videoExtensions
// - documentExtensions
// - otherExtensions
```

### Type-Specific Operations with Pattern Matching

```dart
import 'package:media_source/media_source.dart';

final mediaType = MediaType.fromPath('song.mp3', 'audio/mpeg');

final result = mediaType.when(
  audio: (audio) => 'Audio file with duration: ${audio.duration}',
  video: (video) => 'Video file with duration: ${video.duration}',
  image: (image) => 'Image file',
  document: (doc) => 'Document file',
  url: (url) => 'URL reference',
  orElse: () => 'Other file type',
);

print(result);
```

### Extracting Media Metadata

```dart
import 'package:media_source/src/utils/file_util.dart';

// From file path
final metadata = await FileUtil.getFileMetadata(
  '/path/to/video.mp4',
  MediaType.video,
);
print(metadata?.duration); // Duration(...)
print(metadata?.mimeType); // video/mp4

// From bytes
final metadataFromBytes = await FileUtil.getFileMetadataFromBytes(
  bytes,
  MediaType.audio,
  'audio/mpeg',
  'song.mp3',
);
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

### FileUtil

Static utility methods:

- `String? getMimeTypeFromPath(String path)` - Get MIME type from file path
- `String? getMimeTypeFromBytes(List<int> bytes)` - Get MIME type from byte header
- `Future<MediaMetadata?> getFileMetadata(String path, MediaType mediaType)` - Extract metadata from file
- `Future<MediaMetadata?> getFileMetadataFromBytes(Uint8List bytes, MediaType mediaType, String? mimeType, String? fileName)` - Extract metadata from bytes

## Supported Media Types

The package automatically detects and categorizes hundreds of file extensions including:

**Images**: jpg, jpeg, png, gif, bmp, webp, svg, ico, tiff, avif, heic, heif, and more

**Audio**: mp3, aac, wav, flac, ogg, m4a, wma, opus, and more

**Video**: mp4, mov, avi, mkv, webm, flv, wmv, m4v, 3gp, and more

**Documents**: pdf

**Other**: All other MIME types and extensions

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

- Built with [mime](https://pub.dev/packages/mime) package for MIME type detection
- Uses [cross_file](https://pub.dev/packages/cross_file) for cross-platform file handling
- Media metadata extraction powered by [flutter_media_metadata](https://pub.dev/packages/flutter_media_metadata)