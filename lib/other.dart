import 'dart:ffi';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:libmpv_dart/gen/bindings.dart';
import 'package:libmpv_dart/libmpv.dart';
  
  Pointer<mpv_node> createStringNode(String string) {
    Pointer<mpv_node> node = calloc<mpv_node>();
    node.ref.formatAsInt = mpv_format.MPV_FORMAT_STRING.value;
    node.ref.u.string = string.toNativeUtf8().cast<Char>();
    return node;
  }

  Pointer<mpv_node> createIntNode(int value) {
    Pointer<mpv_node> node = calloc<mpv_node>();
    node.ref.formatAsInt = mpv_format.MPV_FORMAT_INT64.value;
    node.ref.u.int64 = value;
    return node;
  }

  Pointer<mpv_node> createDoubleNode(double value) {
    Pointer<mpv_node> node = calloc<mpv_node>();
    node.ref.formatAsInt = mpv_format.MPV_FORMAT_DOUBLE.value;
    node.ref.u.double_ = value;
    return node;
  }

  Pointer<mpv_node> createFlagNode(bool value) {
    Pointer<mpv_node> node = calloc<mpv_node>();
    node.ref.formatAsInt = mpv_format.MPV_FORMAT_FLAG.value;
    node.ref.u.flag = value ? 1 : 0;
    return node;
  }

  Pointer<mpv_node> createNode(dynamic value) {
    if (value is double) {
      return createDoubleNode(value);
    } else if (value is int) {
      return createIntNode(value);
    } else if (value is String) {
      return createStringNode(value);
    } else if (value is bool) {
      return createFlagNode(value);
    } else {
      throw Exception('Invalid value type');
    }
  }

  String eventName(mpv_event_id eventId)
  {
    return Library.libmpv.mpv_event_name(eventId).cast<Utf8>().toDartString();
  }