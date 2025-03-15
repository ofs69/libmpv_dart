import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:libmpv_dart/gen/bindings.dart';

import 'package:libmpv_dart/library.dart';
import 'package:libmpv_dart/video/params.dart';

typedef WakeUpCallback = Void Function(Pointer<mpv_handle>);
typedef WakeUpNativeCallable = NativeCallable<WakeUpCallback>;

typedef EventCallback = Future<void> Function(Pointer<mpv_event>);

MethodChannel _channel = const MethodChannel('libmpv_dart');

class Player {
  late Pointer<mpv_handle> ctx;
  int get handle => ctx.address;
  bool _videoOutput = false;

  Player(Map<String, String> options, {bool videoOutput = false}) {
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
      int error =
          Library.libmpv.mpv_set_option_string(ctx, key.cast(), value.cast());
      if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
        throw Exception(
            Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
      }
      calloc.free(key);
      calloc.free(value);
    }
    int error = Library.libmpv.mpv_initialize(ctx);
    if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
    }

    <String, mpv_format>{
      'video-out-params': mpv_format.MPV_FORMAT_NODE,
      'time-pos': mpv_format.MPV_FORMAT_DOUBLE,
    }.forEach(
      (property, format) {
        final name = property.toNativeUtf8();
        Library.libmpv.mpv_observe_property(
          ctx,
          0,
          name.cast(),
          format,
        );
        calloc.free(name);
      },
    );
    // TODO: dispose
    final nativeCallable = WakeUpNativeCallable.listener(_mpvCallback);
    final nativeFunction = nativeCallable.nativeFunction;
    Library.libmpv
        .mpv_set_wakeup_callback(ctx, nativeFunction.cast(), ctx.cast());

    _videoOutput = videoOutput;
    if (videoOutput) {
      initVO();
    }
  }

  Future<void> initVO() async {
    setPropertyString('vo', 'libmpv');
    setPropertyString('hwdec', 'auto');
    setPropertyString('vid', 'auto');

    final textureId = await _channel.invokeMethod(
      'VOCreate',
      {
        'handle': handle,
        'hwdec': true,
      },
    );

    id.value = textureId;
  }

  Future<void> refreshVO(int? width, int? height) async {
    if (!_videoOutput) return;
    final textureId = await _channel.invokeMethod(
      'VOSetSize',
      {
        'handle': handle,
        'width': (width ?? videoWidth),
        'height': (height ?? videoHeight),
      },
    );

    id.value = textureId;
  }

  void command(List<String> args) {
    var pointers = args.map((str) => str.toNativeUtf8()).toList();
    final arr = calloc<Pointer<Utf8>>(sizeOf<Pointer<Utf8>>() * args.length);

    for (int i = 0; i < args.length; i++) {
      (arr + i).value = pointers[i];
    }
    int error = Library.libmpv.mpv_command(ctx, arr.cast());
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

  Future<void> observeProperty(
    String property,
    Future<void> Function(String) listener,
  ) async {
    final reply = property.hashCode;
    observed[property] = listener;
    final name = property.toNativeUtf8();
    Library.libmpv.mpv_observe_property(
      ctx,
      reply,
      name.cast(),
      mpv_format.MPV_FORMAT_NONE,
    );
    calloc.free(name);
  }

  void commandNode(Pointer<mpv_node> node1, Pointer<mpv_node> node2) {
    int error = Library.libmpv.mpv_command_node(ctx, node1, node2);
    if (error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(
          Library.libmpv.mpv_error_string(error).cast<Utf8>().toDartString());
    }
  }

  Pointer<mpv_event> waitEvent(double timeout) {
    Pointer<mpv_event> event = Library.libmpv.mpv_wait_event(ctx, timeout);
    if (event.ref.error != mpv_error.MPV_ERROR_SUCCESS.value) {
      throw Exception(Library.libmpv
          .mpv_error_string(event.ref.error)
          .cast<Utf8>()
          .toDartString());
    }

    return event;
  }

  void destroy() {
    Library.libmpv.mpv_destroy(ctx);
  }

  final StreamController<VideoParams> _videoParamsController =
      StreamController<VideoParams>.broadcast();

  late final Stream<VideoParams> videoParamsStream =
      _videoParamsController.stream.distinct(
    (previous, current) => previous == current,
  );

  final HashMap<String, Future<void> Function(String)> observed = HashMap();

  // state for video render
  VideoParams videoParams = const VideoParams();
  int videoHeight = 0;
  int videoWidth = 0;
  final ValueNotifier<int> id = ValueNotifier<int>(0);
  // state

  final StreamController<int> _heightController =
      StreamController<int>.broadcast();
  final StreamController<int> _widthController =
      StreamController<int>.broadcast();

  late final Stream<int> heightStream = _heightController.stream.distinct(
    (previous, current) => previous == current,
  );
  late final Stream<int> widthStream = _widthController.stream.distinct(
    (previous, current) => previous == current,
  );

  void _mpvCallback(Pointer<mpv_handle> ctx) async {
    while (true) {
      final event = Library.libmpv.mpv_wait_event(ctx, 0);
      if (event == nullptr) return;
      if (event.ref.event_id == mpv_event_id.MPV_EVENT_NONE) return;
      await _mpvHandler(event);
    }
  }

  Future<void> _mpvHandler(Pointer<mpv_event> event) async {
    if (event.ref.event_id == mpv_event_id.MPV_EVENT_PROPERTY_CHANGE) {
      final prop = event.ref.data.cast<mpv_event_property>();
      if (prop.ref.name.cast<Utf8>().toDartString() == 'video-out-params' &&
          prop.ref.format == mpv_format.MPV_FORMAT_NODE) {
        final node = prop.ref.data.cast<mpv_node>().ref;
        final data = <String, dynamic>{};
        for (int i = 0; i < node.u.list.ref.num; i++) {
          final key = node.u.list.ref.keys[i].cast<Utf8>().toDartString();
          final value = node.u.list.ref.values[i];
          switch (value.format) {
            case mpv_format.MPV_FORMAT_INT64:
              data[key] = value.u.int64;
              break;
            case mpv_format.MPV_FORMAT_DOUBLE:
              data[key] = value.u.double_;
              break;
            case mpv_format.MPV_FORMAT_STRING:
              data[key] = value.u.string.cast<Utf8>().toDartString();
              break;
            default:
              break;
          }
        }

        final params = VideoParams(
          pixelformat: data['pixelformat'],
          hwPixelformat: data['hw-pixelformat'],
          w: data['w'],
          h: data['h'],
          dw: data['dw'],
          dh: data['dh'],
          aspect: data['aspect'],
          par: data['par'],
          colormatrix: data['colormatrix'],
          colorlevels: data['colorlevels'],
          primaries: data['primaries'],
          gamma: data['gamma'],
          sigPeak: data['sig-peak'],
          light: data['light'],
          chromaLocation: data['chroma-location'],
          rotate: data['rotate'],
          stereoIn: data['stereo-in'],
          averageBpp: data['average-bpp'],
          alpha: data['alpha'],
        );

        videoParams = params;
        if (!_videoParamsController.isClosed) {
          _videoParamsController.add(params);
        }

        final dw = params.dw;
        final dh = params.dh;
        final rotate = params.rotate ?? 0;
        if (dw is int && dh is int) {
          final int width;
          final int height;
          if (rotate == 0 || rotate == 180) {
            width = dw;
            height = dh;
          } else {
            // width & height are swapped for 90 or 270 degrees rotation.
            width = dh;
            height = dw;
          }
          videoHeight = height;
          videoWidth = width;
          if (!_widthController.isClosed) {
            _widthController.add(width);
          }
          if (!_heightController.isClosed) {
            _heightController.add(height);
          }
        }
        refreshVO(videoWidth, videoHeight);
      }
      if (observed.containsKey(prop.ref.name.cast<Utf8>().toDartString())) {
        if (prop.ref.format == mpv_format.MPV_FORMAT_NONE) {
          final fn = observed[prop.ref.name.cast<Utf8>().toDartString()];
          if (fn != null) {
            final data =
                Library.libmpv.mpv_get_property_string(ctx, prop.ref.name);
            if (data != nullptr) {
              try {
                await fn.call(data.cast<Utf8>().toDartString());
              } catch (exception, stacktrace) {
                debugPrint(exception.toString());
                debugPrint(stacktrace.toString());
              }
              Library.libmpv.mpv_free(data.cast());
            }
          }
        }
      }
    }
  }
}
