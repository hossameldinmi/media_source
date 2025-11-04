import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'platform_utils/platform_utils_io.dart' if (dart.library.html) 'platform_utils_web.dart';

class PlatformUtils {
  static final _instance = PlatformUtilsFacadeImpl();
  static PlatformUtilsFacade get instance => _instance;
}

abstract class PlatformUtilsFacade {
  Future<bool> deleteFile(XFile file);
  Future<void> createDirectoryIfNotExists(String directoryPath);
  @visibleForTesting
  Future<bool> directoryExists(String directoryPath);
  @visibleForTesting
  Future<bool> deleteDirectory(String directoryPath);

  Future<bool> fileExists(XFile xFile);
}
