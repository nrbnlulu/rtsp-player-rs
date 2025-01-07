import 'package:flutter_gstreamer/video/dtos/video_widget_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_state.g.dart';

sealed class VideoState{

}

class VideoStateInitial extends VideoState{

}

class VideoStatePlaying extends VideoState{
  final bool _visible;
  final bool playing;
  final int width;
  final int height;

  VideoStatePlaying({
    required this.playing,
    required this.width,
    required this.height,
  }) : _visible = false;

  get visible => _visible && playing && width > 0 && height > 0;

  VideoState copyWith({
    bool? playing,
    int? width,
    int? height,
  }) {
    return VideoStatePlaying(
      playing: playing ?? this.playing,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}





@riverpod
class VideoStateNotifier extends _$VideoStateNotifier {
  late final VideoWidgetConfig config;


  VideoState build(VideoWidgetConfig config) {
    this.config = config;
    return VideoStateInitial();
  }

  void update(VideoStatePlaying state_) {
    state = state_;
  }
}

@riverpod
class TextureIdNotifier extends _$TextureIdNotifier {
  late final VideoWidgetConfig config;

  int? build(VideoWidgetConfig config) {
    this.config = config;
    return null;
  }
}
