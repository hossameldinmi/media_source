import 'package:media_source/src/extensions/uri_extensions.dart';
import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:sized_file/sized_file.dart';
import 'package:file_type_plus/file_type_plus.dart';

/// Abstract base class for network-based media sources.
///
/// Represents media accessible via HTTP/HTTPS URLs. Unlike file or memory sources,
/// network media sources do not require loading the full content into memory or
/// file system. They store only the URL and metadata.
///
/// Useful for:
/// - Streaming media over the network
/// - Playing remote media without downloading
/// - Representing cloud-hosted media
///
/// Subclasses include:
/// - [VideoNetworkMedia] for video URLs
/// - [AudioNetworkMedia] for audio URLs
/// - [ImageNetworkMedia] for image URLs
/// - [DocumentNetworkMedia] for document URLs
/// - [UnSupportedNetworkMedia] for unclassified URLs
/// - [UrlMedia] for generic URLs
abstract class NetworkMediaSource<M extends FileType> extends MediaSource<M> {
  /// The network URI pointing to the media.
  final Uri uri;

  /// Internal constructor for creating network media sources.
  ///
  /// Parameters:
  /// - [uri]: The network URI of the media
  /// - [name]: Optional custom display name, defaults to filename from URI
  /// - [size]: Optional media size
  /// - [mimeType]: Optional MIME type, auto-detected from URI path if not provided
  /// - [metadata]: Type-specific metadata (VideoType, AudioType, etc.)
  NetworkMediaSource._({
    required this.uri,
    String? name,
    required super.size,
    String? mimeType,
    required super.metadata,
  }) : super(
          mimeType: mimeType ?? FileUtil.getMimeTypeFromPath(uri.path),
          name: name ?? uri.fileName,
        );

  /// Creates a [NetworkMediaSource] from a URL string.
  ///
  /// Automatically detects the media type and returns the appropriate subclass.
  /// If media type is not provided, it will be determined from the URL path.
  ///
  /// Parameters:
  /// - [url]: The URL string to the media
  /// - [name]: Optional custom display name
  /// - [size]: Optional media size
  /// - [mimeType]: Optional MIME type override
  /// - [duration]: Optional duration for audio/video media
  /// - [mediaType]: Optional explicit media type
  ///
  /// Returns the appropriate [NetworkMediaSource] subclass based on media type.
  /// Throws an exception if the URL is invalid.
  static NetworkMediaSource fromUrl(
    String url, {
    String? name,
    SizedFile? size,
    String? mimeType,
    Duration? duration,
    FileType? mediaType,
  }) {
    mediaType ??= FileType.fromPath(url, mimeType);
    final uri = Uri.parse(url);
    if (mediaType.isAny([FileType.audio])) {
      return AudioNetworkMedia(
        uri,
        name: name,
        size: size,
        mimeType: mimeType,
        duration: duration,
      );
    }
    if (mediaType.isAny([FileType.video])) {
      return VideoNetworkMedia(
        uri,
        name: name,
        size: size,
        mimeType: mimeType,
        duration: duration,
      );
    }
    if (mediaType.isAny([FileType.image])) {
      return ImageNetworkMedia(
        uri,
        name: name,
        size: size,
        mimeType: mimeType,
      );
    }
    if (mediaType.isAny([FileType.document])) {
      return DocumentNetworkMedia(
        uri,
        name: name,
        size: size,
        mimeType: mimeType,
      );
    }
    return UnSupportedNetworkMedia(
      uri,
      name: name,
      size: size,
      mimeType: mimeType,
    );
  }

  /// Safely creates a [NetworkMediaSource] from a URL string or returns null.
  ///
  /// Similar to [fromUrl] but returns null instead of throwing an exception
  /// if the URL is invalid or null.
  ///
  /// Parameters:
  /// - [url]: The URL string to the media, or null
  ///
  /// Returns a [NetworkMediaSource] or null if the URL is invalid or empty.
  static NetworkMediaSource? fromUrlOrNull(String? url) {
    if (url != null && url.isNotEmpty) {
      try {
        return NetworkMediaSource.fromUrl(url);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Includes the URI in equality comparisons.
  @override
  List<Object?> get props => [uri, ...super.props];
}

/// Represents video URLs (streaming media).
///
/// Stores video metadata including optional duration information.
/// Supports both Uri and String constructors.
class VideoNetworkMedia extends NetworkMediaSource<VideoType> {
  /// Creates a [VideoNetworkMedia] from a Uri object.
  ///
  /// Parameters:
  /// - [uri]: The video URL as a Uri
  /// - [duration]: Optional video duration
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional video size
  VideoNetworkMedia(
    Uri uri, {
    Duration? duration,
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: uri,
          metadata: VideoType(duration),
        );

  /// Creates a [VideoNetworkMedia] from a URL string.
  ///
  /// Convenience constructor that parses a string URL.
  ///
  /// Parameters:
  /// - [url]: The video URL as a string
  /// - [duration]: Optional video duration
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional video size
  VideoNetworkMedia.url(
    String url, {
    Duration? duration,
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: Uri.parse(url),
          metadata: VideoType(duration),
        );

  @override
  List<Object?> get props => [uri, mimeType, metadata, name, size];
}

/// Represents audio URLs (streaming media).
///
/// Stores audio metadata including optional duration information.
/// Supports both Uri and String constructors.
class AudioNetworkMedia extends NetworkMediaSource<AudioType> {
  /// Creates an [AudioNetworkMedia] from a Uri object.
  ///
  /// Parameters:
  /// - [uri]: The audio URL as a Uri
  /// - [duration]: Optional audio duration
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional audio size
  AudioNetworkMedia(
    Uri uri, {
    Duration? duration,
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: uri,
          metadata: AudioType(duration),
        );

  /// Creates an [AudioNetworkMedia] from a URL string.
  ///
  /// Convenience constructor that parses a string URL.
  ///
  /// Parameters:
  /// - [url]: The audio URL as a string
  /// - [duration]: Optional audio duration
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional audio size
  AudioNetworkMedia.url(
    String url, {
    Duration? duration,
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: Uri.parse(url),
          metadata: AudioType(duration),
        );
}

/// Represents image URLs.
///
/// Supports both Uri and String constructors for flexible instantiation.
class ImageNetworkMedia extends NetworkMediaSource<ImageType> {
  /// Creates an [ImageNetworkMedia] from a Uri object.
  ///
  /// Parameters:
  /// - [uri]: The image URL as a Uri
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional image size
  ImageNetworkMedia(
    Uri uri, {
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: uri,
          metadata: ImageType(),
        );

  /// Creates an [ImageNetworkMedia] from a URL string.
  ///
  /// Convenience constructor that parses a string URL.
  ///
  /// Parameters:
  /// - [url]: The image URL as a string
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional image size
  ImageNetworkMedia.url(
    String url, {
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: Uri.parse(url),
          metadata: ImageType(),
        );
}

/// Represents document URLs.
///
/// Supports documents like PDF, DOC, XLSX, etc. accessible via URL.
/// Supports both Uri and String constructors.
class DocumentNetworkMedia extends NetworkMediaSource<DocumentType> {
  /// Creates a [DocumentNetworkMedia] from a Uri object.
  ///
  /// Parameters:
  /// - [uri]: The document URL as a Uri
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional document size
  @override
  DocumentNetworkMedia(
    Uri uri, {
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: uri,
          metadata: DocumentType(),
        );

  /// Creates a [DocumentNetworkMedia] from a URL string.
  ///
  /// Convenience constructor that parses a string URL.
  ///
  /// Parameters:
  /// - [url]: The document URL as a string
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional document size
  DocumentNetworkMedia.url(
    String url, {
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: Uri.parse(url),
          metadata: DocumentType(),
        );
}

/// Represents URLs for media types that don't fit standard categories.
///
/// Used for unclassified or unsupported network media types.
class UnSupportedNetworkMedia extends NetworkMediaSource<OtherType> {
  /// Creates an [UnSupportedNetworkMedia] from a Uri object.
  ///
  /// Parameters:
  /// - [uri]: The media URL as a Uri
  /// - [mimeType]: Optional MIME type override
  /// - [name]: Optional custom display name
  /// - [size]: Optional media size
  @override
  UnSupportedNetworkMedia(Uri uri, {super.mimeType, super.name, super.size})
      : super._(
          uri: uri,
          metadata: OtherType(),
        );
}

/// Represents a generic URL, separate from media classification.
///
/// Used for any URL that needs to be stored as metadata without
/// media type classification. Unlike other network media sources,
/// this represents the URL itself as the primary resource.
class UrlMedia extends NetworkMediaSource<UrlType> {
  /// Creates a [UrlMedia] from a Uri object.
  ///
  /// Parameters:
  /// - [uri]: The URL as a Uri object
  UrlMedia(Uri uri)
      : super._(
          size: 0.b,
          mimeType: 'url',
          metadata: UrlType(),
          uri: uri,
        );

  /// Creates a [UrlMedia] from a URL string.
  ///
  /// Convenience constructor that parses a string URL.
  ///
  /// Parameters:
  /// - [url]: The URL as a string
  UrlMedia.url(String url) : this(Uri.parse(url));

  /// Includes only URI and metadata for equality comparisons.
  @override
  List<Object?> get props => [uri, metadata];
}
