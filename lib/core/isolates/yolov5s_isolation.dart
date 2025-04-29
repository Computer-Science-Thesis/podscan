import 'dart:io';
import 'package:flutter/services.dart';
import 'package:podscan/core/isolates/base_isolation.dart';
import 'package:podscan/core/models/yolov5s_model.dart';
import 'package:podscan/core/services/model_service.dart';


class YoloV5sIsolateParams extends BaseIsolateParams {
  YoloV5sIsolateParams({
    required super.imagePath,
    required super.modelPath,
    required super.sendPort,
    required super.rootIsolateToken
  });
}

void yoloIsolateEntry(YoloV5sIsolateParams params) async {
  await handleIsolateInference(
    params: params,
    runModelInference: (params) async {
      final File imageFile = File(params.imagePath);
      final YoloV5sModel model = YoloV5sModel();
      model.load(modelFile: File(params.modelPath!));
      await model.runInference(imageFile: imageFile);
      final Map<String, dynamic> result = {
        'normalizedBboxMinmax': model.normalizedBboxMinmax,
        'confidence': model.detectedObjectConfidence,
        'classIndex': model.detectedObjectIndex,
      };
      model.dispose(); // cleanup
      return result;
  });
}

Future<Map<String, dynamic>> runYoloInferenceInIsolate(ModelType modelType, String imagePath, RootIsolateToken rootIsolateToken) async {
  return await runInferenceInIsolate<YoloV5sIsolateParams>(
    createParams: (sendPort) => YoloV5sIsolateParams(
      imagePath: imagePath,
      modelPath: ModelService().getModelPath(modelType),
      sendPort: sendPort,
      rootIsolateToken: rootIsolateToken,
    ),
    isolateEntry: yoloIsolateEntry,
  );
}