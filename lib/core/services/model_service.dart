import 'package:flutter/material.dart';
import '../models/base_model.dart';
import '../models/resnet50_model.dart';
import '../models/unet_model.dart';
import '../models/yolov5s_model.dart';

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

  ResNet50Model? _diseaseModel;
  ResNet50Model? _varietyModel;
  YoloV5sModel? _objectDetectionModel;
  UNetModel? _diseaseMaskModel;
  UNetModel? _podMaskModel;

  ResNet50Model? get varietyModel => _varietyModel;
  ResNet50Model? get diseaseModel => _diseaseModel;
  YoloV5sModel? get objectDetectionModel => _objectDetectionModel;
  UNetModel? get podMaskModel => _podMaskModel;
  UNetModel? get diseaseMaskModel => _diseaseMaskModel;

  factory ModelService() {
    return _instance;
  }

  ModelService._internal();

  Future<BaseModel?> getModel(ModelType modelType) async {
    switch (modelType) {
      case ModelType.disease:
        if (_diseaseModel == null) {
          _diseaseModel = ResNet50Model();
          await _loadModel(_diseaseModel!, modelType.modelPath);
        }
        return _diseaseModel;
      case ModelType.variety:
          if (_varietyModel == null) {
            _varietyModel = ResNet50Model();
            await _loadModel(_varietyModel!, modelType.modelPath);
          }
          return _varietyModel;
      case ModelType.objectDetection:
          if (_objectDetectionModel == null) {
            _objectDetectionModel = YoloV5sModel();
            await _loadModel(_objectDetectionModel!, modelType.modelPath);
          }
          return _objectDetectionModel;
      case ModelType.diseaseMask:
          if (_diseaseMaskModel == null) {
            _diseaseMaskModel = UNetModel();
            await _loadModel(_diseaseMaskModel!, modelType.modelPath);
          }
          return _diseaseMaskModel;
      case ModelType.podMask:
          if (_podMaskModel == null) {
            _podMaskModel = UNetModel();
            await _loadModel(_podMaskModel!, modelType.modelPath);
          }
          return _podMaskModel;
    }
  }

  void unloadModel(ModelType modelType) {
    switch (modelType) {
      case ModelType.disease:
        _diseaseModel?.dispose();
        _diseaseModel = null;
        debugPrint("Unloaded ${modelType.displayName} model.");
      case ModelType.variety:
        _varietyModel?.dispose();
        _varietyModel = null;
        debugPrint("Unloaded ${modelType.displayName} model.");
      case ModelType.objectDetection:
        _objectDetectionModel?.dispose();
        _objectDetectionModel = null;
        debugPrint("Unloaded ${modelType.displayName} model.");
      case ModelType.diseaseMask:
        _diseaseMaskModel?.dispose();
        _diseaseMaskModel = null;
        debugPrint("Unloaded ${modelType.displayName} model.");
      case ModelType.podMask:
        _podMaskModel?.dispose();
        _podMaskModel = null;
        debugPrint("Unloaded ${modelType.displayName} model.");
    }
  }

  Future<void> _loadModel(BaseModel model, String modelPath) async {
    await model.load(modelPath: modelPath);
    if (model.isLoaded) {
      debugPrint("Model loaded successfully: '$modelPath'");
    }
  }
}