import 'dart:io';
import 'package:flutter/services.dart';
import 'package:podscan/core/isolates/base_isolation.dart';
import 'package:podscan/core/models/unet_model.dart';
import 'package:podscan/core/services/model_service.dart';


class UNetIsolateParams extends BaseIsolateParams {
  UNetIsolateParams({
    required super.imagePath,
    required super.modelPath,
    required super.sendPort,
    required super.rootIsolateToken
  });
}

void unetIsolateEntry(UNetIsolateParams params) async {
  await handleIsolateInference(
    params: params,
    runModelInference: (params) async {
      final File imageFile = File(params.imagePath);
      final UNetModel model = UNetModel();
      model.load(modelFile: File(params.modelPath!));
      await model.runInference(imageFile: imageFile);
      final Map<String, dynamic> result = {
        'normalizedPixelValues': model.normalizedPixelValues,
      };
      model.dispose(); // cleanup
      return result;
    });
}

Future<InferenceIsolate<UNetIsolateParams>> runUNetInferenceInIsolate(
  ModelType modelType,
  String imagePath,
  RootIsolateToken rootIsolateToken
) async {
  return await runInferenceInIsolate<UNetIsolateParams>(
    createParams: (sendPort) => UNetIsolateParams(
      imagePath: imagePath,
      modelPath: ModelService().getModelPath(modelType),
      sendPort: sendPort,
      rootIsolateToken: rootIsolateToken,
    ),
    isolateEntry: unetIsolateEntry,
  );
}