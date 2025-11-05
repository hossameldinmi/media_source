import 'package:file_type_plus/file_type_plus.dart';

/// Extension on [FileTypeImpl] providing pattern matching functionality.
///
/// This extension enables type-safe pattern matching over different media types
/// using a fold-like pattern, allowing you to handle each media type specifically.
extension MediaTypeExtension on FileTypeImpl {
  /// Performs pattern matching on media types using a fold-like pattern.
  ///
  /// This method allows you to handle different media types with type-specific
  /// callbacks. Each media type has an optional callback that will be executed
  /// if the current instance is of that type.
  ///
  /// Parameters:
  /// - [image]: Called if this is an [ImageType]
  /// - [audio]: Called if this is an [AudioType]
  /// - [video]: Called if this is an [VideoType]
  /// - [document]: Called if this is a [DocumentType]
  /// - [url]: Called if this is a [UrlType]
  /// - [orElse]: Called if no matching callback is provided
  ///
  /// Returns: The result of the matching callback or [orElse]
  T fold<T>({
    required T Function() orElse,
    T Function(ImageType image)? image,
    T Function(AudioType audio)? audio,
    T Function(VideoType video)? video,
    T Function(DocumentType doc)? document,
    T Function(UrlType url)? url,
  }) {
    if (this is ImageType && image != null) {
      return image(this as ImageType);
    } else if (this is AudioType && audio != null) {
      return audio(this as AudioType);
    } else if (this is VideoType && video != null) {
      return video(this as VideoType);
    } else if (this is DocumentType && document != null) {
      return document(this as DocumentType);
    } else if (this is UrlType && url != null) {
      return url(this as UrlType);
    }
    return orElse();
  }
}

abstract class FileTypeImpl extends FileType {
  FileTypeImpl.copy(super.value) : super.copy();
}

/// Media type for video files.
///
/// Extends [FileTypeImpl] to provide video-specific classification.
/// Optionally stores duration information if available.
class VideoType extends FileTypeImpl implements DurationMedia {
  /// The duration of the video, if available.
  @override
  final Duration? duration;

  /// Creates a [VideoType] with an optional duration.
  @override
  VideoType([this.duration]) : super.copy(FileType.video);

  @override
  List<Object?> get props => [duration];
}

/// Media type for audio files.
///
/// Extends [FileTypeImpl] to provide audio-specific classification.
/// Optionally stores duration information if available.
class AudioType extends FileTypeImpl implements DurationMedia {
  /// The duration of the audio, if available.
  @override
  final Duration? duration;
  @override
  List<Object?> get props => [duration];

  /// Creates an [AudioType] with an optional duration.
  AudioType([this.duration]) : super.copy(FileType.audio);
}

/// Media type for image files.
///
/// Extends [FileTypeImpl] to provide image-specific classification.
class ImageType extends FileTypeImpl {
  /// Creates an [ImageType].
  ImageType() : super.copy(FileType.image);

  @override
  List<Object?> get props => [];
}

/// Media type for document files (primarily PDF).
///
/// Extends [FileTypeImpl] to provide document-specific classification.
class DocumentType extends FileTypeImpl {
  /// Creates a [DocumentType].
  DocumentType() : super.copy(FileType.document);
  @override
  List<Object?> get props => [];
}

/// Media type for URL references.
///
/// Extends [FileTypeImpl] to provide URL reference classification.
class UrlType extends FileTypeImpl {
  /// Creates a [UrlType].
  UrlType() : super.copy(FileType.html);
  @override
  List<Object?> get props => [];
}

/// Media type for other/unclassified file types.
///
/// Extends [FileTypeImpl] to provide a fallback classification for files
/// that don't match any other specific media type.
class OtherType extends FileTypeImpl {
  /// Creates an [OtherType].
  OtherType() : super.copy(FileType.other);

  @override
  List<Object?> get props => [];
}

/// Interface for media types that have duration information.
///
/// This interface is implemented by media types that can have duration metadata,
/// such as audio and video files.
abstract class DurationMedia {
  /// The duration of the media, if available.
  Duration? get duration;
}
