import 'dart:io';
import 'dart:ui' as ui show Codec;

import 'package:drawable/drawable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Loads the given Android Drawable identified by [name] as an image,
/// associating it with the given scale.
class DrawableImage extends ImageProvider<DrawableImage> {
  const DrawableImage(
    this.name, {
    this.scale = 1.0,
    this.androidDrawable = const AndroidDrawable(),
  });

  /// Useful for testing. Should not be set by user.
  final AndroidDrawable androidDrawable;

  /// The Drawable resource id. E.g. the "foo" in "R.drawable.foo"
  final String name;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<DrawableImage> obtainKey(ImageConfiguration configuration) {
    return Future<DrawableImage>.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
      DrawableImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.name,
      informationCollector: () sync* {
        yield ErrorDescription('Resource: $name');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      DrawableImage key, ImageDecoderCallback decode) async {
    assert(key == this);

    BitmapDrawable? drawable;

    if (Platform.isAndroid) {
      drawable = await androidDrawable.loadBitmap(name: name);
    } else if (Platform.isIOS) {}
    if (drawable == null) {
      throw StateError(
        '$name does not exist and cannot be loaded as an image.',
      );
    }
    final bytes = drawable.content;

    return decode.call(await ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DrawableImage && other.name == name && other.scale == scale;
  }

  @override
  int get hashCode =>
      super.hashCode +
      androidDrawable.hashCode +
      name.hashCode +
      scale.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'DrawableImage')}("$name", scale: $scale)';
}
