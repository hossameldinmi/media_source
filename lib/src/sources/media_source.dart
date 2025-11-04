import 'package:equatable/equatable.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:media_source/src/sources/file_media_source.dart';
import 'package:media_source/src/sources/memory_media_source.dart';
import 'package:media_source/src/sources/network_media_source.dart';
import 'package:sized_file/sized_file.dart';

abstract class MediaSource<M extends FileType> extends Equatable {
  final String? mimeType;
  final String name;
  final SizedFile? size;
  final M metadata;

  String get extension => name.split('.').last;

  const MediaSource({
    required this.metadata,
    required this.mimeType,
    required String? name,
    required this.size,
  }) : name = name ?? '';

  @override
  List<Object?> get props => [name, mimeType, size, metadata];

  bool isAnyType(List<Type> list) => list.contains(runtimeType);

  T fold<T>(
      {T Function(FileMediaSource<M> fileMedia)? file,
      T Function(MemoryMediaSource<M> memoryMedia)? memory,
      T Function(NetworkMediaSource<M> networkMedia)? network,
      required T Function() orElse}) {
    if (this is FileMediaSource<M> && file != null) {
      return file(this as FileMediaSource<M>);
    } else if (this is MemoryMediaSource<M> && memory != null) {
      return memory(this as MemoryMediaSource<M>);
    } else if (this is NetworkMediaSource<M> && network != null) {
      return network(this as NetworkMediaSource<M>);
    }
    return orElse();
  }
}

abstract class ToMemoryConvertableMedia<M extends FileType> {
  Future<MemoryMediaSource<M>> convertToMemory();
}

abstract class ToFileConvertableMedia<M extends FileType> {
  Future<FileMediaSource<M>> saveToFile(String path);
}
