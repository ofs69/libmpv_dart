#include "include/libmpv_dart/libmpv_dart_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "libmpv_dart/libmpv_dart_plugin.h"

void LibmpvDartPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  libmpv_dart::LibmpvDartPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
