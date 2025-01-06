/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.

import 'package:flutter_gstreamer/dtos/audio_device.dart';
import 'package:flutter_gstreamer/dtos/audio_params.dart';
import 'package:flutter_gstreamer/dtos/player_log.dart';
import 'package:flutter_gstreamer/dtos/track.dart';
import 'package:flutter_gstreamer/dtos/video_params.dart';


/// {@template player_stream}
///
/// PlayerStream
/// ------------
///
/// Event [Stream]s for subscribing to [Player] events.
///
/// {@endtemplate}
class PlayerStream {

  /// Whether playing or not.
  final Stream<bool> playing;

  /// Whether end of currently playing [Media] has been reached.
  final Stream<bool> completed;

  /// Current playback position.
  final Stream<Duration> position;

  /// Current playback duration.
  final Stream<Duration> duration;

  /// Current volume.
  final Stream<double> volume;

  /// Current playback rate.
  final Stream<double> rate;

  /// Current pitch.
  final Stream<double> pitch;

  /// Whether buffering or not.
  final Stream<bool> buffering;

  /// Current buffer position.
  /// This indicates how much of the stream has been decoded & cached by the demuxer.
  final Stream<Duration> buffer;

  /// Current buffering percentage
  final Stream<double> bufferingPercentage;


  /// Audio parameters of the currently playing [Media].
  /// e.g. sample rate, channels, etc.
  final Stream<AudioParams> audioParams;

  /// Video parameters of the currently playing [Media].
  /// e.g. width, height, rotation etc.
  final Stream<VideoParams> videoParams;

  /// Audio bitrate of the currently playing [Media].
  final Stream<double?> audioBitrate;

  /// Currently selected [AudioDevice]s.
  final Stream<AudioDevice> audioDevice;

  /// Currently available [AudioDevice]s.
  final Stream<List<AudioDevice>> audioDevices;

  /// Currently selected video, audio and subtitle track.
  final Stream<Track> track;

  /// Currently available video, audio and subtitle tracks.
  final Stream<Tracks> tracks;

  /// Currently playing video's width.
  final Stream<int?> width;

  /// Currently playing video's height.
  final Stream<int?> height;

  /// Currently displayed subtitle.
  final Stream<List<String>> subtitle;

  /// [Stream] emitting internal logs.
  final Stream<PlayerLog> log;

  /// [Stream] emitting error messages. This may be used to handle & display errors to the user.
  final Stream<String> error;

  /// {@macro player_stream}
  const PlayerStream({
    required this.playing,
    required this.completed,
    required this.position,
    required this.duration,
    required this.volume,
    required this.rate,
    required this.pitch,
    required this.buffering,
    required this.bufferingPercentage,
    required this.buffer,
    required this.audioParams,
    required this.videoParams,
    required this.audioBitrate,
    required this.audioDevice,
    required this.audioDevices,
    required this.track,
    required this.tracks,
    required this.width,
    required this.height,
    required this.subtitle,
    required this.log,
    required this.error,
  });
}
