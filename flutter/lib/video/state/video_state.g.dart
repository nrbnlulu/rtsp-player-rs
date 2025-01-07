// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoStateNotifierHash() =>
    r'494e3e438ff7c9459f1c8fbf63e4d535d6bf1dea';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$VideoStateNotifier
    extends BuildlessAutoDisposeNotifier<VideoState> {
  late final InvalidType config;

  VideoState build(
    InvalidType config,
  );
}

/// See also [VideoStateNotifier].
@ProviderFor(VideoStateNotifier)
const videoStateNotifierProvider = VideoStateNotifierFamily();

/// See also [VideoStateNotifier].
class VideoStateNotifierFamily extends Family<VideoState> {
  /// See also [VideoStateNotifier].
  const VideoStateNotifierFamily();

  /// See also [VideoStateNotifier].
  VideoStateNotifierProvider call(
    InvalidType config,
  ) {
    return VideoStateNotifierProvider(
      config,
    );
  }

  @override
  VideoStateNotifierProvider getProviderOverride(
    covariant VideoStateNotifierProvider provider,
  ) {
    return call(
      provider.config,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoStateNotifierProvider';
}

/// See also [VideoStateNotifier].
class VideoStateNotifierProvider
    extends AutoDisposeNotifierProviderImpl<VideoStateNotifier, VideoState> {
  /// See also [VideoStateNotifier].
  VideoStateNotifierProvider(
    InvalidType config,
  ) : this._internal(
          () => VideoStateNotifier()..config = config,
          from: videoStateNotifierProvider,
          name: r'videoStateNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoStateNotifierHash,
          dependencies: VideoStateNotifierFamily._dependencies,
          allTransitiveDependencies:
              VideoStateNotifierFamily._allTransitiveDependencies,
          config: config,
        );

  VideoStateNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.config,
  }) : super.internal();

  final InvalidType config;

  @override
  VideoState runNotifierBuild(
    covariant VideoStateNotifier notifier,
  ) {
    return notifier.build(
      config,
    );
  }

  @override
  Override overrideWith(VideoStateNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoStateNotifierProvider._internal(
        () => create()..config = config,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        config: config,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<VideoStateNotifier, VideoState>
      createElement() {
    return _VideoStateNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoStateNotifierProvider && other.config == config;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, config.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoStateNotifierRef on AutoDisposeNotifierProviderRef<VideoState> {
  /// The parameter `config` of this provider.
  InvalidType get config;
}

class _VideoStateNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<VideoStateNotifier, VideoState>
    with VideoStateNotifierRef {
  _VideoStateNotifierProviderElement(super.provider);

  @override
  InvalidType get config => (origin as VideoStateNotifierProvider).config;
}

String _$textureIdNotifierHash() => r'dbf56ef9310a0dd350cd936a1c014cae21bc21a4';

abstract class _$TextureIdNotifier extends BuildlessAutoDisposeNotifier<int?> {
  late final InvalidType config;

  int? build(
    InvalidType config,
  );
}

/// See also [TextureIdNotifier].
@ProviderFor(TextureIdNotifier)
const textureIdNotifierProvider = TextureIdNotifierFamily();

/// See also [TextureIdNotifier].
class TextureIdNotifierFamily extends Family<int?> {
  /// See also [TextureIdNotifier].
  const TextureIdNotifierFamily();

  /// See also [TextureIdNotifier].
  TextureIdNotifierProvider call(
    InvalidType config,
  ) {
    return TextureIdNotifierProvider(
      config,
    );
  }

  @override
  TextureIdNotifierProvider getProviderOverride(
    covariant TextureIdNotifierProvider provider,
  ) {
    return call(
      provider.config,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'textureIdNotifierProvider';
}

/// See also [TextureIdNotifier].
class TextureIdNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TextureIdNotifier, int?> {
  /// See also [TextureIdNotifier].
  TextureIdNotifierProvider(
    InvalidType config,
  ) : this._internal(
          () => TextureIdNotifier()..config = config,
          from: textureIdNotifierProvider,
          name: r'textureIdNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$textureIdNotifierHash,
          dependencies: TextureIdNotifierFamily._dependencies,
          allTransitiveDependencies:
              TextureIdNotifierFamily._allTransitiveDependencies,
          config: config,
        );

  TextureIdNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.config,
  }) : super.internal();

  final InvalidType config;

  @override
  int? runNotifierBuild(
    covariant TextureIdNotifier notifier,
  ) {
    return notifier.build(
      config,
    );
  }

  @override
  Override overrideWith(TextureIdNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TextureIdNotifierProvider._internal(
        () => create()..config = config,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        config: config,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TextureIdNotifier, int?> createElement() {
    return _TextureIdNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TextureIdNotifierProvider && other.config == config;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, config.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TextureIdNotifierRef on AutoDisposeNotifierProviderRef<int?> {
  /// The parameter `config` of this provider.
  InvalidType get config;
}

class _TextureIdNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TextureIdNotifier, int?>
    with TextureIdNotifierRef {
  _TextureIdNotifierProviderElement(super.provider);

  @override
  InvalidType get config => (origin as TextureIdNotifierProvider).config;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
