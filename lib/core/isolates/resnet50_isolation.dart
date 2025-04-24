import 'dart:io';
import 'package:flutter/services.dart';
import 'package:podscan/core/isolates/base_isolation.dart';
import 'package:podscan/core/models/resnet50_model.dart';
import 'package:podscan/core/services/model_service.dart';


class ResNet50IsolateParams extends BaseIsolateParams {
  ResNet50IsolateParams({
    required super.imagePath,
    required super.modelPath,
    required super.sendPort,
    required super.rootIsolateToken
  });
}

void resNet50IsolateEntry(ResNet50IsolateParams params) async {
  await handleIsolateInference(
    params: params,
    runModelInference: (params) async {
        final File imageFile = File(params.imagePath);
        final ResNet50Model model = ResNet50Model();
        model.load(modelFile: File(params.modelPath!));
        await model.runInference(imageFile: imageFile);
        final Map<String, dynamic> result = {
          'classIndexToConfidenceMap': model.classIndexToConfidenceMap,
        };
        model.dispose(); // cleanup
        return result;
    });
}

Future<Map<String, dynamic>> runResNet50InferenceInIsolate(ModelType modelType, String imagePath, RootIsolateToken rootIsolateToken) async {
  return await runInferenceInIsolate<ResNet50IsolateParams>(
    createParams: (sendPort) => ResNet50IsolateParams(
      imagePath: imagePath,
      modelPath: ModelService().getModelPath(modelType),
      sendPort: sendPort,
      rootIsolateToken: rootIsolateToken,
    ),
    isolateEntry: resNet50IsolateEntry
  );
}