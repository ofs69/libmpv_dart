import 'dart:ffi';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:libmpv_dart/gen/bindings.dart';

class Library {
  static late LibMPV libmpv;
  static bool loaded = false;
  static const String _libName = 'mpv';
  static void init() {
    try {
      final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('lib$_libName-2.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();
      Library.libmpv = LibMPV(_dylib);
      loaded = true;
    } catch (e) {
      debugPrint('error loading libmpv: ${e.toString()}');
    }
  }
}
