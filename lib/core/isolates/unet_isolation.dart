import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:podscan/core/models/unet_model.dart';
import 'package:podscan/core/services/model_service.dart';


class UNetIsolateParams {
  final String imagePath;
  final String? modelPath;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  UNetIsolateParams({
    required this.imagePath,
    required this.modelPath,
    required this.sendPort,
    required this.rootIsolateToken
  });
}

void unetIsolateEntry(UNetIsolateParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.rootIsolateToken);
  if (params.modelPath == null) return;
  
  final File imageFile = File(params.imagePath);

  UNetModel model = UNetModel();
  model.load(modelFile: File(params.modelPath!));
  await model.runInference(imageFile: imageFile);

  params.sendPort.send({
    'normalizedPixelValues': model.normalizedPixelValues,
  });

  model.dispose(); // cleanup
}

Future<Map<String, dynamic>> unetInferenceInIsolate(ModelType modelType, String imagePath, RootIsolateToken rootIsolateToken) async {
  final receivePort = ReceivePort();
  final isolateParams = UNetIsolateParams(
    imagePath: imagePath,
    modelPath: ModelService().getModelPath(modelType),
    sendPort: receivePort.sendPort,
    rootIsolateToken: rootIsolateToken,
  );

  await Isolate.spawn(unetIsolateEntry, isolateParams);

  return await receivePort.first as Map<String, dynamic>;
}