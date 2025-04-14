import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabelService {
  static final LabelService _instance = LabelService._internal();

  late List<String> _varietyLabels;
  late List<String> _diseaseLabels;
  late List<String> _objectLabels;
  late Map<String, String> _pestLabels;

  factory LabelService() {
    return _instance;
  }

  LabelService._internal();

  Future<void> loadAllLabels() async {
    _diseaseLabels = await _loadLabel("assets/labels/disease_label.txt");
    _objectLabels = await _loadLabel("assets/labels/object_label.txt");
    _pestLabels = await _loadPestLabel("assets/labels/pest_label.txt");
    _varietyLabels = await _loadLabel("assets/labels/variety_label.txt");
  }

  Future<List<String>> _loadLabel(String labelPath) async {
    String labelsData = await rootBundle.loadString(labelPath);
    debugPrint("Label is Loaded: '$labelPath'");
    return labelsData
      .split("\n")
      .map((label) => label.trim())
      .where((label) => label.isNotEmpty)
      .toList();
  }

  Future<Map<String, String>> _loadPestLabel(String labelPath) async {
    List<String> keyValuePairs = await _loadLabel(labelPath);

    Map<String, String> diseaseToPestMap = {};
    for (String entry in keyValuePairs) {
      List<String> parts = entry.split(":");
      if (parts.length != 2) continue;
      final String key = parts[0].trim();
      final String value = parts[1].trim();
      diseaseToPestMap[key] = value;
    }
    return diseaseToPestMap;
  }

  String? _getLabel(int index, List<String> labels) {
    return (index < 0 || index >= labels.length) ? null : labels[index];
  }

  String getDiseaseLabel(int index) {
    return _getLabel(index, _diseaseLabels) ?? "unknown disease";
  }

  String getObjectLabel(int index) {
    return _getLabel(index, _objectLabels) ?? "unknown object";
  }

  String getPestLabel(String diseaseLabel) {
    return _pestLabels[diseaseLabel] ?? "unknown pest";
  }

  String getVarietyLabel(int index) {
    return _getLabel(index, _varietyLabels) ?? "unknown variety";
  }
}