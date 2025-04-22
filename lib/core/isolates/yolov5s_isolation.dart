import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:podscan/core/models/yolov5s_model.dart';
import 'package:podscan/core/services/model_service.dart';


class YoloV5sIsolateParams {
  final String imagePath;
  final String? modelPath;
  final double confidenceThreshold;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  YoloV5sIsolateParams({
    required this.imagePath,
    required this.modelPath,
    required this.sendPort,
    required this.rootIsolateToken,
    this.confidenceThreshold = 0.5
  });
}

void yoloIsolateEntry(YoloV5sIsolateParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.rootIsolateToken);
  if (params.modelPath == null) return;
  
  final File imageFile = File(params.imagePath);

  YoloV5sModel model = YoloV5sModel();
  model.load(modelFile: File(params.modelPath!));
  await model.runInference(
    imageFile: imageFile,
    confidenceThreshold: params.confidenceThreshold,
  );

  params.sendPort.send({
    'normalizedBboxMinmax': model.normalizedBboxMinmax,
    'confidence': model.detectedObjectConfidence,
    'classIndex': model.detectedObjectIndex,
  });

  model.dispose(); // cleanup
}

Future<Map<String, dynamic>> runYoloInferenceInIsolate(ModelType modelType, String imagePath, RootIsolateToken rootIsolateToken) async {
  final receivePort = ReceivePort();
  final isolateParams = YoloV5sIsolateParams(
    imagePath: imagePath,
    modelPath: ModelService().getModelPath(modelType),
    sendPort: receivePort.sendPort,
    rootIsolateToken: rootIsolateToken,
  );

  await Isolate.spawn(yoloIsolateEntry, isolateParams);

  return await receivePort.first as Map<String, dynamic>;
}