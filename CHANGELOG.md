# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0-alpha.1] - 2025-11-03

### Added
- Initial release of the `media_source` package
- Core `MediaSource` abstraction for handling different media sources
- `FileMediaSource` implementation for local file system access
  - Support for file operations (delete, exists, size)
  - Automatic MIME type detection
  - Media metadata extraction
- `MemoryMediaSource` implementation for in-memory media data
  - Support for `Uint8List` byte arrays
  - MIME type detection from byte headers
- `NetworkMediaSource` implementation for remote URL media
  - URL validation and parsing
  - Automatic media type detection from URLs
- `MediaType` classification system with subtypes:
  - `ImageType` - for image files
  - `AudioType` - for audio files with duration support
  - `VideoType` - for video files with duration support
  - `DocumentType` - for PDF documents
  - `UrlType` - for URL references
  - `OtherType` - for unclassified files
- Media type detection from:
  - File paths using MIME type lookup
  - MIME type strings
  - Byte data headers
- File utilities (`file_util.dart`):
  - `getMimeTypeFromPath()` - detect MIME from file path
  - `getMimeTypeFromBytes()` - detect MIME from byte data
  - `getFileMetadata()` - extract duration and MIME from media files
  - `getFileMetadataFromBytes()` - extract metadata from byte arrays
- MIME groups utility (`mime_groups.dart`):
  - Extension to `MediaType` mapping derived from `mime` package
  - Grouped extension sets by media type
  - Pre-built sets: `imageExtensions`, `audioExtensions`, `videoExtensions`, `documentExtensions`, `otherExtensions`
  - Helper functions:
    - `mediaTypeForExtension()` - get MediaType from file extension
    - `isExtensionOfType()` - check if extension matches a MediaType
  - Runtime classification of all extensions from the `mime` package's default extension map
- Cross-platform support:
  - Platform-specific utilities for web and native (IO)
  - Conditional imports for Flutter web compatibility
- File extensions on `XFile`:
  - `delete()` - delete file with existence check
  - `size()` - get file size
  - `exists()` - check file existence
  - `mediaType` - get MediaType from file
  - `name` - get file name from path
- Comprehensive test suite:
  - `MediaType` tests for classification and type detection
  - `MemoryMediaSource` tests
  - `NetworkMediaSource` tests with URL validation
  - Test fixtures and sample files

### Features
- 🎯 Type-safe media source abstraction
- 📁 Support for file, memory, and network media sources
- 🔍 Automatic media type detection from paths, MIME types, and bytes
- ⏱️ Duration metadata extraction for audio/video files
- 🌐 Cross-platform support (Flutter mobile, web, desktop)
- 📊 Comprehensive MIME type to media type mapping
- 🧩 Extension-based media type lookup utilities
- 🧪 Test coverage for core functionality
- 🔗 Built on `cross_file` for cross-platform file handling
- ⚡ Lightweight with minimal dependencies

[0.1.0-alpha.1]: https://github.com/hossameldinmi/media_source/releases/tag/v0.1.0

