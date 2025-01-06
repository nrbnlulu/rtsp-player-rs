/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gstreamer/managers/backends/native_streamer.dart';
import 'package:flutter_gstreamer/managers/bases/platform_stream.dart';
import 'package:flutter_gstreamer/video/controller/platform_video_controller.dart';
import 'package:flutter_gstreamer/video/controller/video_controller.dart';
import 'package:flutter_gstreamer/video/state/video_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class VideoWidgetConfig{
    /// The [VideoController] reference to control this [Video] output.
  final VideoController controller;

  /// Width of this viewport.
  final double? width;

  /// Height of this viewport.
  final double? height;

  /// Fit of the viewport.
  final BoxFit fit;

  /// Background color to fill the video background.
  final Color fill;

  /// Alignment of the viewport.
  final Alignment alignment;

  /// Preferred aspect ratio of the viewport.
  final double? aspectRatio;

  /// Filter quality of the [Texture] widget displaying the video output.
  final FilterQuality filterQuality;

  /// Video controls builder.
  final VideoControlsBuilder? controls;

  /// Whether to acquire wake lock while playing the video.
  final bool wakelock;

  /// Whether to pause the video when application enters background mode.
  final bool pauseUponEnteringBackgroundMode;

  /// Whether to resume the video when application enters foreground mode.
  ///
  /// This attribute is only applicable if [pauseUponEnteringBackgroundMode] is `true`.
  ///
  final bool resumeUponEnteringForegroundMode;

  /// The callback invoked when the [Video] enters fullscreen.
  final Future<void> Function() onEnterFullscreen;

  /// The callback invoked when the [Video] exits fullscreen.
  final Future<void> Function() onExitFullscreen;

  const VideoWidgetConfig({
    required this.controller,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fill = const Color(0xFF000000),
    this.alignment = Alignment.center,
    this.aspectRatio,
    this.filterQuality = FilterQuality.low,
    this.wakelock = true,
    this.pauseUponEnteringBackgroundMode = true,
    this.resumeUponEnteringForegroundMode = false,
    this.controls,
    this.onEnterFullscreen = defaultEnterNativeFullscreen,
    this.onExitFullscreen = defaultExitNativeFullscreen,
  });
}
var conf = PlayerConfiguration();



/// {@template video}
///
/// Video
/// -----
/// [Video] widget is used to display video output.
///
/// Use [VideoController] to initialize & handle the video rendering.
///
/// **Example:**
///
/// ```dart
/// class MyScreen extends StatefulWidget {
///   const MyScreen({Key? key}) : super(key: key);
///   @override
///   State<MyScreen> createState() => MyScreenState();
/// }
///
/// class MyScreenState extends State<MyScreen> {
///   late final player = NativePlayer();
///   late final controller = VideoController(player);
///
///   @override
///   void initState() {
///     super.initState();
///     player.open(Media('https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'));
///   }
///
///   @override
///   void dispose() {
///     player.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Video(
///         controller: controller,
///       ),
///     );
///   }
/// }
/// ```
///
/// {@endtemplate}
class Video extends  ConsumerWidget {

  final VideoWidgetConfig config;


  /// {@macro video}
  Video({
    Key? key,
    required VideoController controller,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color fill = const Color(0xFF000000),
    Alignment alignment = Alignment.center,
    double? aspectRatio,
    FilterQuality filterQuality = FilterQuality.low,
    VideoControlsBuilder? controls,
    bool wakelock = true,
    bool pauseUponEnteringBackgroundMode = true,
    bool resumeUponEnteringForegroundMode = false,
  }
  ):config =  VideoWidgetConfig(
    controller: controller,
    width: width,
    height: height,
    fit: fit,
    fill: fill,
    alignment: alignment,
    aspectRatio: aspectRatio,
    filterQuality: filterQuality,
    controls: controls,
    wakelock: wakelock,
    pauseUponEnteringBackgroundMode: pauseUponEnteringBackgroundMode,
    resumeUponEnteringForegroundMode: resumeUponEnteringForegroundMode,
  ), super(key: key);
    

   @override
  Widget build(BuildContext context, WidgetRef ref) {
      
    return Container(
            clipBehavior: Clip.none,
            width: config.width,
            height: config.height,
            color: config.fill,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: FittedBox(
                    fit: config.fit,
                    alignment: config.alignment,
                    child:ValueListenableBuilder<int?>(
                              valueListenable: notifier.id,
                              builder: (context, id, _) {
                                return ValueListenableBuilder<Rect?>(
                                  valueListenable: notifier.rect,
                                  builder: (context, rect, _) {
                                    if (id != null &&
                                        rect != null &&
                                        _visible) {
                                      return SizedBox(
                                        // Apply aspect ratio if provided.
                                        width:
                                            config.aspectRatio ==
                                                    null
                                                ? rect.width
                                                : rect.height *
                                                    config
                                                        .aspectRatio!,
                                        height: rect.height,
                                        child: Stack(
                                          children: [
                                            const SizedBox(),
                                            Positioned.fill(
                                              child: Texture(
                                                textureId: id,
                                                filterQuality:
                                                    config
                                                        .filterQuality,
                                              ),
                                            ),
                                            // Keep the |Texture| hidden before the first frame renders. In native implementation, if no default frame size is passed (through VideoController), a starting 1 pixel sized texture/surface is created to initialize the render context & check for H/W support.
                                            // This is then resized based on the video dimensions & accordingly texture ID, texture, EGLDisplay, EGLSurface etc. (depending upon platform) are also changed. Just don't show that 1 pixel texture to the UI.
                                            // NOTE: Unmounting |Texture| causes the |MarkTextureFrameAvailable| to not do anything on GNU/Linux.
                                            if (rect.width <= 1.0 &&
                                                rect.height <= 1.0)
                                              Positioned.fill(
                                                child: Container(
                                                  color:
                                                      config.fill,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                );
                              },
                            )
                  ),
                ),
                if (config.controls != null)
                  Positioned.fill(
                    child: config.controls!.call(this),
                  ),
              ],
            ),
          );
  }
}




typedef VideoControlsBuilder = Widget Function(VideoState state);

// --------------------------------------------------

/// Makes the native window enter fullscreen.
Future<void> defaultEnterNativeFullscreen() async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await Future.wait(
        [
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          ),
          SystemChrome.setPreferredOrientations(
            [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
          ),
        ],
      );
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      await const MethodChannel('com.alexmercerind/media_kit_video')
          .invokeMethod(
        'Utils.EnterNativeFullscreen',
      );
    }
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}

/// Makes the native window exit fullscreen.
Future<void> defaultExitNativeFullscreen() async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await Future.wait(
        [
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          ),
          SystemChrome.setPreferredOrientations(
            [],
          ),
        ],
      );
    } else if (Platform.isMacOS | Platform.isWindows | Platform.isLinux) {
      await const MethodChannel('com.alexmercerind/media_kit_video')
          .invokeMethod(
        'Utils.ExitNativeFullscreen',
      );
    }
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }
}
// --------------------------------------------------
