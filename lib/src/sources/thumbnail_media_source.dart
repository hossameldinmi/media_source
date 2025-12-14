import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/media_source.dart';

/// A [MediaSource] that wraps an [original] source and an optional [thumbnail] source.
///
/// This source mimics the [original] source's metadata, mimeType, name, and size,
/// but also holds a reference to a [thumbnail] which can be used for preview purposes.
///
/// [M] is the type of the original media file (e.g., [VideoType], [ImageType]).
/// [T] is the type of the thumbnail media file (e.g., [ImageType]).
class ThumbnailMediaSource<M extends FileType, T extends FileType> extends MediaSource<M> {
  /// The original full-quality media source.
  final MediaSource<M> original;

  /// An optional thumbnail source for the original media.
  final MediaSource<T>? thumbnail;

  /// Creates a [ThumbnailMediaSource].
  ///
  /// [original] is required and provides the main content and metadata.
  /// [thumbnail] is optional and provides a preview image.
  ThumbnailMediaSource({
    required this.original,
    this.thumbnail,
  }) : super(
          metadata: original.metadata,
          mimeType: original.mimeType,
          name: original.name,
          size: original.size,
        );

  /// Returns `true` if a [thumbnail] source is available.
  bool get hasThumbnail => thumbnail != null;
}
