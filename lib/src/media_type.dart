import 'package:file_type_plus/file_type_plus.dart';

extension MediaTypeExtension on FileType {
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

class VideoType extends FileType implements DurationMedia {
  @override
  final Duration? duration;

  @override
  VideoType([this.duration]) : super.copy(FileType.video);

  @override
  List<Object?> get props => [duration];
}

class AudioType extends FileType implements DurationMedia {
  @override
  final Duration? duration;
  @override
  List<Object?> get props => [duration];
  AudioType([this.duration]) : super.copy(FileType.audio);
}

class ImageType extends FileType {
  ImageType() : super.copy(FileType.image);

  @override
  List<Object?> get props => [];
}

class DocumentType extends FileType {
  DocumentType() : super.copy(FileType.document);
  @override
  List<Object?> get props => [];
}

class UrlType extends FileType {
  UrlType() : super.copy(FileType.html);
  @override
  List<Object?> get props => [];
}

class OtherType extends FileType {
  OtherType() : super.copy(FileType.other);

  @override
  List<Object?> get props => [];
}

abstract class DurationMedia {
  final Duration? duration;
  DurationMedia({required this.duration});
}
