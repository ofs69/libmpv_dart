import 'dart:ffi';
import 'package:ffi/ffi.dart';
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

Pointer<mpv_node> createMapNode(Pointer<mpv_node_list> list) {
  Pointer<mpv_node> node = calloc<mpv_node>();
  node.ref.formatAsInt = mpv_format.MPV_FORMAT_NODE_MAP.value;
  node.ref.u.list = list;
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
  } else if (value is Pointer<mpv_node_list>) {
    return createMapNode(value);
  } else {
    throw Exception('Invalid value type');
  }
}

Pointer<mpv_node_list> createNodeList(
    List<String> key, List<Pointer<mpv_node>> values) {
  Pointer<mpv_node_list> list = calloc<mpv_node_list>();
  if (key.length != values.length) {
    throw Exception('Key and value length must be equal');
  }
  list.ref.num = key.length;
  list.ref.values = calloc<mpv_node>(key.length);
  for (int i = 0; i < key.length; i++) {
    list.ref.values[i] = values[i].ref;
  }
  list.ref.keys = calloc<Pointer<Char>>(key.length);
  for (int i = 0; i < key.length; i++) {
    list.ref.keys[i] = key[i].toNativeUtf8().cast<Char>();
  }
  return list;
}

String eventName(mpv_event_id eventId) {
  return Library.libmpv.mpv_event_name(eventId).cast<Utf8>().toDartString();
}
