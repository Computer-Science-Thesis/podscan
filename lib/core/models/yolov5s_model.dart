import 'dart:io';
import 'dart:math';
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

  Future<void> runInference({
    required File imageFile,
    double confidenceThreshold = 0.5,
    double nmsIouThreshold = 0.5
  }) async {
    await runBaseInference(imageFile);
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

    final List<List<double>> filteredBoxes = _nonMaxSuppression(allBoxes, nmsIouThreshold);

    if (filteredBoxes.isEmpty) {
      _normalizedBboxMinmax = null;
      _detectedObjectConfidence = null;
      _detectedObjectIndex = null;
      return;
    }

    List<double> output = filteredBoxes.reduce((a, b) => a[4] > b[4] ? a : b);
    _normalizedBboxMinmax = output.sublist(0, 4);
    _detectedObjectConfidence = output[4];
    _detectedObjectIndex = output[5].toInt();
  }

  List<List<double>> _nonMaxSuppression(List<List<double>> normalizedBboxMinmax, double iouThreshold) {
    List<List<double>> selectedBoxes = [];
  
    // Sort boxes by confidence score
    normalizedBboxMinmax.sort((a, b) => b[4].compareTo(a[4]));

    while (normalizedBboxMinmax.isNotEmpty) {
      final currentBox = normalizedBboxMinmax.removeAt(0);
      selectedBoxes.add(currentBox);

      List<List<double>> remainingBoxes = [];

      for (List<double> box in normalizedBboxMinmax) {
        double iou = _calculateIoU(currentBox, box);
        if (iou <= iouThreshold) {
          remainingBoxes.add(box);
        }
      }
      normalizedBboxMinmax = remainingBoxes;
    }

    return selectedBoxes;
  }

  double _calculateIoU(List<double> normalizedBboxMinmaxA, List<double> normalizedBboxMinmaxB) {
    // Unpack the bounding box coordinates
    double xMinA = normalizedBboxMinmaxA[0];
    double yMinA = normalizedBboxMinmaxA[1];
    double xMaxA = normalizedBboxMinmaxA[2];
    double yMaxA = normalizedBboxMinmaxA[3];

    double xMinB = normalizedBboxMinmaxB[0];
    double yMinB = normalizedBboxMinmaxB[1];
    double xMaxB = normalizedBboxMinmaxB[2];
    double yMaxB = normalizedBboxMinmaxB[3];

    // Calculate the area of both boxes
    double areaA = (xMaxA - xMinA) * (yMaxA - yMinA);
    double areaB = (xMaxB - xMinB) * (yMaxB - yMinB);

    // Calculate the coordinates of the intersection rectangle
    double interXMin = max(xMinA, xMinB);
    double interYMin = max(xMinA, xMinB);
    double interXMax = min(xMaxA, xMaxB);
    double interYMax = min(xMaxA, xMaxB);

    // Calculate the area of the intersection rectangle
    double interArea = max(0, interXMax - interXMin) * max(0, interYMax - interYMin);

    // Calculate the IoU
    double iou = interArea / (areaA + areaB - interArea);
    return iou;
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