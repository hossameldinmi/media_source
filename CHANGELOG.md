# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-07-16

### Fixed
- `XFile.getMediaType` now honors the provided MIME type override; previously the parameter was
  silently ignored, so explicit `mimeType` arguments to `FileMediaSource.fromFile`/`fromPath` did
  not affect media type detection
- `AssetMediaSource.loadAsset` now slices the `ByteData` with its offset and length, preventing
  corrupt data when the platform returns a view into a larger shared buffer
- `NetworkMediaSource.fromUrl` detects the media type from the parsed URI path, so query strings
  and fragments (e.g. `?token=a.b`) can no longer be mistaken for a file extension
- `Uri.fileName` (and therefore default network media names) is now percent-decoded and handles
  trailing slashes and extension-less URLs
- `MemoryMediaSource` equality no longer hashes the full byte content on every `hashCode`/`==`
  call; content is compared only after the cheap fields match
- Fixed misleading documentation of `MediaSource.extension` (returns the extension with its
  leading dot, or an empty string)
- Removed meaningless `@override` annotations from constructors

### Changed
- **BREAKING**: `FileMediaSource` and `MemoryMediaSource` gained abstract template hooks
  (`copyWithFile`, `createMemoryMedia`, `createFileMedia`). External subclasses must implement
  them; existing `saveTo` overrides keep working unchanged
- **BREAKING**: minimum SDK is now Dart 3.4 (the `web` dependency already required it)
- **BREAKING**: `PlatformUtilsFacade.createDirectoryIfNotExists` is deprecated in favor of
  `ensureParentDirectoryExists`, which describes the actual behavior (the method always created
  the *parent* directory of the given path). Custom facade implementations must implement the
  new methods (`ensureParentDirectoryExists`, `moveFile`)
- **BREAKING**: `UrlMedia` no longer reports a fake `0 B` size or the invalid `'url'` MIME type;
  size is now null and the MIME type is detected from the URL path when possible
- **BREAKING**: `FileMediaSource.moveTo` now throws a `StateError` on native platforms when the
  fallback copy succeeds but the original file cannot be deleted
- **BREAKING**: `saveTo` on the concrete source classes now returns the base
  `Future<FileMediaSource<M>>` instead of the concrete subtype (e.g. `Future<VideoFileMedia>`).
  The runtime object is unchanged; only explicitly-typed assignments need updating. The typed
  metadata survives via the generic (`FileMediaSource<VideoType>.metadata.duration` still works)
- `FileMediaSource.moveTo` uses a fast platform rename when possible instead of copy + delete
- `NetworkMediaSource.fromUrlOrNull` now forwards `name`, `size`, `mimeType`, `duration`, and
  `mediaType` to `fromUrl`, and only swallows `FormatException`
- Save/move/convert logic is now implemented once in the base classes
  (`FileMediaSource`, `MemoryMediaSource`, `AssetMediaSource`) via template hooks, removing
  drift between the per-type implementations

### Deprecated
- `MediaSource.isAnyType`: exact `runtimeType` comparison silently fails for base types; use
  `is` checks or `fold` instead

### Added
- Public synchronous constructors for all asset media types (`VideoAssetMedia`,
  `AudioAssetMedia`, `ImageAssetMedia`, `DocumentAssetMedia`, `OtherTypeAssetMedia`).
  The constructor trusts the provided `size` (or leaves it null); use `load()` when the size
  should be read from the asset bundle. Previously only `ImageAssetMedia` exposed a public
  constructor, and it required all parameters
- `PlatformUtilsFacade.moveFile` for fast native file renames
- Lint enforcement via `flutter_lints` (previously no lint ruleset was included)

### Dependencies
- `file_type_plus` `^1.0.0` → `^1.1.0`: picks up detection fixes (extension
  preferred over MIME type, `fromPath` returns `FileType.other` instead of
  throwing on unparseable input, query/fragment-safe local names)

## [1.3.2] - 2026-04-28

### Changed
- Changed code coverage badge URL in README.md

## [1.3.1] - 2026-04-28

### Changed
- Changed organization name to balsm-io in pubspec.yaml and README.md

### Removed
- Removed redundant arguments from test functions

## [1.3.0] - 2025-12-14

### Fixed
- Fixed web platform build errors
- Improved web compatibility for cross-platform file operations

### Changed
- Enhanced web platform support for better reliability

## [1.2.0] - 2025-12-14
 
### Added
- **ThumbnailMediaSource** - A wrapper source that pairs high-quality media with a lightweight thumbnail
  - Supports separate types for original and thumbnail generic types (e.g. `ThumbnailMediaSource<VideoType, ImageType>`)
  - Automatically delegates metadata (name, size, mimeType) to the original source
  - Documentation and examples included

## [1.1.0] - 2025-11-26

### Changed
- **Breaking Change**: Renamed dependency `sized_file` to `file_sized`
- **Breaking Change**: Renamed `SizedFile` class to `FileSize`

## [1.0.0] - 2025-11-06

### Added
- **AssetMediaSource** - New media source for Flutter asset bundles
  - `AssetMediaSource<M>` base class for asset-based media
  - `VideoAssetMedia` - Load video assets with duration metadata
  - `AudioAssetMedia` - Load audio assets with duration metadata
  - `ImageAssetMedia` - Load image assets
  - `DocumentAssetMedia` - Load PDF document assets
  - `OtherTypeAssetMedia` - Load other file type assets
  - All asset media types support:
    - `.load()` factory method with optional `AssetBundle` parameter
    - `assetPath` property for asset location
    - `convertToMemory()` for converting to memory-based media
    - `saveTo()` for saving assets to file system
    - Pattern matching with `fold()` including new `asset` callback
    - Lazy loading with optional size parameter to optimize performance
- Interactive Flutter example app (`example/asset_media_example.dart`)
  - Complete MaterialApp demonstrating all asset media features
  - 7 interactive examples: video, audio, image, document, conversions, metadata preservation, and pattern matching
  - UI with buttons to run each example scenario
  - Detailed usage comments and pubspec.yaml asset configuration guide
- Console examples for asset media in `example/main.dart`
  - Example 4: Asset Media Sources with load, convert, and save demonstrations
  - Shows optimized loading with size hints
  - Demonstrates conversion chains (asset → memory → file)
- Comprehensive test coverage for AssetMediaSource
  - 52 tests with 100% coverage for asset media functionality
  - `TestFileAssetBundle` for testing asset loading
  - Tests for all asset media types and operations
  - Fixture-based test data with real asset files

### Changed
- Updated `MediaSource.fold()` to include `asset` callback parameter
  - Added `asset` parameter to support asset media pattern matching
  - Maintains backward compatibility with `orElse` fallback
- Enhanced README.md with comprehensive asset media documentation
  - Added "Working with Asset Media Source" section with code examples
  - Updated features list to include asset media support
  - Updated motivation section to mention bundled assets
  - Added asset media feature highlights (6 key features)
  - Updated all `fold()` examples to include `asset` parameter
  - Added AssetMediaSource to API Reference section
  - Included link to interactive Flutter example
- Updated package description to include "asset" sources
- Improved extensibility documentation for custom media sources
- Updated all code examples and documentation to include `asset` parameter in `fold()` calls
  - Main library documentation (`lib/media_source.dart`)
  - README examples (Complete Example, Pattern Matching sections)
  - Console examples (`example/main.dart`)
  - Asset media example with pattern matching demonstration

### Documentation
- Comprehensive dartdoc comments for all AssetMediaSource classes
- Usage examples in class-level documentation
- Parameter descriptions for all factory methods
- Examples showing load(), saveTo(), and convertToMemory() patterns
- Cross-references between related asset media types

## [0.2.0-alpha.6]

### Added
- Custom media factory pattern documentation and examples
  - Added `MediaFactory` class example for centralized media creation
  - Added `SmartMediaFactory` class with size-based optimization logic
  - New Example 7 in `example/main.dart` demonstrating factory patterns
  - Factory implementations showing auto-detection from paths and URLs
  - Business logic examples (memory vs. file based on size thresholds)
- Enhanced extensibility documentation
  - Added custom media factory section in README.md with code examples
  - Updated library documentation to mention three extensibility approaches
  - Highlighted benefits: centralization, business rules, testing, optimization

### Changed
- Updated README.md with custom media factory examples
  - Added `MediaSourceType` enum example
  - Added basic and smart factory implementation examples
  - Included practical benefits list for factory pattern
- Enhanced library-level documentation in `media_source.dart`
  - Added factory pattern as third extensibility option
  - Included factory code example in main library docs
- Improved README formatting with more **bold highlights** for important terms

### Fixed
- Added `homepage` field to `pubspec.yaml` for better pub.dev compatibility

## [0.2.0-alpha.5]

### Fixed
- GitHub Actions CI workflow now properly checks out repository code
  - CI pipeline now successfully runs analysis, tests, and coverage reporting
  - Set Flutter version to 3.24.0 for better compatibility
  - Simplified CI dependencies installation step by removing debug commands

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

[1.3.2]: https://github.com/balsm-io/media_source/releases/tag/v1.3.2
[1.3.1]: https://github.com/balsm-io/media_source/releases/tag/v1.3.1
[1.3.0]: https://github.com/balsm-io/media_source/releases/tag/v1.3.0
[1.2.0]: https://github.com/balsm-io/media_source/releases/tag/v1.2.0
[1.1.0]: https://github.com/balsm-io/media_source/releases/tag/v1.1.0
[1.0.0]: https://github.com/balsm-io/media_source/releases/tag/v1.0.0

