import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterNativeImage {
  static const MethodChannel _channel = MethodChannel('flutter_native_image');

  /// Compress an image
  ///
  /// Compresses the given [fileName].
  /// [percentage] controls by how much the image should be resized. (0-100)
  /// [quality] controls how strong the compression should be. (0-100)
  /// Use [targetWidth] and [targetHeight] to resize the image for a specific
  /// target size.
  static Future<File?>? compressImage(String fileName,
      {int? percentage = 70, int? quality = 70, int? targetWidth = 0, int? targetHeight = 0}) async {
    final file = await _channel.invokeMethod('compressImage', {
      'file': fileName,
      'quality': quality,
      'percentage': percentage,
      'targetWidth': targetWidth,
      'targetHeight': targetHeight
    });

    return File(file as String);
  }

  /// Gets the properties of an image
  ///
  /// Gets the properties of an image given the [fileName].
  static Future<ImageProperties?>? getImageProperties(String fileName) async {
    ImageOrientation decodeOrientation(int orientation) {
      // For details, see: https://developer.android.com/reference/android/media/ExifInterface
      switch (orientation) {
        case 1:
          return ImageOrientation.normal;
        case 2:
          return ImageOrientation.flipHorizontal;
        case 3:
          return ImageOrientation.rotate180;
        case 4:
          return ImageOrientation.flipVertical;
        case 5:
          return ImageOrientation.transpose;
        case 6:
          return ImageOrientation.rotate90;
        case 7:
          return ImageOrientation.transverse;
        case 8:
          return ImageOrientation.rotate270;
        default:
          return ImageOrientation.undefined;
      }
    }

    final Map properties =
        Map.from(await _channel.invokeMethod('getImageProperties', {'file': fileName}) as Map<dynamic, dynamic>);
    return ImageProperties(
        width: properties['width'] as int?,
        height: properties['height'] as int?,
        orientation: decodeOrientation(properties['orientation'] as int));
  }

  /// Crops an image
  ///
  /// Crops the given [fileName].
  /// [originX] and [originY] control from where the image should be cropped.
  /// [width] and [height] control how the image is being cropped.
  static Future<File?>? cropImage(String? fileName, int? originX, int? originY, int? width, int? height) async {
    final file = await _channel.invokeMethod(
        'cropImage', {'file': fileName, 'originX': originX, 'originY': originY, 'width': width, 'height': height});

    return File(file as String);
  }
}

/// Imageorientation enum used for [getImageProperties].
enum ImageOrientation {
  normal,
  rotate90,
  rotate180,
  rotate270,
  flipHorizontal,
  flipVertical,
  transpose,
  transverse,
  undefined,
}

/// Return value of [getImageProperties].
class ImageProperties {
  ImageProperties({this.width = 0, this.height = 0, this.orientation = ImageOrientation.undefined});

  int? width;
  int? height;
  ImageOrientation? orientation;
}
