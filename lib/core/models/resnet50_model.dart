import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:podscan/core/models/base_model.dart';

class ResNet50Model extends BaseModel {
  // [[class_index: conf, class_index: conf, ..., class_index: conf]]
  Map<int, double>? _classIndexToConfidenceMap;

  bool get hasOutput => _classIndexToConfidenceMap != null && _classIndexToConfidenceMap!.isNotEmpty;
  Map<int, double>? get classIndexToConfidenceMap => _classIndexToConfidenceMap;

  @override
  Future<void> runInference({required File imageFile}) async {
    await super.runInference(imageFile: imageFile);
    if (!hasBaseOutput) {
      _classIndexToConfidenceMap = null;
      return;
    }

    final List<double> prediction = baseOutput![0];

    Map<int, double> output = prediction.asMap().map((index, value) => MapEntry(index, value));
    var sortedEntries = output.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    _classIndexToConfidenceMap = Map.fromEntries(sortedEntries);
  }

  @override
  void dispose() {
    _classIndexToConfidenceMap = null;
    super.dispose();
  }
}