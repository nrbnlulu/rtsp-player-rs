/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
import 'package:flutter_gstreamer/managers/backends/native_streamer.dart';
import 'package:flutter_gstreamer/managers/player.dart';
import 'package:flutter_gstreamer/video/controller/platform_video_controller.dart';

// Stub declaration for avoiding compilation errors on Dart JS using conditional imports.

class NativeVideoController extends PlatformVideoController {
  static const bool supported = false;

  NativeVideoController._(
    super.player,
    super.configuration,
  );

  static Future<PlatformVideoController> create(
    NativePlayer player,
    VideoControllerConfiguration configuration,
  ) =>
      throw UnimplementedError();

  @override
  Future<void> setSize({int? width, int? height}) => throw UnimplementedError();
}
