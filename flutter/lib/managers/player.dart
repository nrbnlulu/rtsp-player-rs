/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
import 'dart:typed_data';
import 'package:flutter_gstreamer/dtos/audio_device.dart';
import 'package:flutter_gstreamer/dtos/media/media_native.dart';
import 'package:flutter_gstreamer/dtos/playable.dart';
import 'package:flutter_gstreamer/dtos/player_state.dart';
import 'package:flutter_gstreamer/dtos/player_stream.dart';
import 'package:flutter_gstreamer/dtos/track.dart';
import 'package:flutter_gstreamer/managers/backends/native_streamer.dart';
import 'package:flutter_gstreamer/managers/bases/platform_stream.dart';
import 'package:universal_platform/universal_platform.dart';



/// {@template player}
///
/// Player
/// ------
///
/// [Player] class provides high-level abstraction for media playback.
/// Large number of features have been exposed as class methods & properties.
///
/// The instantaneous state may be accessed using the [state] getter & subscription to the them may be made using the [stream] available.
///
/// Call [dispose] to free the allocated resources back to the system.
///
/// ```dart
/// import 'package:media_kit/media_kit.dart';
///
/// NativePlayableKit.ensureInitialized();
///
/// // Create a [Player] instance for audio or video playback.
///
/// final player = Player();
///
/// // Subscribe to event stream & listen to updates.
///
/// player.stream.playlist.listen((e) => print(e));
/// player.stream.playing.listen((e) => print(e));
/// player.stream.completed.listen((e) => print(e));
/// player.stream.position.listen((e) => print(e));
/// player.stream.duration.listen((e) => print(e));
/// player.stream.volume.listen((e) => print(e));
/// player.stream.rate.listen((e) => print(e));
/// player.stream.pitch.listen((e) => print(e));
/// player.stream.buffering.listen((e) => print(e));
///
/// // Open a playable [NativePlayable] or [Playlist].
///
/// await player.open(NativePlayable('asset:///assets/videos/sample.mp4'));
/// await player.open(NativePlayable('file:///C:/Users/Hitesh/Music/Sample.mp3'));
/// await player.open(
///   Playlist(
///     [
///       NativePlayable('file:///C:/Users/Hitesh/Music/Sample.mp3'),
///       NativePlayable('file:///C:/Users/Hitesh/Video/Sample.mkv'),
///       NativePlayable('https://www.example.com/sample.mp4'),
///       NativePlayable('rtsp://www.example.com/live'),
///     ],
///   ),
/// );
///
/// // Control playback state.
///
/// await player.play();
/// await player.pause();
/// await player.playOrPause();
/// await player.seek(const Duration(seconds: 10));
///
/// // Use or modify the queue.
///
/// await player.next();
/// await player.previous();
/// await player.jump(2);
/// await player.add(NativePlayable('https://www.example.com/sample.mp4'));
/// await player.move(0, 2);
///
/// // Customize speed, pitch, volume, shuffle, playlist mode, audio device.
///
/// await player.setRate(1.0);
/// await player.setPitch(1.2);
/// await player.setVolume(50.0);
/// await player.setShuffle(false);
/// await player.setPlaylistMode(PlaylistMode.loop);
/// await player.setAudioDevice(AudioDevice.auto());
///
/// // Release allocated resources back to the system.
///
/// await player.dispose();
/// ```
///
/// {@endtemplate}
///
class Player {
  /// {@macro player}
  Player({
    PlayerConfiguration configuration = const PlayerConfiguration(),
  }) {
    if (UniversalPlatform.isWindows) {
      platform = NativePlayer(configuration: configuration);
    } else if (UniversalPlatform.isLinux) {
      platform = NativePlayer(configuration: configuration);
    } else if (UniversalPlatform.isMacOS) {
      throw UnimplementedError('MacOS platform is not supported yet.');
    } else if (UniversalPlatform.isIOS) {
      throw UnimplementedError('IOS platform is not supported yet.');
    } else if (UniversalPlatform.isAndroid) {
      throw UnimplementedError('android platform is not supported yet.');
    } else if (UniversalPlatform.isWeb) {
      throw UnimplementedError('Web platform is not supported yet.');
    }
  }

  /// Platform specific internal implementation initialized depending upon the current platform.
  IPlatformPlayer? platform;

  /// Current state of the [Player].
  PlayerState get state => platform!.state;

  /// Current state of the [Player] available as listenable [Stream]s.
  PlayerStream get stream => platform!.stream;

  /// Current state of the [Player] available as listenable [Stream]s.
  @Deprecated('Use [stream] instead')
  PlayerStream get streams => stream;

  /// Disposes the [Player] instance & releases the resources.
  Future<void> dispose() async {
    return platform?.dispose();
  }

  /// Opens a [NativePlayable] or [Playlist] into the [Player].
  /// Passing [play] as `true` starts the playback immediately.
  ///
  /// ```dart
  /// await player.open(NativePlayable('asset:///assets/videos/sample.mp4'));
  /// await player.open(NativePlayable('file:///C:/Users/Hitesh/Music/Sample.mp3'));
  /// await player.open(
  ///   Playlist(
  ///     [
  ///       NativePlayable('file:///C:/Users/Hitesh/Music/Sample.mp3'),
  ///       NativePlayable('file:///C:/Users/Hitesh/Video/Sample.mkv'),
  ///       NativePlayable('https://www.example.com/sample.mp4'),
  ///       NativePlayable('rtsp://www.example.com/live'),
  ///     ],
  ///   ),
  /// );
  /// ```
  ///
  Future<void> open(
    Playable playable, {
    bool play = true,
  }) async {
    return platform?.open(
      playable,
      play: play,
    );
  }

  /// Stops the [Player].
  /// Unloads the current [NativePlayable] or [Playlist] from the [Player]. This method is similar to [dispose] but does not release the resources & [Player] is still usable.
  Future<void> stop() async {
    return platform?.stop();
  }

  /// Starts playing the [Player].
  Future<void> play() async {
    return platform?.play();
  }

  /// Pauses the [Player].
  Future<void> pause() async {
    return platform?.pause();
  }

  /// Cycles between [play] & [pause] states of the [Player].
  Future<void> playOrPause() async {
    return platform?.playOrPause();
  }

  /// Appends a [NativePlayable] to the [Player]'s playlist.
  Future<void> add(NativePlayable playable) async {
    return platform?.add(playable);
  }

  /// Removes the [NativePlayable] at specified index from the [Player]'s playlist.
  Future<void> remove(int index) async {
    return platform?.remove(index);
  }

  /// Jumps to next [NativePlayable] in the [Player]'s playlist.
  Future<void> next() async {
    return platform?.next();
  }

  /// Jumps to previous [NativePlayable] in the [Player]'s playlist.
  Future<void> previous() async {
    return platform?.previous();
  }

  /// Jumps to specified [NativePlayable]'s index in the [Player]'s playlist.
  Future<void> jump(int index) async {
    return platform?.jump(index);
  }

  /// Moves the playlist [NativePlayable] at [from], so that it takes the place of the [NativePlayable] [to].
  Future<void> move(int from, int to) async {
    return platform?.move(from, to);
  }

  /// Seeks the currently playing [NativePlayable] in the [Player] by specified [Duration].
  Future<void> seek(Duration duration) async {
    return platform?.seek(duration);
  }

  /// Sets the playback volume of the [Player].
  /// Defaults to `100.0`.
  Future<void> setVolume(double volume) async {
    return platform?.setVolume(volume);
  }

  /// Sets the playback rate of the [Player].
  /// Defaults to `1.0`.
  Future<void> setRate(double rate) async {
    return platform?.setRate(rate);
  }

  /// Sets the relative pitch of the [Player].
  /// Defaults to `1.0`.
  Future<void> setPitch(double pitch) async {
    return platform?.setPitch(pitch);
  }

  /// Enables or disables shuffle for [Player].
  /// Default is `false`.
  Future<void> setShuffle(bool shuffle) async {
    return platform?.setShuffle(shuffle);
  }

  /// Sets the current [AudioDevice] for audio output.
  ///
  /// * Currently selected [AudioDevice] can be accessed using [state.audioDevice] or [stream.audioDevice].
  /// * The list of currently available [AudioDevice]s can be obtained accessed using [state.audioDevices] or [stream.audioDevices].
  Future<void> setAudioDevice(AudioDevice audioDevice) async {
    return platform?.setAudioDevice(audioDevice);
  }

  /// Sets the current [VideoTrack] for video output.
  ///
  /// * Currently selected [VideoTrack] can be accessed using [state.track.video] or [stream.track.video].
  /// * The list of currently available [VideoTrack]s can be obtained accessed using [state.tracks.video] or [stream.tracks.video].
  Future<void> setVideoTrack(VideoTrack track) async {
    return platform?.setVideoTrack(track);
  }

  /// Sets the current [AudioTrack] for audio output.
  ///
  /// * Currently selected [AudioTrack] can be accessed using [state.track.audio] or [stream.track.audio].
  /// * The list of currently available [AudioTrack]s can be obtained accessed using [state.tracks.audio] or [stream.tracks.audio].
  /// * External audio track can be loaded using [AudioTrack.uri] constructor.
  ///
  /// ```dart
  /// player.setAudioTrack(
  ///   AudioTrack.uri(
  ///     'https://www.iandevlin.com/html5test/webvtt/v/upc-tobymanley.mp4',
  ///     title: 'English',
  ///     language: 'en',
  ///   ),
  /// );
  /// ```
  ///
  Future<void> setAudioTrack(AudioTrack track) async {
    return platform?.setAudioTrack(track);
  }

  /// Takes the snapshot of the current video frame & returns encoded image bytes as [Uint8List].
  ///
  /// The [format] parameter specifies the format of the image to be returned. Supported values are:
  /// * `image/jpeg`: Returns a JPEG encoded image.
  /// * `image/png`: Returns a PNG encoded image.
  /// * `null`: Returns BGRA pixel buffer.
  ///
  /// On the native backend, if [includeLibassSubtitles] is `true` *and*
  /// [PlayerConfiguration.libass] is `true`, then the screenshot will include
  /// the on-screen subtitles. This option is ignored by the web backend.
  Future<Uint8List?> screenshot(
      {String? format = 'image/jpeg',
      bool includeLibassSubtitles = false}) async {
    return platform?.screenshot(
      format: format,
    );
  }

  /// Internal platform specific identifier for this [Player] instance.
  ///
  /// Since, [int] is a primitive type, it can be used to pass this [Player] instance to native code without directly depending upon this library.
  ///
  Future<int> get handle {
    final result = platform?.handle;
    return result!;
  }
}
