import 'package:flutter/material.dart';
import '../models/base_model.dart';
import '../models/resnet50_model.dart';
import '../models/unet_model.dart';
import '../models/yolov5s_model.dart';

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

  Future<BaseModel?> getModel(String modelType) async {
    switch (modelType) {
      case "disease":
        if (_diseaseModel == null) {
          _diseaseModel = ResNet50Model();
          await _loadModel(_diseaseModel!, "assets/models/resnet50/disease_model.tflite");
        }
        return _diseaseModel;
      case "variety":
          if (_varietyModel == null) {
            _varietyModel = ResNet50Model();
            await _loadModel(_varietyModel!, "assets/models/resnet50/variety_model.tflite");
          }
          return _varietyModel;
      case "objectDetection":
          if (_objectDetectionModel == null) {
            _objectDetectionModel = YoloV5sModel();
            await _loadModel(_objectDetectionModel!, "assets/models/yolov5s/object_model.tflite");
          }
          return _objectDetectionModel;
      case "diseaseMask":
          if (_diseaseMaskModel == null) {
            _diseaseMaskModel = UNetModel();
            await _loadModel(_diseaseMaskModel!, "assets/models/unet/disease_mask.tflite");
          }
          return _diseaseMaskModel;
      case "podMask":
          if (_podMaskModel == null) {
            _podMaskModel = UNetModel();
            await _loadModel(_podMaskModel!, "assets/models/unet/pod_mask.tflite");
          }
          return _podMaskModel;
      default:
        debugPrint("Unknown model type: $modelType");
        return null;
    }
  }

  void unloadModel(String modelType) {
    switch (modelType) {
      case "disease":
        _diseaseModel?.dispose();
        _diseaseModel = null;
        debugPrint("Unloaded disease model.");
      case "variety":
        _varietyModel?.dispose();
        _varietyModel = null;
        debugPrint("Unloaded variety model.");
      case "objectDetection":
        _objectDetectionModel?.dispose();
        _objectDetectionModel = null;
        debugPrint("Unloaded object detection model.");
      case "diseaseMask":
        _diseaseMaskModel?.dispose();
        _diseaseMaskModel = null;
        debugPrint("Unloaded disease mask model.");
      case "podMask":
        _podMaskModel?.dispose();
        _podMaskModel = null;
        debugPrint("Unloaded pod mask model.");
      default:
      debugPrint("Unknown model type: $modelType");
    }
  }

  Future<void> _loadModel(BaseModel model, String modelPath) async {
    await model.load(modelPath: modelPath);
    if (model.isLoaded) {
      debugPrint("Model is Loaded: '$modelPath'");
    }
  }
}