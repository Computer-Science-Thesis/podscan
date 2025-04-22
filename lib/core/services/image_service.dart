import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  Future<File> drawBoundingBoxes(File imageFile, List<double>? normalizedBboxMinmax) async {
    if (normalizedBboxMinmax == null) return imageFile;

    final Uint8List imageBytes = imageFile.readAsBytesSync();
    final img.Image decodedImage = img.decodeImage(imageBytes)!;

    final List<double> bbox = normalizedBboxMinmax;
    final int xmin = (bbox[0] * decodedImage.width).toInt();
    final int ymin = (bbox[1] * decodedImage.height).toInt();
    final int xmax = (bbox[2] * decodedImage.width).toInt();
    final int ymax = (bbox[3] * decodedImage.height).toInt();

    img.drawRect(
      decodedImage,
      x1: xmin, y1: ymin, x2: xmax, y2: ymax,
      color: img.ColorUint8.rgb(255, 0, 0), thickness: 5,
    );

    // Save in a temporary directory
    final Directory tempDir = await getTemporaryDirectory();
    final String drawnImagePath = '${tempDir.path}/drawn_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final File drawnImageFile = File(drawnImagePath);
    await drawnImageFile.writeAsBytes(img.encodeJpg(decodedImage));

    return drawnImageFile;
  }

  Future<File> cropImage(File imageFile, List<double>? normalizedBboxMinmax) async {
    if (normalizedBboxMinmax == null) return imageFile;

    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image decodedImage = img.decodeImage(imageBytes)!;

    final List<double> bb = normalizedBboxMinmax;
    final int x = (bb[0] * decodedImage.width).toInt().clamp(0, decodedImage.width - 1);
    final int y = (bb[1] * decodedImage.height).toInt().clamp(0, decodedImage.height - 1);
    final int width = ((bb[2] - bb[0]) * decodedImage.width).toInt().clamp(1, decodedImage.width - x);
    final int height = ((bb[3] - bb[1]) * decodedImage.height).toInt().clamp(1, decodedImage.height - y);

    final img.Image croppedImage = img.copyCrop(decodedImage, x: x, y: y, width: width, height: height);

    final Directory temporaryDirectory = await getTemporaryDirectory();
    final String croppedImagePath = "${temporaryDirectory.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final File croppedImageFile = File(croppedImagePath);
    await croppedImageFile.writeAsBytes(img.encodeJpg(croppedImage));

    return croppedImageFile;
  }
}