import 'package:flutter_gstreamer/dtos/audio_device.dart';
import 'package:flutter_gstreamer/dtos/audio_params.dart';
import 'package:flutter_gstreamer/dtos/playable.dart';
import 'package:flutter_gstreamer/dtos/track.dart';
import 'package:flutter_gstreamer/dtos/video_params.dart';

/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.

/// {@template player_state}
///
/// PlayerState
/// -----------
///
/// Instantaneous state of the [NativePlayer].
///
/// {@endtemplate}
class PlayerState {
  /// Currently opened [Playable].
  final Playable? playable;

  /// Whether playing or not.
  final bool playing;

  /// Whether end of currently playing [Media] has been reached.
  final bool completed;

  /// Current playback position.
  final Duration position;

  /// Current playback duration.
  final Duration duration;

  /// Current volume.
  final double volume;

  /// Current playback rate.
  final double rate;

  /// Current pitch.
  final double pitch;

  /// Whether buffering or not.
  final bool buffering;

  /// Current buffer position.
  /// This indicates how much of the stream has been decoded & cached by the demuxer.
  final Duration buffer;

  /// Current buffering percentage
  final double bufferingPercentage;

  /// Audio parameters of the currently playing [Media].
  /// e.g. sample rate, channels, etc.
  final AudioParams audioParams;

  /// Video parameters of the currently playing [Media].
  /// e.g. width, height, rotation, etc.
  final VideoParams videoParams;

  /// Audio bitrate of the currently playing [Media].
  final double? audioBitrate;

  /// Currently selected [AudioDevice].
  final AudioDevice audioDevice;

  /// Currently available [AudioDevice]s.
  final List<AudioDevice> audioDevices;

  /// Currently selected video, audio & subtitle track.
  final Track track;

  /// Currently available video, audio & subtitle tracks.
  final Tracks tracks;

  /// Currently playing video's width.
  final int? width;

  /// Currently playing video's height.
  final int? height;

  /// Currently displayed subtitle.
  final List<String> subtitle;

  /// {@macro player_state}
  const PlayerState({
    this.playable,
    this.playing = false,
    this.completed = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100.0,
    this.rate = 1.0,
    this.pitch = 1.0,
    this.buffering = false,
    this.buffer = Duration.zero,
    this.bufferingPercentage = 0.0,
    this.audioParams = const AudioParams(),
    this.videoParams = const VideoParams(),
    this.audioBitrate,
    this.audioDevice = const AudioDevice('auto', ''),
    this.audioDevices = const [AudioDevice('auto', '')],
    this.track = const Track(),
    this.tracks = const Tracks(),
    this.width,
    this.height,
    this.subtitle = const ['', ''],
  });

  PlayerState copyWith({
    Playable? playable,
    bool? playing,
    bool? completed,
    Duration? position,
    Duration? duration,
    double? volume,
    double? rate,
    double? pitch,
    bool? buffering,
    Duration? buffer,
    double? bufferingPercentage,
    AudioParams? audioParams,
    VideoParams? videoParams,
    double? audioBitrate,
    AudioDevice? audioDevice,
    List<AudioDevice>? audioDevices,
    Track? track,
    Tracks? tracks,
    int? width,
    int? height,
    List<String>? subtitle,
  }) {
    return PlayerState(
      playable: playable ?? this.playable,
      playing: playing ?? this.playing,
      completed: completed ?? this.completed,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      buffering: buffering ?? this.buffering,
      bufferingPercentage: bufferingPercentage ?? this.bufferingPercentage,
      buffer: buffer ?? this.buffer,
      audioParams: audioParams ?? this.audioParams,
      videoParams: videoParams ?? this.videoParams,
      audioBitrate: audioBitrate ?? this.audioBitrate,
      audioDevice: audioDevice ?? this.audioDevice,
      audioDevices: audioDevices ?? this.audioDevices,
      track: track ?? this.track,
      tracks: tracks ?? this.tracks,
      width: width ?? this.width,
      height: height ?? this.height,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  String toString() => 'NativePlayer('
      'playing: $playing, '
      'completed: $completed, '
      'position: $position, '
      'duration: $duration, '
      'volume: $volume, '
      'rate: $rate, '
      'pitch: $pitch, '
      'buffering: $buffering, '
      'bufferingPercentage: $bufferingPercentage, '
      'buffer: $buffer, '
      'audioParams: $audioParams, '
      'videoParams: $videoParams, '
      'audioBitrate: $audioBitrate, '
      'audioDevice: $audioDevice, '
      'audioDevices: $audioDevices, '
      'track: $track, '
      'tracks: $tracks, '
      'width: $width, '
      'height: $height, '
      'subtitle: $subtitle'
      ')';
}
