import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:libmpv/gen/bindings.dart';

class Library {
  static late LibMPV libmpv;
  static bool loaded = false;

  static void init(String path) {
    try {
      Library.libmpv = LibMPV(DynamicLibrary.open(path));
      loaded = true;
    } catch (e) {
      debugPrint('error loading libmpv: ${e.toString()}');
    }
  }
}
