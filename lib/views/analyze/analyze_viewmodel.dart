import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:podscan/core/isolates/resnet50_isolation.dart';
import 'package:podscan/core/isolates/unet_isolation.dart';
import 'package:podscan/core/models/unet_model.dart';
import 'package:podscan/core/services/label_service.dart';
import 'package:podscan/core/services/model_service.dart';
import 'package:podscan/views/home/home_view.dart';
import '../result/result_view.dart';

class AnalyzeViewModel with ChangeNotifier {
  late File _croppedImageFile;
  late File _drawnImageFile;
  late String _detectedObject;
  late double _confidenceScore;
  bool isAnalyzing = false;

  File get drawnImageFile => _drawnImageFile;
  String get detectedObject => _detectedObject;
  double get confidenceScore => _confidenceScore;

  AnalyzeViewModel({required detectionOutput}) {
    _croppedImageFile = detectionOutput["croppedImageFile"];
    _drawnImageFile = detectionOutput["detectedImageFile"];
    
    Map<String, double> detectedObjectMap = detectionOutput["detectedObjectMap"];
    _detectedObject = detectedObjectMap.entries.first.key;
    _confidenceScore = detectedObjectMap.entries.first.value;

    debugPrint(_croppedImageFile.path);
    debugPrint(_drawnImageFile.path);
    debugPrint(_detectedObject);
    debugPrint(_confidenceScore.toStringAsFixed(2));
  }


  Future<void> analyzeWithIsolate(BuildContext context) async {
    isAnalyzing = true;
    notifyListeners();

    final Map<String, dynamic> varietyOutput = await runResNet50InferenceInIsolate(ModelType.variety, _croppedImageFile.path, RootIsolateToken.instance!);
    final Map<String, dynamic> diseaseOutput = await runResNet50InferenceInIsolate(ModelType.disease, _croppedImageFile.path, RootIsolateToken.instance!);
    final Map<String, dynamic> diseaseMaskOutput = await unetInferenceInIsolate(ModelType.diseaseMask, _croppedImageFile.path, RootIsolateToken.instance!);
    final Map<String, dynamic> podMaskOutput = await unetInferenceInIsolate(ModelType.podMask, _croppedImageFile.path, RootIsolateToken.instance!);

    isAnalyzing = false;
    notifyListeners();

    if (context.mounted) {
      Map<int, double> diseaseIndexMap = diseaseOutput['classIndexToConfidenceMap'];
      Map<int, double> varietyIndexMap = varietyOutput['classIndexToConfidenceMap'];
      final List<List<double>> diseaseMask = diseaseMaskOutput['normalizedPixelValues'];
      final List<List<double>> podMask = podMaskOutput['normalizedPixelValues'];
      double diseasePercentage = 0;

      Map<String, double> diseaseMap = _convertMapping(diseaseIndexMap, LabelService().getDiseaseLabel);
      diseaseMap = _sortMapping(diseaseMap);
      Map<String, double> varietyMap =  _convertMapping(varietyIndexMap, LabelService().getVarietyLabel);
      varietyMap = _sortMapping(varietyMap);
      Map<String, String> pestMap = _extractPest(diseaseMap.keys.toList());
      diseasePercentage = UNetModel.podDiseaseIntersectionRatio(targetMask: diseaseMask, referenceMask: podMask);
      debugPrint(diseaseMap.toString());
      debugPrint(varietyMap.toString());
      debugPrint(diseasePercentage.toStringAsFixed(2));

      goToResultView(context, {
        'analyzedImageFile': _drawnImageFile,
        'diseaseMap': diseaseMap,
        'pestMap': pestMap,
        'varietyMap': varietyMap,
        'diseasePercentage': diseasePercentage,
      });
    }
  }

  Map<String, double> _convertMapping(Map<int, double> fromMap, String Function(int) getLabel) {
    return fromMap.map((key, value) {
      String label = getLabel(key);
      return MapEntry(label, value);
    });
  }

  Map<String, double> _sortMapping(Map<String, double> map) {
    var sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map<String, double>.fromEntries(sortedEntries);
  }

  Map<String, String> _extractPest(List<String> diseaseLabels) {
    Map<String, String> map = {};
    for (String diseaseLabel in diseaseLabels) {
      map[diseaseLabel] = LabelService().getPestLabel(diseaseLabel);
    }
    return map;
  }

  void goBack(BuildContext context) {
    debugPrint("Going Back...");
    Navigator.of(context).pop();
  }

  void goToResultView(BuildContext context, Map<String, dynamic> output) {
    debugPrint("Going to Result View...");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultView(analysisOutput: output)),// ResultView(analysisOutput: output))
    );
  }

}