import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:sized_file/sized_file.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/utils/file_util.dart' as file_util;

abstract class NetworkMediaSource<M extends FileType> extends MediaSource<M> {
  final Uri uri;
  NetworkMediaSource._({
    required this.uri,
    String? name,
    required super.size,
    String? mimeType,
    required super.metadata,
  }) : super(
          mimeType: mimeType ?? FileUtil.getMimeTypeFromPath(uri.path),
          name: name ?? file_util.FileUtil.getFileNameFromPath(uri.path),
        );

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

  @override
  List<Object?> get props => [uri, ...super.props];
}

class VideoNetworkMedia extends NetworkMediaSource<VideoType> {
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

class AudioNetworkMedia extends NetworkMediaSource<AudioType> {
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

class ImageNetworkMedia extends NetworkMediaSource<ImageType> {
  ImageNetworkMedia(
    Uri uri, {
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: uri,
          metadata: ImageType(),
        );

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

class DocumentNetworkMedia extends NetworkMediaSource<DocumentType> {
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

class UnSupportedNetworkMedia extends NetworkMediaSource<OtherType> {
  @override
  UnSupportedNetworkMedia(Uri uri, {super.mimeType, super.name, super.size})
      : super._(
          uri: uri,
          metadata: OtherType(),
        );
}

class UrlMedia extends NetworkMediaSource<UrlType> {
  UrlMedia(Uri uri)
      : super._(
          size: 0.b,
          mimeType: 'url',
          metadata: UrlType(),
          uri: uri,
        );
  UrlMedia.url(String url) : this(Uri.parse(url));

  @override
  List<Object?> get props => [uri, metadata];
}
