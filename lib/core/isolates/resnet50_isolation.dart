import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:podscan/core/models/resnet50_model.dart';
import 'package:podscan/core/services/model_service.dart';


class ResNet50IsolateParams {
  final String imagePath;
  final String? modelPath;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  ResNet50IsolateParams({
    required this.imagePath,
    required this.modelPath,
    required this.sendPort,
    required this.rootIsolateToken
  });
}

void resNet50IsolateEntry(ResNet50IsolateParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.rootIsolateToken);
  if (params.modelPath == null) return;
  
  final File imageFile = File(params.imagePath);

  ResNet50Model model = ResNet50Model();
  model.load(modelFile: File(params.modelPath!));
  await model.runInference(imageFile: imageFile);

  params.sendPort.send({
    'classIndexToConfidenceMap': model.classIndexToConfidenceMap,
  });

  model.dispose(); // cleanup
}

Future<Map<String, dynamic>> runResNet50InferenceInIsolate(ModelType modelType, String imagePath, RootIsolateToken rootIsolateToken) async {
  final receivePort = ReceivePort();
  final isolateParams = ResNet50IsolateParams(
    imagePath: imagePath,
    modelPath: ModelService().getModelPath(modelType),
    sendPort: receivePort.sendPort,
    rootIsolateToken: rootIsolateToken,
  );

  await Isolate.spawn(resNet50IsolateEntry, isolateParams);

  return await receivePort.first as Map<String, dynamic>;
}