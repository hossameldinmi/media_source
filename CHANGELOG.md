# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0-alpha.4]

### Fixed
- WASM compatibility issue by updating conditional import from `dart.library.html` to `dart.library.js_interop`
  - Package is now fully compatible with WASM runtime
  - Maintains backward compatibility with web and native platforms
  - Resolves pub.dev scoring penalty for WASM incompatibility

## [0.2.0-alpha.3] - 2025-11-05

### Added
- Comprehensive inline documentation for all public APIs
  - Class-level documentation for all media types and sources
  - Method and constructor documentation with parameter descriptions
  - Property documentation explaining purpose and usage
  - Usage examples in doc comments
- Extensibility documentation
  - Guide for creating custom media types by extending `FileTypeImpl`
  - Guide for creating custom media sources by extending `MediaSource<M>`
  - Example implementations in library docs and README
- Complete example file (`example/main.dart`) demonstrating:
  - Working with file, memory, and network media sources
  - Type-safe pattern matching with fold
  - Converting between different source types
  - Creating custom media types and sources
- Platform utilities documentation
  - Documented `PlatformUtils` facade pattern
  - IO and web implementation documentation
  - Cross-platform file operation guides
- Extension methods documentation
  - `FileExtensions` on `XFile` with usage examples
  - `UriExtensions` for file name extraction
  - `ObjectExtension` for safe type casting

### Changed
- Enhanced library-level documentation in `media_source.dart`
  - Added comprehensive feature list
  - Added usage examples for all source types
  - Added pattern matching examples
  - Included extensibility section with custom type example
- Improved README.md
  - Added motivation section inspired by Flutter's `ImageProvider`
  - Added extensibility section with practical examples
  - Added quick start link to example file
  - Better organization of features and usage patterns

### Documentation
- All public classes now have comprehensive doc comments
- All public methods include parameter and return value documentation
- IDE tooltips and generated docs are now complete
- Code comments explain design patterns (fold, facade, etc.)

### Fixed
- WASM compatibility issue by updating conditional import from `dart.library.html` to `dart.library.js_interop`
  - Package is now compatible with WASM runtime
  - Maintains backward compatibility with web and native platforms

## [0.2.0-alpha.2]

### Added
- Comprehensive test coverage achieving 99.7% coverage
- Tests for `UrlMedia` class with both `Uri` and `.url()` constructors
- Tests for `.url()` constructors in all network media types
- Test for `FileMediaSource` fold method callback
- Test for `DocumentType` fold method callback
- Test for `UrlType` fold method callback
- Test for `stringify` property in `MemoryMediaSource`
- Test for `props` property in `FileMediaSource`
- Test for `moveTo()` when target file already exists
- Extended documentation in main library file with usage examples

### Changed
- Refactored `DurationMedia` from abstract class with constructor to interface-only (getter pattern)
- Simplified `VideoFileMedia.fromFile()` to use inline null-coalescing instead of try-catch
- Improved `FileMediaSource.fromPath()` to explicitly handle size parameter conversion
- Removed unused `dart:developer` import from `file_media_source.dart`

### Fixed
- All test assertions now use direct comparison instead of deprecated `equals()` matcher
- Error handling in file operations now more consistent across media types

### Testing
- Added 13 new test cases across multiple test files
- Total test count: 157 tests (155 passing, 2 skipped)
- Test coverage improved from ~91% to 99.7%
- Comprehensive coverage of all media source types and operations

## [0.1.0-alpha.1] - 2025-11-03

### Added
- Initial release of the `media_source` package
- Core `MediaSource` abstraction for handling different media sources
- `FileMediaSource` implementation for local file system access
  - Support for file operations (delete, exists, size)
  - Automatic MIME type detection
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
- 🌐 Cross-platform support (Flutter mobile, web, desktop)
- 📊 Comprehensive MIME type to media type mapping
- 🧩 Extension-based media type lookup utilities
- 🧪 Test coverage for core functionality
- 🔗 Built on `cross_file` for cross-platform file handling
- ⚡ Lightweight with minimal dependencies

[0.1.0-alpha.1]: https://github.com/hossameldinmi/media_source/releases/tag/v0.1.0

