import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  Future<File?> drawBoundingBoxes(Uint8List imageBytes, List<double>? normalizedBboxMinmax) async {
    if (normalizedBboxMinmax == null) return null;

    final Map<String, dynamic> args = {
      'imageBytes': imageBytes,
      'bbox': normalizedBboxMinmax,
    };

    final Uint8List drawnImageEncodedBytes = await compute(_drawBoundingBoxesIsolate, args);
    return saveEncodedJpgTemporary(drawnImageEncodedBytes, "drawn");
  }

  Uint8List _drawBoundingBoxesIsolate(Map<String, dynamic> args) {
    final img.Image decodedImage = img.decodeImage(args['imageBytes'])!;

    final List<double> bbox = args['bbox'];
    final int xmin = (bbox[0] * decodedImage.width).toInt();
    final int ymin = (bbox[1] * decodedImage.height).toInt();
    final int xmax = (bbox[2] * decodedImage.width).toInt();
    final int ymax = (bbox[3] * decodedImage.height).toInt();

    img.drawRect(
      decodedImage,
      x1: xmin, y1: ymin, x2: xmax, y2: ymax,
      color: img.ColorUint8.rgb(255, 0, 0), thickness: 5,
    );

    return Uint8List.fromList(img.encodeJpg(decodedImage));
  }

  Future<File?> cropImage(Uint8List imageBytes, List<double>? normalizedBboxMinmax) async {
    if (normalizedBboxMinmax == null) return null;

    final Map<String, dynamic> args = {
      'imageBytes': imageBytes,
      'bbox': normalizedBboxMinmax,
    };

    final Uint8List croppedImageEncodedBytes = await compute(_cropImageIsolate, args);
    return saveEncodedJpgTemporary(croppedImageEncodedBytes, "cropped");
  }

  Uint8List _cropImageIsolate(Map<String, dynamic> args) {
    final img.Image decodedImage = img.decodeImage(args['imageBytes'])!;

    final List<double> bb = args['bbox'];
    final int x = (bb[0] * decodedImage.width).toInt().clamp(0, decodedImage.width - 1);
    final int y = (bb[1] * decodedImage.height).toInt().clamp(0, decodedImage.height - 1);
    final int width = ((bb[2] - bb[0]) * decodedImage.width).toInt().clamp(1, decodedImage.width - x);
    final int height = ((bb[3] - bb[1]) * decodedImage.height).toInt().clamp(1, decodedImage.height - y);

    final img.Image croppedImage = img.copyCrop(decodedImage, x: x, y: y, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(croppedImage));
  }

  Future<File?> generateImage(List<List<double>> normalizedPixelValues) async {
    List<List<double>> nPixVals = normalizedPixelValues;
    final height = nPixVals.length;
    final width = nPixVals[0].length;

    final img.Image image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int pixelValue = ((nPixVals[y][x] as num) * 255).clamp(0, 255).toInt();
        final img.ColorRgb8 pixelColor = img.ColorRgb8(pixelValue, pixelValue, pixelValue);
        image.setPixel(x, y, pixelColor);
      }
    }
    
    return saveEncodedJpgTemporary(img.encodeJpg(image), "mask");
  }

  Future<File> saveEncodedJpgTemporary(Uint8List encodedJpgImage, String prefix) async {
    final Directory temporaryDirectory = await getTemporaryDirectory();
    final String imagePath = "${temporaryDirectory.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final File imageFile = File(imagePath);
    await imageFile.writeAsBytes(encodedJpgImage);
    return imageFile;
  } 
}