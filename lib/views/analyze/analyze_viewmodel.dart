import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:podscan/core/isolates/resnet50_isolation.dart';
import 'package:podscan/core/isolates/unet_isolation.dart';
import 'package:podscan/core/models/unet_model.dart';
import 'package:podscan/core/services/label_service.dart';
import 'package:podscan/core/services/model_service.dart';
import 'package:podscan/views/result/result_view.dart';

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
    final stopWatch = Stopwatch()..start();

    isAnalyzing = true;
    notifyListeners();

    Map<String, double> varietyMap = {"none": 0.0};
    Map<String, double> diseaseMap = {"none": 0.0};
    Map<String, String> pestMap = {"none": "none"};
    List<List<double>>? diseaseMask;
    List<List<double>>? podMask;
    double diseasePercentage = 0.0;

    // Start classification inference tasks in parallel
    final List<Map<String, dynamic>> firstFutures = await Future.wait([
      runResNet50InferenceInIsolate(ModelType.variety, _croppedImageFile.path, RootIsolateToken.instance!),
      runUNetInferenceInIsolate(ModelType.podMask, _croppedImageFile.path, RootIsolateToken.instance!)
    ]);

    final Map<String, dynamic> varietyOutput = firstFutures[0];
    final Map<String, dynamic> podMaskOutput = firstFutures[1];

    if (varietyOutput.containsKey('error')) {
      debugPrint('Isolate error: ${varietyOutput['error']}');
    } else {
      debugPrint('Variety classification inference time: ${varietyOutput["elapsedMilliseconds"]}ms');
      if (varietyOutput['classIndexToConfidenceMap'] != null) {
        Map<int, double> varietyIndexMap = varietyOutput['classIndexToConfidenceMap'];
        varietyMap =  _convertMapping(varietyIndexMap, LabelService().getVarietyLabel);
        varietyMap = _sortMapping(varietyMap);
      }
    }

    if (podMaskOutput.containsKey('error')) {
      debugPrint('Isolate error: ${podMaskOutput['error']}');
    } else {
      debugPrint('Pod segmentation inference time: ${podMaskOutput["elapsedMilliseconds"]}ms');
      if (podMaskOutput['normalizedPixelValues'] != null) {
        podMask = podMaskOutput['normalizedPixelValues'] as List<List<double>>;
      }
    }

      // Start segmentation inference tasks in parallel
      final List<Map<String, dynamic>> secondFutures = await Future.wait([
        runResNet50InferenceInIsolate(ModelType.disease, _croppedImageFile.path, RootIsolateToken.instance!),
        runUNetInferenceInIsolate(ModelType.diseaseMask, _croppedImageFile.path, RootIsolateToken.instance!)
      ]);

    final Map<String, dynamic> diseaseOutput = secondFutures[0];
    final Map<String, dynamic> diseaseMaskOutput = secondFutures[1];

    if (diseaseOutput.containsKey('error')) {
      debugPrint('Isolate error: ${diseaseOutput['error']}');
    } else {
      debugPrint('Disease classification inference time: ${diseaseOutput["elapsedMilliseconds"]}ms');
      if (diseaseOutput['classIndexToConfidenceMap'] != null) {
        Map<int, double> diseaseIndexMap = diseaseOutput['classIndexToConfidenceMap'];
        diseaseMap = _convertMapping(diseaseIndexMap, LabelService().getDiseaseLabel);
        diseaseMap = _sortMapping(diseaseMap);
        pestMap = _extractPest(diseaseMap.keys.toList());
      }
    }

    if (diseaseMaskOutput.containsKey('error')) {
      debugPrint('Isolate error: ${diseaseMaskOutput['error']}');
    } else {
      debugPrint('Disease segmentation inference time: ${diseaseMaskOutput["elapsedMilliseconds"]}ms');
      if (diseaseMaskOutput['normalizedPixelValues'] != null) {
        diseaseMask = diseaseMaskOutput['normalizedPixelValues'] as List<List<double>>;
      }
    }
    
    diseasePercentage = UNetModel.podDiseaseIntersectionRatio(
      targetMask: diseaseMask,
      referenceMask: podMask
    );

    stopWatch.stop();

    debugPrint('Total analysis process time: ${stopWatch.elapsedMilliseconds}ms');
    
    isAnalyzing = false;
    notifyListeners();

    if (context.mounted) {
      
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