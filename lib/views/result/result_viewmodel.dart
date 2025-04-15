import 'dart:io';
import 'package:flutter/material.dart';
import 'package:podscan/core/services/label_service.dart';

class ResultViewModel with ChangeNotifier {
  late File _imageFile;
  late Map<String, double> _diseaseMap;
  late Map<String, String> _pestMap;
  late Map<String, double> _varietyMap;
  late double _diseasePercentage;
  bool _isExpanded = false;

  File get imageFile => _imageFile;
  String get topVariety => _varietyMap.entries.first.key;
  String get topVarietyNSICNumber => LabelService().getNSICNumber(topVariety);
  List<String> get possibleVarietiesWithConfidences => _varietyMap.entries.map((entry) => "${entry.key}: ${(entry.value * 100).round()}%").toList();
  String get cacaoDescription => LabelService().getCacaoDescription(topVariety);
  String get topDisease => _diseaseMap.entries.first.key;
  String get topPest => _pestMap.entries.first.value;
  String get severityLevel => "${(_diseasePercentage * 100).round()}%";
  String get recommendation => LabelService().getDiseaseRecommendation(topVariety == "Healthy");
  bool get isExpanded => _isExpanded;

  ResultViewModel({required Map<String, dynamic> analysisOutput}) {
    _imageFile = analysisOutput["analyzedImageFile"];
    _diseaseMap = analysisOutput["diseaseMap"];
    _pestMap = analysisOutput["pestMap"];
    _varietyMap = analysisOutput["varietyMap"];
    _diseasePercentage = analysisOutput["diseasePercentage"];
  }

  void toggleExpand() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void goBack(BuildContext context) {
    debugPrint("Going Back...");
    Navigator.of(context).pop();
  }
}