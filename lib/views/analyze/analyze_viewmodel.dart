import 'dart:io';
import 'package:flutter/material.dart';
import 'package:podscan/core/models/resnet50_model.dart';
import 'package:podscan/core/models/unet_model.dart';
import 'package:podscan/core/services/label_service.dart';
import 'package:podscan/core/services/model_service.dart';
import '../result/result_view.dart';

class AnalyzeViewModel with ChangeNotifier {
  final ModelService _modelService = ModelService();
  late ResNet50Model _diseaseModel;
  late ResNet50Model _varietyModel;
  late UNetModel _diseaseMaskModel;
  late UNetModel _podMaskModel;

  bool _isAnalyzing = false;
  late File _croppedImageFile;
  late File _drawnImageFile;
  late String _detectedObject;
  late double _confidenceScore;

  bool get isAnalyzing => _isAnalyzing;
  File get drawnImageFile => _drawnImageFile;
  String get detectedObject => _detectedObject;
  double get confidenceScore => _confidenceScore;

  bool get modelsAreLoaded => _diseaseModel.isLoaded
                                  && _varietyModel.isLoaded
                                  && _diseaseMaskModel.isLoaded
                                  && _podMaskModel.isLoaded;

  AnalyzeViewModel({required detectionOutput}) {
    _croppedImageFile = detectionOutput["croppedImageFile"];
    _drawnImageFile = detectionOutput["detectedImageFile"];
    
    Map<String, double> detectedObjectMap = detectionOutput["detectedObjectMap"];
    _detectedObject = detectedObjectMap.entries.first.key;
    _confidenceScore = detectedObjectMap.entries.first.value;

    _loadModels();

    debugPrint(_croppedImageFile.path);
    debugPrint(_drawnImageFile.path);
    debugPrint(_detectedObject);
    debugPrint(_confidenceScore.toStringAsFixed(2));
  }

  Future<void> _loadModels() async {
    try {
      _diseaseModel = await _modelService.getModel(ModelType.disease) as ResNet50Model;
      _varietyModel = await _modelService.getModel(ModelType.variety) as ResNet50Model;
      _diseaseMaskModel = await _modelService.getModel(ModelType.diseaseMask) as UNetModel;
      _podMaskModel = await _modelService.getModel(ModelType.podMask) as UNetModel;
    } catch (e) {
      debugPrint("Error loading models: $e");
    }
  }

  void _unloadModels() {
    _modelService.unloadModel(ModelType.disease);
    _modelService.unloadModel(ModelType.variety);
    _modelService.unloadModel(ModelType.diseaseMask);
    _modelService.unloadModel(ModelType.podMask);
  }

  Future<void> analyze(BuildContext context) async {
    if (!modelsAreLoaded) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Models are not loaded. Please try again later."),
          duration: Duration(seconds: 3),
        ),
      );
      goBack(context);
      return;
    }

    _isAnalyzing = true;
    notifyListeners();

    final Map<String, dynamic> output = await _runInference();

    _isAnalyzing = false;
    notifyListeners();

    if (context.mounted) goToResultView(context, output);
  }

  Future<Map<String, dynamic>> _runInference() async {
    Map<String, double> diseaseMap = {"none": 0.0};
    Map<String, String> pestMap = {"none": "none"};
    Map<String, double> varietyMap = {"none": 0.0};
    double diseasePercentage = 0.0;

    await _diseaseModel.runInference(imageFile: _croppedImageFile);
    if (_diseaseModel.hasOutput) {
      diseaseMap = _convertMapping(_diseaseModel.classIndexToConfidenceMap!, LabelService().getDiseaseLabel);
      diseaseMap = _sortMapping(diseaseMap);
      pestMap = _extractPest(diseaseMap.keys.toList());
    }

    await _varietyModel.runInference(imageFile: _croppedImageFile);
    if (_varietyModel.hasOutput) {
      varietyMap = _convertMapping(_varietyModel.classIndexToConfidenceMap!, LabelService().getVarietyLabel);
      varietyMap = _sortMapping(varietyMap);
    }

    await _diseaseMaskModel.runInference(imageFile: _croppedImageFile);
    await _podMaskModel.runInference(imageFile: _croppedImageFile);
    if (_diseaseMaskModel.hasOutput && _podMaskModel.hasOutput) {
      List<List<double>> diseaseMask = _diseaseMaskModel.normalizedPixelValues!;
      List<List<double>> podMask = _podMaskModel.normalizedPixelValues!;
      diseasePercentage = UNetModel.podDiseaseIntersectionRatio(targetMask: diseaseMask, referenceMask: podMask);
    }

    return {
      "analyzedImageFile": _drawnImageFile,
      "diseaseMap": diseaseMap,
      "pestMap": pestMap,
      "varietyMap": varietyMap,
      "diseasePercentage": diseasePercentage,
    };
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
    _unloadModels();
    Navigator.of(context).pop();
  }

  void goToResultView(BuildContext context, Map<String, dynamic> output) {
    debugPrint("Going to Result View...");
    _unloadModels();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultView(analysisOutput: output))
    );
  }

}