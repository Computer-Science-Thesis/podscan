import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'base_model.dart';

class ResNet50Model extends BaseModel {
  // [[class_index: conf, class_index: conf, ..., class_index: conf]]
  Map<int, double>? _classIndexToConfidenceMap;

  bool get hasOutput => _classIndexToConfidenceMap != null && _classIndexToConfidenceMap!.isNotEmpty;
  Map<int, double>? get classIndexToConfidenceMap => _classIndexToConfidenceMap;

  Future<void> runInference({required File imageFile}) async {
    await runBaseInference(imageFile);
    if (!hasBaseOutput) {
      _classIndexToConfidenceMap = null;
      return;
    }

    final List<double> prediction = baseOutput![0];

    Map<int, double> output = prediction.asMap().map((index, value) => MapEntry(index, value));
    var sortedEntries = output.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    _classIndexToConfidenceMap = Map.fromEntries(sortedEntries);
  }

  static Future<File> cropImage(File imageFile, List<double> normalizedBboxMinmax) async {
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

  @override
  void dispose() {
    _classIndexToConfidenceMap = null;
    super.dispose();
  }
}