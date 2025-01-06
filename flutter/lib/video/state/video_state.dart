import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_state.g.dart';

class VideoState{
  final bool _visible;
  final bool playing;
  final int width;
  final int height;

  VideoState({
    required this.playing,
    required this.width,
    required this.height,
  }): _visible = false;


  get visible => _visible && playing && width > 0 && height > 0;


  VideoState copyWith({
    bool? playing,
    int? width,
    int? height,
  }) {
    return VideoState(
      playing: playing ?? this.playing,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}


@riverpod
class VideoStateNotifier extends _$VideoStateNotifierProvider {
  VideoStateNotifier(VideoState state) : super(state);

  void update({
    bool? playing,
    int? width,
    int? height,
  }) {
    state = state.copyWith(
      playing: playing,
      width: width,
      height: height,
    );
  }
}




@riverpod
class TextureIdNotifier extends _$TextureIdNotifierProvider {
  TextureIdNotifier(int state) : super(state);

 int? build(){
  return null;
 }
 
}