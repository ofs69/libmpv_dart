import 'dart:ffi';
import 'dart:developer' as dev;
import 'package:ffi/ffi.dart';
import 'package:libmpv_dart/gen/bindings.dart';
import 'package:libmpv_dart/library.dart';

/// for desktop video texture properties
/// setPropertyString('vo', 'libmpv');
/// setPropertyString('hwdec', 'auto');
/// setPropertyString('vid', 'auto');

class Player {
  late Pointer<mpv_handle> ctx;
  int get handle => ctx.address;

  Player(Map<String, String> options) {
    if (!Library.loaded) {
      if (!Library.flagFirst) {
        Library.init();
      } else {
        throw Exception('libmpv is not loaded!');
      }
    }
    ctx = Library.libmpv.mpv_create();
    for (var entry in options.entries) {
      final key = entry.key.toNativeUtf8();
      final value = entry.value.toNativeUtf8();
      int error=Library.libmpv.mpv_set_option_string(ctx, key.cast(), value.cast());
      if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
    }
      calloc.free(key);
      calloc.free(value);
    }
    int error=Library.libmpv.mpv_initialize(ctx);
    if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
    }
  }

  void command(List<String> args) {
    var pointers = args.map((str) => str.toNativeUtf8()).toList();
    final arr = calloc<Pointer<Utf8>>(sizeOf<Pointer<Utf8>>() * args.length);

    for (int i = 0; i < args.length; i++) {
      (arr + i).value = pointers[i];
    }
    int error=Library.libmpv.mpv_command(ctx, arr.cast());
    if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
    }
    calloc.free(arr);
    pointers.forEach(calloc.free);
  }

  void setPropertyAll(
    String name,
    mpv_format format,
    Pointer<Void> data,
  ) {
    final namePtr = name.toNativeUtf8();

    int error = Library.libmpv.mpv_set_property(
      ctx,
      namePtr.cast(),
      format,
      data,
    );
    if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
    }
    calloc.free(namePtr);
  }

  void setPropertyFlag(String name, bool value) {
    final ptr = calloc<Bool>(1)..value = value;
    setPropertyAll(
      name,
      mpv_format.MPV_FORMAT_FLAG,
      ptr.cast(),
    );
    calloc.free(ptr);
  }

  void setPropertyDouble(
    String name,
    double value,
  ) {
    final ptr = calloc<Double>(1)..value = value;
    setPropertyAll(
      name,
      mpv_format.MPV_FORMAT_DOUBLE,
      ptr.cast(),
    );
    calloc.free(ptr);
  }

  void setPropertyInt64(
    String name,
    int value,
  ) {
    final ptr = calloc<Int64>(1)..value = value;
    setPropertyAll(
      name,
      mpv_format.MPV_FORMAT_INT64,
      ptr.cast(),
    );
    calloc.free(ptr);
  }

  void setPropertyString(
    String name,
    String value,
  ) {
    final string = value.toNativeUtf8();
    final ptr = calloc<Pointer<Void>>(1);
    ptr.value = Pointer.fromAddress(string.address);
    setPropertyAll(
      name,
      mpv_format.MPV_FORMAT_STRING,
      ptr.cast(),
    );
    calloc.free(ptr);
    calloc.free(string);
  }

  void setProperty(String name, dynamic value) {
    if (value is double) {
      setPropertyDouble(name, value);
    } else if (value is int) {
      setPropertyInt64(name, value);
    } else if (value is String) {
      setPropertyString(name, value);
    } else if (value is bool) {
      setPropertyFlag(name, value);
    } else {
      throw Exception('Invalid value type');
    }
  }

  void commandNode(Pointer<mpv_node> node1, Pointer<mpv_node> node2) {
    int error=Library.libmpv.mpv_command_node(ctx, node1, node2);
     if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
    }
  }

  Pointer<mpv_event> waitEvent(double timeout,{bool printEvent=false}){

    Pointer<mpv_event> event=Library.libmpv.mpv_wait_event(ctx, timeout);
    if (event.ref.error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(event.ref.error).cast<Utf8>().toDartString());
    }
   
  return event;
  }
}
