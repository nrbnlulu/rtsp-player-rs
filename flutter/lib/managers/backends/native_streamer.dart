/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
import 'dart:io';
import 'dart:ffi';
import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter_gstreamer/dtos/audio_device.dart';
import 'package:flutter_gstreamer/dtos/media/media_native.dart';
import 'package:flutter_gstreamer/dtos/playable.dart';
import 'package:flutter_gstreamer/dtos/track.dart';
import 'package:flutter_gstreamer/managers/bases/platform_stream.dart';
import 'package:flutter_gstreamer/managers/utils/native_reference_holder.dart';
import 'package:path/path.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

/// Initializes the native backend for package:media_kit.
void nativeEnsureInitialized({String? libmpv}) {
  throw UnimplementedError();
}

/// {@template native_player}
///
/// NativePlayer
/// ------------
///
/// Native implementation of [IPlatformPlayer].
///
/// {@endtemplate}
class NativePlayer extends IPlatformPlayer {
  /// {@macro native_player}
  NativePlayer({required super.configuration});

  /// Disposes the [NativePlayer] instance & releases the resources.
  @override
  Future<void> dispose({bool synchronized = true}) {
    Future<void> function() async {
      if (disposed) {
        throw AssertionError('[NativePlayer] has been disposed');
      }
      await waitForPlayerInitialization;
      await waitForVideoControllerInitializationIfAttached;

      await stop(notify: false, synchronized: false);

      disposed = true;

      await super.dispose();
    }

    if (synchronized) {
      return lock.synchronized(function);
    } else {
      return function();
    }
  }

  /// Opens a [NativePlayable] or [Playlist] into the [NativePlayer].
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
  @override
  Future<void> open(
    Playable playable, {
    bool play = true,
    bool synchronized = true,
  }) {
    throw UnimplementedError();
  }

  /// Stops the [NativePlayer].
  /// Unloads the current [NativePlayable] or [Playlist] from the [NativePlayer]. This method is similar to [dispose] but does not release the resources & [NativePlayer] is still usable.
  @override
  Future<void> stop({
    bool open = false,
    bool notify = true,
    bool synchronized = true,
  }) async {
    throw UnimplementedError();
  }

  /// Starts playing the [NativePlayer].
  @override
  Future<void> play({bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Pauses the [NativePlayer].
  @override
  Future<void> pause({bool synchronized = true}) {
    Future<void> function() async {
      if (disposed) {
        throw AssertionError('[NativePlayer] has been disposed');
      }
      await waitForPlayerInitialization;
      await waitForVideoControllerInitializationIfAttached;

      state = state.copyWith(playing: false);
      if (!playingController.isClosed) {
        playingController.add(false);
      }

      isPlayingStateChangeAllowed = true;
      isBufferingStateChangeAllowed = false;
      await _setPropertyFlag('pause', true);
    }

    if (synchronized) {
      return lock.synchronized(function);
    } else {
      return function();
    }
  }

  /// Cycles between [play] & [pause] states of the [NativePlayer].
  @override
  Future<void> playOrPause({
    bool notify = true,
    bool synchronized = true,
  }) {
    throw UnimplementedError();
  }

  /// Appends a [NativePlayable] to the [NativePlayer]'s playlist.
  @override
  Future<void> add(NativePlayable media, {bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Removes the [NativePlayable] at specified index from the [NativePlayer]'s playlist.
  @override
  Future<void> remove(int index, {bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Jumps to next [NativePlayable] in the [NativePlayer]'s playlist.
  @override
  Future<void> next({bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Jumps to previous [NativePlayable] in the [NativePlayer]'s playlist.
  @override
  Future<void> previous({bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Jumps to specified [NativePlayable]'s index in the [NativePlayer]'s playlist.
  @override
  Future<void> jump(int index, {bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Moves the playlist [NativePlayable] at [from], so that it takes the place of the [NativePlayable] [to].
  @override
  Future<void> move(int from, int to, {bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Seeks the currently playing [NativePlayable] in the [NativePlayer] by specified [Duration].
  @override
  Future<void> seek(Duration duration, {bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Sets the playback volume of the [NativePlayer]. Defaults to `100.0`.
  @override
  Future<void> setVolume(double volume, {bool synchronized = true}) {
    Future<void> function() async {
      if (disposed) {
        throw AssertionError('[NativePlayer] has been disposed');
      }
      await waitForPlayerInitialization;
      await waitForVideoControllerInitializationIfAttached;

      await _setPropertyDouble('volume', volume);
    }

    if (synchronized) {
      return lock.synchronized(function);
    } else {
      return function();
    }
  }

  /// Sets the playback rate of the [NativePlayer]. Defaults to `1.0`.
  @override
  Future<void> setRate(double rate, {bool synchronized = true}) {
    Future<void> function() async {
      if (disposed) {
        throw AssertionError('[NativePlayer] has been disposed');
      }
      await waitForPlayerInitialization;
      await waitForVideoControllerInitializationIfAttached;

      if (rate <= 0.0) {
        throw ArgumentError.value(
          rate,
          'rate',
          'Must be greater than 0.0',
        );
      }

      if (configuration.pitch) {
        // Pitch shift control is enabled.

        state = state.copyWith(rate: rate);
        if (!rateController.isClosed) {
          rateController.add(state.rate);
        }
        // Apparently, using scaletempo:scale actually controls the playback rate as intended after setting audio-pitch-correction as FALSE.
        // speed on the other hand, changes the pitch when audio-pitch-correction is set to FALSE.
        // Since, it also alters the actual [speed], the scaletempo:scale is divided by the same value of [pitch] to compensate the speed change.
        await _setPropertyFlag('audio-pitch-correction', false);
        // Divide by [state.pitch] to compensate the speed change caused by pitch shift.
        await _setPropertyString('af',
            'scaletempo:scale=${(state.rate / state.pitch).toStringAsFixed(8)}');
      } else {
        // Pitch shift control is disabled.

        state = state.copyWith(rate: rate);
        if (!rateController.isClosed) {
          rateController.add(state.rate);
        }
        await _setPropertyDouble('speed', rate);
      }
    }

    if (synchronized) {
      return lock.synchronized(function);
    } else {
      return function();
    }
  }

  /// Sets the relative pitch of the [NativePlayer]. Defaults to `1.0`.
  @override
  Future<void> setPitch(double pitch, {bool synchronized = true}) {
    Future<void> function() async {
      if (disposed) {
        throw AssertionError('[NativePlayer] has been disposed');
      }
      await waitForPlayerInitialization;
      await waitForVideoControllerInitializationIfAttached;

      if (configuration.pitch) {
        if (pitch <= 0.0) {
          throw ArgumentError.value(
            pitch,
            'pitch',
            'Must be greater than 0.0',
          );
        }

        // Pitch shift control is enabled.

        state = state.copyWith(pitch: pitch);
        if (!pitchController.isClosed) {
          pitchController.add(state.pitch);
        }
        // Apparently, using scaletempo:scale actually controls the playback rate as intended after setting audio-pitch-correction as FALSE.
        // speed on the other hand, changes the pitch when audio-pitch-correction is set to FALSE.
        // Since, it also alters the actual [speed], the scaletempo:scale is divided by the same value of [pitch] to compensate the speed change.
        await _setPropertyFlag('audio-pitch-correction', false);
        await _setPropertyDouble('speed', pitch);
        // Divide by [state.pitch] to compensate the speed change caused by pitch shift.
        await _setPropertyString('af',
            'scaletempo:scale=${(state.rate / state.pitch).toStringAsFixed(8)}');
      } else {
        // Pitch shift control is disabled.
        throw ArgumentError('[PlayerConfiguration.pitch] is false');
      }
    }

    if (synchronized) {
      return lock.synchronized(function);
    } else {
      return function();
    }
  }

  /// Enables or disables shuffle for [NativePlayer]. Default is `false`.
  @override
  Future<void> setShuffle(bool shuffle, {bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Sets the current [AudioDevice] for audio output.
  ///
  /// * Currently selected [AudioDevice] can be accessed using [state.audioDevice] or [stream.audioDevice].
  /// * The list of currently available [AudioDevice]s can be obtained accessed using [state.audioDevices] or [stream.audioDevices].
  @override
  Future<void> setAudioDevice(AudioDevice audioDevice,
      {bool synchronized = true}) {
    throw UnimplementedError();
  }

  /// Sets the current [VideoTrack] for video output.
  ///
  /// * Currently selected [VideoTrack] can be accessed using [state.track.video] or [stream.track.video].
  /// * The list of currently available [VideoTrack]s can be obtained accessed using [state.tracks.video] or [stream.tracks.video].
  @override
  Future<void> setVideoTrack(VideoTrack track, {bool synchronized = true}) {
    throw UnimplementedError();
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
  @override
  Future<void> setAudioTrack(AudioTrack track, {bool synchronized = true}) {
throw UnimplementedError();

  }



  /// Takes the snapshot of the current video frame & returns encoded image bytes as [Uint8List].
  ///
  /// The [format] parameter specifies the format of the image to be returned. Supported values are:
  /// * `image/jpeg`: Returns a JPEG encoded image.
  /// * `image/png`: Returns a PNG encoded image.
  /// * `null`: Returns BGRA pixel buffer.
  ///
  /// If [includeLibassSubtitles] is `true` *and* [PlayerConfiguration.libass] is `true`, then the
  /// screenshot will include the on-screen subtitles.
  @override
  Future<Uint8List?> screenshot(
      {String? format = 'image/jpeg',
      bool synchronized = true,
      bool includeLibassSubtitles = false}) async {
throw UnimplementedError();

  }

  /// Internal platform specific identifier for this [NativePlayer] instance.
  ///
  /// Since, [int] is a primitive type, it can be used to pass this [NativePlayer] instance to native code without directly depending upon this library.
  ///
  @override
  Future<int> get handle async {
    throw UnimplementedError();

  }

  /// Sets property for the internal libmpv instance of this [NativePlayer].
  /// Please use this method only if you know what you are doing, existing methods in [NativePlayer] implementation are suited for the most use cases.
  ///
  Future<void> setProperty(
    String property,
    String value, {
    bool waitForInitialization = true,
  }) async {
    throw UnimplementedError("probably not needed anymore");
  }

  /// Retrieves the value of a property from the internal libmpv instance of this [NativePlayer].
  /// Please use this method only if you know what you are doing, existing methods in [NativePlayer] implementation are suited for the most use cases.
  ///
  /// See:
  /// * https://mpv.io/manual/master/#options
  /// * https://mpv.io/manual/master/#properties
  ///
  Future<String> getProperty(
    String property, {
    bool waitForInitialization = true,
  }) async {
    throw UnimplementedError("probably not needed anymore");
  }

  /// Observes property for the internal libmpv instance of this [NativePlayer].
  /// Please use this method only if you know what you are doing, existing methods in [NativePlayer] implementation are suited for the most use cases.
  ///
  /// See:
  /// * https://mpv.io/manual/master/#options
  /// * https://mpv.io/manual/master/#properties
  ///
  Future<void> observeProperty(
    String property,
    Future<void> Function(String) listener, {
    bool waitForInitialization = true,
  }) async {
    throw UnimplementedError("probably not needed anymore");
  }

  /// Unobserves property for the internal libmpv instance of this [NativePlayer].
  /// Please use this method only if you know what you are doing, existing methods in [NativePlayer] implementation are suited for the most use cases.
  ///
  /// See:
  /// * https://mpv.io/manual/master/#options
  /// * https://mpv.io/manual/master/#properties
  ///
  Future<void> unobserveProperty(
    String property, {
    bool waitForInitialization = true,
  }) async {
    throw UnimplementedError("probably not needed anymore");

  }

  /// Invokes command for the internal libmpv instance of this [NativePlayer].
  /// Please use this method only if you know what you are doing, existing methods in [NativePlayer] implementation are suited for the most use cases.
  ///
  /// See:
  /// * https://mpv.io/manual/master/#list-of-input-commands
  ///
  Future<void> command(
    List<String> command, {
    bool waitForInitialization = true,
  }) async {
    throw UnimplementedError("probably not needed anymore");

  }

  Future<void> _setProperty(String name, int format, Pointer<Void> data) async {
    throw UnimplementedError();
  }

  Future<void> _setPropertyFlag(String name, bool value) async {
    throw UnimplementedError();
  }

  Future<void> _setPropertyDouble(String name, double value) async {
    throw UnimplementedError();
  }

  Future<void> _setPropertyInt64(String name, int value) async {
    throw UnimplementedError();
  }

  Future<void> _setPropertyString(String name, String value) async {
    throw UnimplementedError();
  }

  /// The [Future] to wait for [_create] completion.
  /// This is used to prevent signaling [completer] (from [IPlatformPlayer]) before [_create] completes in any hypothetical situation (because `idle-active` may fire before it).
  Future<void>? future;

  /// Whether the [NativePlayer] has been disposed. This is used to prevent accessing dangling [ctx] after [dispose].
  bool disposed = false;

  /// A flag to keep track of [setShuffle] calls.
  bool isShuffleEnabled = false;

  /// A flag to prevent changes to [state.playing] due to `loadfile` commands in [open].
  ///
  /// By default, `MPV_EVENT_START_FILE` is fired when a new media source is loaded.
  /// This event modifies the [state.playing] & [stream.playing] to `true`.
  ///
  /// However, the [NativePlayer] is in paused state before the media source is loaded.
  /// Thus, [state.playing] should not be changed, unless the user explicitly calls [play] or [playOrPause].
  ///
  /// We set [isPlayingStateChangeAllowed] to `false` at the start of [open] to prevent this unwanted change & set it to `true` at the end of [open].
  /// While [isPlayingStateChangeAllowed] is `false`, any change to [state.playing] & [stream.playing] is ignored.
  bool isPlayingStateChangeAllowed = false;

  /// A flag to prevent changes to [state.buffering] due to `pause` causing `core-idle` to be `true`.
  ///
  /// This is used to prevent [state.buffering] being set to `true` when [pause] or [playOrPause] is called.
  bool isBufferingStateChangeAllowed = true;

  /// Current loaded [NativePlayable] queue.
  List<NativePlayable> current = <NativePlayable>[];

  /// Currently observed properties through [observeProperty].
  final HashMap<String, Future<void> Function(String)> observed =
      HashMap<String, Future<void> Function(String)>();

  /// The methods which must execute synchronously before playback of a source can begin.
  final List<Future<void> Function()> onLoadHooks = [];

  /// The methods which must execute synchronously before playback of a source can end.
  final List<Future<void> Function()> onUnloadHooks = [];

  /// Synchronization & mutual exclusion between methods of this class.
  static final Lock lock = Lock();

  /// [HashMap] for retrieving previously fetched audio-bitrate(s).
  static final HashMap<String, double> audioBitrateCache =
      HashMap<String, double>();

  /// Whether the [NativePlayer] is initialized for unit-testing.
  @visibleForTesting
  static bool test = false;
}
