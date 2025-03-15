#ifndef LIBMPV_DART_PLUGIN_H_
#define LIBMPV_DART_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <winrt/Windows.System.h>

#include "video_output_manager.h"
#include "libmpv_dart_plugin_c_api.h"

namespace libmpv_dart {

class LibmpvDartPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  LibmpvDartPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~LibmpvDartPlugin();

  LibmpvDartPlugin(const LibmpvDartPlugin&) = delete;
  LibmpvDartPlugin& operator=(const LibmpvDartPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  flutter::PluginRegistrarWindows* registrar_ = nullptr;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_ =
      nullptr;
  std::unique_ptr<VideoOutputManager> video_output_manager_ = nullptr;
};

}  // namespace libmpv_dart

#endif  // LIBMPV_DART_PLUGIN_H_

//#ifndef FLUTTER_PLUGIN_LIBMPV_DART_PLUGIN_C_API_H_
//#define FLUTTER_PLUGIN_LIBMPV_DART_PLUGIN_C_API_H_
//
//#include <flutter_plugin_registrar.h>
//
//#ifdef FLUTTER_PLUGIN_IMPL
//#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
//#else
//#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
//#endif
//
//#if defined(__cplusplus)
//extern "C" {
//#endif
//
//FLUTTER_PLUGIN_EXPORT void LibmpvDartPluginRegisterWithRegistrar(
//    FlutterDesktopPluginRegistrarRef registrar);
//
//#if defined(__cplusplus)
//}  // extern "C"
//#endif
//
//#endif  // FLUTTER_PLUGIN_LIBMPV_DART_PLUGIN_C_API_H_
