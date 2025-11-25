import 'package:equatable/equatable.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/sources/asset_media_source.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/sources/network_media_source.dart';
import 'package:file_sized/file_sized.dart';
import 'package:path/path.dart' as p;

/// Abstract base class for all media sources.
///
/// This class defines the common interface for different media source types
/// (file, memory, network). It provides:
/// - Common properties (name, size, MIME type, media type metadata)
/// - Extension extraction from file names
/// - Pattern matching via [fold] for type-safe handling
/// - Type checking with [isAnyType]
///
/// Extensibility: You can create your own source types by extending
/// `MediaSource<M>` and, when appropriate, implementing the conversion
/// mixins [`ToMemoryConvertableMedia`], [`ToFileConvertableMedia`]. This
/// allows you to model custom storage backends while still participating
/// in the shared fold pattern.
///
/// Generic parameter [M] represents the specific media type metadata
/// (e.g., [VideoType], [AudioType], etc.)
abstract class MediaSource<M extends FileType> extends Equatable {
  /// The MIME type of the media, if available.
  final String? mimeType;

  /// The name or identifier of the media.
  final String name;

  /// The size of the media, if known.
  final FileSize? size;

  /// Metadata about the media type (e.g., VideoType, AudioType).
  final M metadata;

  /// Extracts the file extension from the name.
  ///
  /// Returns the substring after the last dot, or the entire name if no dot exists.
  String get extension => p.extension(name);

  /// Creates a [MediaSource] with the specified properties.
  const MediaSource({
    required this.metadata,
    required this.mimeType,
    required String? name,
    required this.size,
  }) : name = name ?? '';

  @override
  List<Object?> get props => [name, mimeType, size, metadata];

  /// Checks if this media source's runtime type is in the given list.
  ///
  /// Useful for runtime type checking against multiple types.
  bool isAnyType(List<Type> list) => list.contains(runtimeType);

  /// Performs pattern matching on media sources using a fold-like pattern.
  ///
  /// This method allows type-safe handling of different media source types:
  /// - [file]: Called if this is a [FileMediaSource]
  /// - [memory]: Called if this is a [MemoryMediaSource]
  /// - [network]: Called if this is a [NetworkMediaSource]
  /// - [asset]: Called if this is an [AssetMediaSource]
  /// - [orElse]: Called if no matching callback is provided
  ///
  /// Returns: The result of the matching callback or [orElse]
  T fold<T>(
      {T Function(FileMediaSource<M> fileMedia)? file,
      T Function(MemoryMediaSource<M> memoryMedia)? memory,
      T Function(NetworkMediaSource<M> networkMedia)? network,
      T Function(AssetMediaSource<M> assetMedia)? asset,
      required T Function() orElse}) {
    if (this is FileMediaSource<M> && file != null) {
      return file(this as FileMediaSource<M>);
    } else if (this is MemoryMediaSource<M> && memory != null) {
      return memory(this as MemoryMediaSource<M>);
    } else if (this is NetworkMediaSource<M> && network != null) {
      return network(this as NetworkMediaSource<M>);
    } else if (this is AssetMediaSource<M> && asset != null) {
      return asset(this as AssetMediaSource<M>);
    }
    return orElse();
  }
}

/// Mixin for media sources that can be converted to [MemoryMediaSource].
///
/// Implement this mixin on media sources that support converting their content
/// to an in-memory byte representation.
abstract class ToMemoryConvertableMedia<M extends FileType> {
  /// Converts this media source to a [MemoryMediaSource].
  ///
  /// This is useful for caching, processing, or uploading media data.
  /// Returns a new [MemoryMediaSource] containing the same media data.
  Future<MemoryMediaSource<M>> convertToMemory();
}

/// Mixin for media sources that can be saved as files.
///
/// Implement this mixin on media sources that support saving their content
/// to the file system.
abstract class ToFileConvertableMedia<M extends FileType> {
  /// Saves this media to a file at the specified path.
  ///
  /// Returns a new [FileMediaSource] pointing to the saved file.
  Future<FileMediaSource<M>> saveTo(String path);
}
