#include "libmpv_dart/libmpv_dart_plugin.h"

#include <Windows.h>

namespace libmpv_dart {

void LibmpvDartPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<LibmpvDartPlugin>(registrar);
  registrar->AddPlugin(std::move(plugin));
}

LibmpvDartPlugin::LibmpvDartPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar),
      video_output_manager_(std::make_unique<VideoOutputManager>(registrar)) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "libmpv_dart",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([&](const auto& call, auto result) {
    HandleMethodCall(call, std::move(result));
  });
}

LibmpvDartPlugin::~LibmpvDartPlugin() {}

void LibmpvDartPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("VOCreate") == 0) {
    auto args = std::get<flutter::EncodableMap>(*method_call.arguments());
    // auto _handle =
    //     std::get<std::string>(args[flutter::EncodableValue("handle")]);
    // auto handle = std::stoll(_handle);
    const auto handle = args[flutter::EncodableValue("handle")].LongValue();
    auto configuration = VideoOutputConfiguration{};
    auto hwdec = std::get<bool>(args[flutter::EncodableValue("hwdec")]);
    configuration.enable_hardware_acceleration = hwdec;

    // We don't need this callback anymore
    auto callback_ = [](int64_t, int64_t, int64_t) {};

    int64_t textureId =
        video_output_manager_->Create(handle, configuration, callback_);
    result->Success(flutter::EncodableValue(textureId));
  } else if (method_call.method_name().compare("VODispose") == 0) {
    auto args = std::get<flutter::EncodableMap>(*method_call.arguments());
    const auto handle = args[flutter::EncodableValue("handle")].LongValue();

    video_output_manager_->Dispose(handle);
    result->Success(flutter::EncodableValue(std::monostate{}));
  } else if (method_call.method_name().compare("VOSetSize") == 0) {
    auto args = std::get<flutter::EncodableMap>(*method_call.arguments());
    const auto handle = args[flutter::EncodableValue("handle")].LongValue();
    const auto _width = args[flutter::EncodableValue("width")].LongValue();
    const auto _height = args[flutter::EncodableValue("height")].LongValue();

    auto width = _width != 0 ? _width : std::optional<int64_t>{};
    auto height = _height != 0 ? _height : std::optional<int64_t>{};

    int64_t textureId = video_output_manager_->SetSize(handle, width, height);
    result->Success(flutter::EncodableValue(textureId));
  } else {
    result->NotImplemented();
  }
}

}  // namespace libmpv_dart
