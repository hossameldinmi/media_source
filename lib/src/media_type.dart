import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:media_source/src/utils/file_util.dart';

class MediaType extends Equatable {
  final String _value;
  const MediaType._(this._value);
  MediaType._fromEnum(MediaType value) : this._(value._value);
  bool isAny(List<MediaType> list) => list.map((e) => e._value).contains(_value);
  bool isAnyType(List<Type> list) => list.contains(runtimeType);
  static const image = MediaType._('image');
  static const audio = MediaType._('audio');
  static const video = MediaType._('video');
  static const document = MediaType._('doc');
  static const url = MediaType._('url');
  static const other = MediaType._('other');

  factory MediaType.fromPath(String path, String? mimeType) {
    final uri = Uri.parse(path);
    if (uri.path.contains('ism')) return MediaType.video;
    if (mimeType != null) return _getMediaType(mimeType);
    mimeType = FileUtil.getMimeTypeFromPath(uri.path);
    return _getMediaType(mimeType!);
  }

  factory MediaType.fromBytes(Uint8List bytes, String? mimeType) {
    if (mimeType != null) return _getMediaType(mimeType);
    mimeType = FileUtil.getMimeTypeFromBytes(bytes);
    return _getMediaType(mimeType!);
  }

  static MediaType _getMediaType(String mime) {
    late MediaType mediaType;
    if (mime.contains('image')) {
      mediaType = MediaType.image;
    } else if (mime.contains('audio')) {
      mediaType = MediaType.audio;
    } else if (mime.contains('video') || mime.contains('mpegurl')) {
      // mpegurl is for m3u8
      mediaType = MediaType.video;
    } else if (mime.contains('application/pdf')) {
      mediaType = MediaType.document;
    } else {
      mediaType = MediaType.other;
    }
    return mediaType;
  }

  T when<T>({
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

  @override
  List<Object?> get props => [_value];
}

class VideoType extends MediaType implements DurationMedia {
  @override
  final Duration? duration;

  @override
  VideoType([this.duration]) : super._fromEnum(MediaType.video);

  @override
  List<Object?> get props => [duration];
}

class AudioType extends MediaType implements DurationMedia {
  @override
  final Duration? duration;
  @override
  List<Object?> get props => [duration];
  AudioType([this.duration]) : super._fromEnum(MediaType.audio);
}

class ImageType extends MediaType {
  ImageType() : super._fromEnum(MediaType.image);

  @override
  List<Object?> get props => [];
}

class DocumentType extends MediaType {
  DocumentType() : super._fromEnum(MediaType.document);
  @override
  List<Object?> get props => [];
}

class UrlType extends MediaType {
  UrlType() : super._fromEnum(MediaType.url);
  @override
  List<Object?> get props => [];
}

class OtherType extends MediaType {
  OtherType() : super._fromEnum(MediaType.other);

  @override
  List<Object?> get props => [];
}

abstract class DurationMedia {
  final Duration? duration;
  DurationMedia({required this.duration});
}
