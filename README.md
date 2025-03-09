# libmpv_dart

libmpv_dart is a Dart binding for [libmpv](https://github.com/mpv-player/mpv/tree/master/include/mpv),aiming to provide Dart users with an efficient and convenient way to use libmpv.

| Platform | status |
| -------- | ------ |
| Windows  | ✅     |
| Android  | ✅     |
| Linux    | ✅     |
| iOS      | ❌     |
| MacOS    | ❌     |

## Setup

First,add libmpv_dart to your pubspec.yaml:

```
flutter pub add libmpv_dart
```

For windows/android users,run following command in your terminal:

```shell
dart run libmpv_dart:setup --platform windows
dart run libmpv_dart:setup --platform android
```

For linux users,all you need to do is install libmpv.

```shell
sudo apt install libmpv-dart
```

## How to use?

Generate a player instance(corresponding to mpv_handle)

```dart
import 'package:libmpv_dart/libmpv.dart' as mpv;
option={
"terminal":"yes",
"gapless-audio":"yes",
"log-file":logPath,    //corresponding to mpv_set_option_string()
};
  }
  mpv.Player player = mpv.Player(option);
```

then you can execute some command,for example.load a file:

```dart
player.command(["loadfile",inputPath]);
```

After all the jobs are done,destory the player to free memory:

```dart
player.destroy();
```

or you can wait for a mpv event:

```dart
 while(true){
   Pointer<mpv_event> event=player.waitEvent(0);
if(event.ref.event_id==mpv_event_id.MPV_EVENT_SHUTDOWN){
break;
}
else if(event.ref.event_id==mpv_event_id.MPV_EVENT_END_FILE){
  break;
}  
//wait until event happen.
```
