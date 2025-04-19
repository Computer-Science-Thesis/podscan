import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'base_model.dart';

class YoloV5sModel extends BaseModel {
  // [normMinX, normMinY, normMaxX, normMaxY]
  List<double>? _normalizedBboxMinmax;
  double? _detectedObjectConfidence;
  int? _detectedObjectIndex;

  bool get hasOutput => _normalizedBboxMinmax != null && _detectedObjectConfidence != null && _detectedObjectIndex != null;
  List<double>? get normalizedBboxMinmax => _normalizedBboxMinmax;
  double? get detectedObjectConfidence => _detectedObjectConfidence;
  int? get detectedObjectIndex => _detectedObjectIndex;

  @override
  Future<void> runInference({
    required File imageFile,
    double confidenceThreshold = 0.5,
    double nmsIouThreshold = 0.5
  }) async {
    await super.runInference(imageFile: imageFile);
    if (!hasBaseOutput) {
      _normalizedBboxMinmax = null;
      _detectedObjectConfidence = null;
      _detectedObjectIndex = null;
      return;
    }

    List<List<double>> allBoxes = [];

    for (List<double> prediction in baseOutput![0]) {
      final double normalizedXCenter = prediction[0];
      final double normalizedYCenter = prediction[1];
      final double normalizedWidth = prediction[2];
      final double normalizedHeight = prediction[3];
      final double confidence = prediction[4];
      final List<double> classProbabilities = prediction.sublist(5);

      final int classIndex = classProbabilities.indexOf(
        classProbabilities.reduce((a, b) => a > b ? a : b)
      );
      final double classConfidence = classProbabilities[classIndex];

      if (confidence <= confidenceThreshold || classConfidence <= nmsIouThreshold) continue;

      final double normalizedXMin = normalizedXCenter - normalizedWidth / 2;
      final double normalizedYMin = normalizedYCenter - normalizedHeight / 2;
      final double normalizedXMax = normalizedXCenter + normalizedWidth / 2;
      final double normalizedYMax = normalizedYCenter + normalizedHeight / 2;
      
      allBoxes.add([
        normalizedXMin, normalizedYMin, normalizedXMax, normalizedYMax,
        confidence * classConfidence,
        classIndex.toDouble(),
      ]);
    }

    if (allBoxes.isEmpty) {
      _normalizedBboxMinmax = null;
      _detectedObjectConfidence = null;
      _detectedObjectIndex = null;
      return;
    }

    List<double> output = allBoxes.reduce((a, b) => a[4] > b[4] ? a : b);
    _normalizedBboxMinmax = output.sublist(0, 4);
    _detectedObjectConfidence = output[4];
    _detectedObjectIndex = output[5].toInt();
  }

  Future<File> drawBoundingBoxes(File imageFile) async {
    if (!hasOutput) return imageFile;

    final Uint8List imageBytes = imageFile.readAsBytesSync();
    final img.Image decodedImage = img.decodeImage(imageBytes)!;

    final List<double> bbox = normalizedBboxMinmax!;
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
}