import 'package:media_source/src/media_type.dart';
import 'package:media_source/src/sources/media_source.dart';
import 'package:media_source/src/utils/file_util.dart';
import 'package:sized_file/sized_file.dart';

abstract class NetworkMediaSource<M extends MediaType> extends MediaSource<M> {
  final Uri uri;
  NetworkMediaSource._({
    required this.uri,
    String? name,
    required super.size,
    String? mimeType,
    required super.metadata,
  }) : super(
          mimeType: mimeType ?? FileUtil.getMimeTypeFromPath(uri.path),
          name: name ?? FileUtil.getFileNameFromPath(uri.path),
        );

  static NetworkMediaSource fromUrl(
    String url, {
    String? name,
    SizedFile? size,
    String? mimeType,
    Duration? duration,
    MediaSource? thumbnail,
    MediaType? mediaType,
  }) {
    mediaType ??= MediaType.fromPath(url, mimeType);
    final uri = Uri.parse(url);
    if (mediaType.isAny([MediaType.audio])) {
      return AudioNetworkMedia(
        uri,
        name: name,
        size: size,
        mimeType: mimeType,
        duration: duration,
      );
    }
    if (mediaType.isAny([MediaType.video])) {
      return VideoNetworkMedia(
        uri,
        name: name,
        size: size,
        mimeType: mimeType,
        duration: duration,
        thumbnail: thumbnail,
      );
    }
    if (mediaType.isAny([MediaType.image])) {
      return ImageNetworkMedia(
        uri,
        name: name,
        size: size,
        mimeType: mimeType,
        thumbnail: thumbnail,
      );
    }
    if (mediaType.isAny([MediaType.document])) {
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

class VideoNetworkMedia extends NetworkMediaSource<VideoType> implements ThumbnailMedia {
  @override
  final MediaSource? thumbnail;
  @override
  bool get hasThumbnail => ThumbnailMedia.hasThumbnailImp(this);
  VideoNetworkMedia(
    Uri uri, {
    Duration? duration,
    this.thumbnail,
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
    this.thumbnail,
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

class ImageNetworkMedia extends NetworkMediaSource<ImageType> implements ThumbnailMedia {
  @override
  final MediaSource? thumbnail;
  @override
  bool get hasThumbnail => ThumbnailMedia.hasThumbnailImp(this);

  ImageNetworkMedia(
    Uri uri, {
    this.thumbnail,
    super.mimeType,
    super.name,
    super.size,
  }) : super._(
          uri: uri,
          metadata: ImageType(),
        );

  ImageNetworkMedia.url(
    String url, {
    this.thumbnail,
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
