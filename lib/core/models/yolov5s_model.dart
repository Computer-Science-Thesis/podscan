import 'dart:io';
import 'package:podscan/core/models/base_model.dart';

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

    int bestBoxIndex = -1;
    int bestClassIndex = -1;
    double bestConfidence = -1.0;

    List<List<double>> predictions = baseOutput![0];
    for (int i = 0; i < predictions.length; i++) {
      final double confidence = predictions[i][4];
      final List<double> classProbabilities = predictions[i].sublist(5);

      double maxClassConfidence = -1.0;
      int classIndex = -1;
      for (int i = 0; i < classProbabilities.length; i++) {
        if (classProbabilities[i] > maxClassConfidence) {
          maxClassConfidence = classProbabilities[i];
          classIndex = i;
        }
      }

      if (confidence <= confidenceThreshold || maxClassConfidence <= nmsIouThreshold) continue;

      final double finalConfidence = confidence * maxClassConfidence;

      if (finalConfidence > bestConfidence) {
        bestBoxIndex = i;
        bestClassIndex = classIndex;
        bestConfidence = finalConfidence;
      }
      
    }

    if (bestConfidence == -1.0) {
      _normalizedBboxMinmax = null;
      _detectedObjectConfidence = null;
      _detectedObjectIndex = null;
      return;
    }

    final double normalizedXMin = predictions[bestBoxIndex][0] - predictions[bestBoxIndex][2] / 2;
    final double normalizedYMin = predictions[bestBoxIndex][1] - predictions[bestBoxIndex][3] / 2;
    final double normalizedXMax = predictions[bestBoxIndex][0] + predictions[bestBoxIndex][2] / 2;
    final double normalizedYMax = predictions[bestBoxIndex][1] + predictions[bestBoxIndex][3] / 2;

    _normalizedBboxMinmax = [normalizedXMin, normalizedYMin, normalizedXMax, normalizedYMax];
    _detectedObjectConfidence = bestConfidence;
    _detectedObjectIndex = bestClassIndex.toInt();
  }

  @override
  void dispose() {
    _normalizedBboxMinmax = null;
    _detectedObjectConfidence = null;
    _detectedObjectIndex = null;
    super.dispose();
  }
}