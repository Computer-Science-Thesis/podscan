import 'package:flutter/material.dart';
import '../models/base_model.dart';
import '../models/resnet50_model.dart';
import '../models/unet_model.dart';
import '../models/yolov5s_model.dart';

class ModelService {
  static final ModelService _instance = ModelService._internal();

  late ResNet50Model _diseaseModel;
  late ResNet50Model _varietyModel;
  late YoloV5sModel _objectDetectionModel;
  late UNetModel _diseaseMaskModel;
  late UNetModel _podMaskModel;

  ResNet50Model get varietyModel => _varietyModel;
  ResNet50Model get diseaseModel => _diseaseModel;
  YoloV5sModel get objectDetectionModel => _objectDetectionModel;
  UNetModel get podMaskModel => _podMaskModel;
  UNetModel get diseaseMaskModel => _diseaseMaskModel;

  factory ModelService() {
    return _instance;
  }

  ModelService._internal();

  Future<void> loadAllModels() async {
    _diseaseModel = ResNet50Model();
    _loadModel(_diseaseModel, "assets/models/resnet50/disease_model.tflite");

    _varietyModel = ResNet50Model();
    _loadModel(_varietyModel, "assets/models/resnet50/variety_model.tflite");

    _objectDetectionModel = YoloV5sModel();
    _loadModel(_objectDetectionModel, "assets/models/yolov5s/object_model.tflite");

    _diseaseMaskModel = UNetModel();
    _loadModel(_diseaseMaskModel, "assets/models/unet/disease_mask.tflite");

    _podMaskModel = UNetModel();
    _loadModel(_podMaskModel, "assets/models/unet/pod_mask.tflite");

  }

  Future<void> _loadModel(BaseModel model, String modelPath) async {
    await model.load(modelPath: modelPath);
    if (model.isLoaded) {
      debugPrint("Model is Loaded: '$modelPath'");
    }
  }
}