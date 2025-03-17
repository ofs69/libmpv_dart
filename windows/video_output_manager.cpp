#include "libmpv_dart/video_output_manager.h"

VideoOutputManager::VideoOutputManager(
    flutter::PluginRegistrarWindows *registrar)
    : registrar_(registrar) {}

int64_t VideoOutputManager::Create(
    int64_t handle, VideoOutputConfiguration configuration,
    std::function<void(int64_t, int64_t, int64_t)> texture_update_callback) {
  // std::thread([=]() {
  // }).detach();
  std::lock_guard<std::mutex> lock(mutex_);
  if (video_outputs_.find(handle) == video_outputs_.end()) {
    auto instance = std::make_unique<VideoOutput>(
        handle, configuration, registrar_, thread_pool_.get());
    instance->SetTextureUpdateCallback(texture_update_callback);
    video_outputs_.insert(std::make_pair(handle, std::move(instance)));
    return video_outputs_[handle]->texture_id();
  }
  return 0;
}

int64_t VideoOutputManager::SetSize(int64_t handle,
                                    std::optional<int64_t> width,
                                    std::optional<int64_t> height) {
  // std::thread([=]() {
  // }).detach();
  std::lock_guard<std::mutex> lock(mutex_);
  if (video_outputs_.contains(handle)) {
    return video_outputs_[handle]->SetSize(width, height);
  }
  return 0;
}

void VideoOutputManager::Dispose(int64_t handle) {
  // std::thread([=]() {
  // }).detach();
  std::lock_guard<std::mutex> lock(mutex_);
  if (video_outputs_.contains(handle)) {
    video_outputs_.erase(handle);
  }
}

VideoOutputManager::~VideoOutputManager() {
  // std::lock_guard<std::mutex> lock(mutex_);
  //  |VideoOutput| destructor will do the relevant cleanup.
  video_outputs_.clear();
  // This destructor is only called when the plugin is being destroyed i.e. the
  // application is being closed. So, doesn't really matter on the other hand.
}
