import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum ModelType {
  disease,
  variety,
  objectDetection,
  diseaseMask,
  podMask
}

extension ModelTypeExtension on ModelType {
  String get modelPath {
    switch (this) {
      case ModelType.disease:
        return "assets/models/resnet50/disease_model.tflite";
      case ModelType.variety:
        return "assets/models/resnet50/variety_model.tflite";
      case ModelType.objectDetection:
        return "assets/models/yolov5s/object_model.tflite";
      case ModelType.diseaseMask:
        return "assets/models/unet/disease_mask.tflite";
      case ModelType.podMask:
        return "assets/models/unet/pod_mask.tflite";
    }
  }

  String get displayName {
        switch (this) {
      case ModelType.disease:
        return "Disease Classification";
      case ModelType.variety:
        return "Variety Classification";
      case ModelType.objectDetection:
        return "Object Detection";
      case ModelType.diseaseMask:
        return "Disease Mask Segmentation";
      case ModelType.podMask:
        return "Pod Mask Segmentation";
    }
  }
}

class ModelService {
  static final ModelService _instance = ModelService._internal();

  File? _diseaseModelFile;
  File? _varietyModelFile;
  File? _objectDetectionModelFile;
  File? _diseaseMaskModelFile;
  File? _podMaskModelFile;

  factory ModelService() {
    return _instance;
  }

  ModelService._internal();

  Future<void> prepareAllModels() async {
    _diseaseModelFile = await _prepareModelFile(ModelType.disease);
    _varietyModelFile = await _prepareModelFile(ModelType.variety);
    _objectDetectionModelFile = await _prepareModelFile(ModelType.objectDetection);
    _diseaseMaskModelFile = await _prepareModelFile(ModelType.diseaseMask);
    _podMaskModelFile = await _prepareModelFile(ModelType.podMask);
  }

  Future<File> _prepareModelFile(ModelType modelType) async {
  final byteData = await rootBundle.load(modelType.modelPath);
  final directory = await getTemporaryDirectory();
  final modelPath = '${directory.path}/${modelType.modelPath.split('/').last}';
  final modelFile = File(modelPath);

  await modelFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  debugPrint('model prepared: $modelPath');
  return modelFile;
}

  String? getModelPath(ModelType modelType) {
    switch (modelType) {
      case ModelType.disease:
        return _diseaseModelFile?.path;
      case ModelType.variety:
        return _varietyModelFile?.path;
      case ModelType.objectDetection:
        return _objectDetectionModelFile?.path;
      case ModelType.diseaseMask:
        return _diseaseMaskModelFile?.path;
      case ModelType.podMask:
        return _podMaskModelFile?.path;
    }
  }
}