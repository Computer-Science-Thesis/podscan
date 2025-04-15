import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabelService {
  static final LabelService _instance = LabelService._internal();

  late List<String> _varietyLabels;
  late List<String> _diseaseLabels;
  late List<String> _objectLabels;
  late Map<String, String> _pestLabels;

  late Map<String, String> _cacaoDescriptions;
  late Map<String, String> _cacaoNSICNumbers;
  late Map<String, List<String>> _diseaseRecommendations;

  factory LabelService() {
    return _instance;
  }

  LabelService._internal();

  Future<void> loadAllLabels() async {
    _diseaseLabels = await _loadLabel("assets/labels/disease_label.txt");
    _objectLabels = await _loadLabel("assets/labels/object_label.txt");
    _pestLabels = await _loadPestLabel("assets/labels/pest_label.txt");
    _varietyLabels = await _loadLabel("assets/labels/variety_label.txt");
    _cacaoDescriptions = await _loadCacaoDescriptions("assets/labels/cacao_descriptions.txt");
    _cacaoNSICNumbers = {
      'BR25': 'NSIC 2000 Cc05',
      'PBC123': 'NSIC 2014 Cc 11',
      'UF18': 'NSIC 1997 Cc01'
    };
    _diseaseRecommendations = await _loadRecommendations(
      healthyPath: "assets/labels/recommendations_healthy.txt",
      infectedPath: "assets/labels/recommendations_infected.txt"
    );
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

  Future<Map<String, String>> _loadCacaoDescriptions(String labelPath) async {
    List<String> keyValuePairs = await _loadLabel(labelPath);

    Map<String, String> cacaoToDescriptionMap = {};
    for (String entry in keyValuePairs) {
      List<String> parts = entry.split(":");
      if (parts.length != 2) continue;
      final String key = parts[0].trim();
      final String value = parts[1].trim();
      cacaoToDescriptionMap[key] = value;
    }
    debugPrint(cacaoToDescriptionMap.toString());
    return cacaoToDescriptionMap;
  }

  Future<Map<String, List<String>>> _loadRecommendations({required String healthyPath, required String infectedPath}) async {
    List<String> healthyRecommendations = await _loadRecommendation(healthyPath);
    debugPrint("Recommendation is Loaded: '$healthyPath'");
    List<String> infectedRecommendations = await _loadRecommendation(infectedPath);
    debugPrint("Recommendation is Loaded: '$infectedPath'");

    debugPrint(healthyRecommendations.toString());
    return {
      'healthy': healthyRecommendations,
      'infected': infectedRecommendations
    };
  }

  Future<List<String>> _loadRecommendation(String recommendationPath) async {
    String recommendationsData = await rootBundle.loadString(recommendationPath);
    return recommendationsData
      .split("===")
      .map((recommendation) => recommendation.trim()).
      where((recommendation) => recommendation.isNotEmpty)
      .toList();
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

  String getCacaoDescription(String cacao) {
    return _cacaoDescriptions[cacao] ?? "unknown description";
  }

  String getNSICNumber(String cacao) {
    return _cacaoNSICNumbers[cacao] ?? "unknown NSIC Number";
  }

  String getDiseaseRecommendation(bool isHealthy) {
    List<String>? recommendations = _diseaseRecommendations[isHealthy ? "healthy" : "infected"];
    if (recommendations == null) return "unknown recommendation";
    return (recommendations..shuffle()).first;
  }

}