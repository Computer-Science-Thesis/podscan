// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../../core/models/resnet50_model.dart';
// import '../../core/services/label_service.dart';
// import '../../core/services/model_service.dart';
// import '../../core/models/yolov5s_model.dart';
// import '../analyze/analyze_view.dart';

// class DetectViewModel with ChangeNotifier {
//   final ModelService _modelService = ModelService();
//   late File _imageFile;
//   late YoloV5sModel _objectDetectionModel;
//   bool isDetecting = false;

//   File get imageFile => _imageFile;

//   DetectViewModel({required File imageFile}) {
//     _imageFile = imageFile;
//     _loadModels();
//   }

//   Future<void> _loadModels() async {
//     try {
//       _objectDetectionModel = await _modelService.getModel(ModelType.objectDetection) as YoloV5sModel;
//     } catch (e) {
//       debugPrint("Error loading model: $e");
//     }
//   }

//   void _unloadModels() {
//     ModelService().unloadModel(ModelType.objectDetection);
//   }

//   Future<void> detect(BuildContext context) async {
//     if (!_objectDetectionModel.isLoaded) { 
//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Object detection model is not loaded. Please try again later."),
//           duration: Duration(seconds: 3),
//         ),
//       );
//       goBack(context);
//       return;
//     }

//     isDetecting = true;
//     notifyListeners();
//     final Map<String, dynamic> output = await _runInference();
//     isDetecting = false;
//     notifyListeners();

//     if (context.mounted) goToAnalyzeView(context, output);
//   }

//   Future<Map<String, dynamic>> _runInference() async {
//     File detectedImageFile = _imageFile;
//     Map<String, double> detectedObjectMap = {"none": 0.0};
//     List<double> normalizedBboxMinmax = [0.0, 0.0, 1, 1];

//     await _objectDetectionModel.runInference(imageFile: _imageFile);
//     if (_objectDetectionModel.hasOutput) {
//       final String detectedObject = LabelService().getObjectLabel(_objectDetectionModel.detectedObjectIndex!);
//       final double detectedObjectConfidence = _objectDetectionModel.detectedObjectConfidence!;
//       detectedObjectMap = {detectedObject: detectedObjectConfidence};
//       normalizedBboxMinmax = _objectDetectionModel.normalizedBboxMinmax!;
//       detectedImageFile = await _objectDetectionModel.drawBoundingBoxes(_imageFile);
//     }
//     notifyListeners();

//     return {
//       "croppedImageFile": await ResNet50Model.cropImage(_imageFile, normalizedBboxMinmax),
//       "detectedImageFile": detectedImageFile,
//       "detectedObjectMap": detectedObjectMap
//     };
//   }

//   void goBack(BuildContext context) {
//     debugPrint("Going Back...");
//     _unloadModels();
//     Navigator.of(context).pop();
//   }

//   void goToAnalyzeView(BuildContext context, Map<String, dynamic> output) {
//     debugPrint("Going to Analyze View...");
//     _unloadModels();
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (_) => AnalyzeView(detectionOutput: output))
//     );
//   }
// }

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:podscan/core/services/image_service.dart';
import 'package:podscan/core/services/label_service.dart';
import 'package:podscan/core/isolates/yolov5s_isolation.dart';
import 'package:podscan/core/services/model_service.dart';
import 'package:podscan/views/analyze/analyze_view.dart';

class DetectViewModel with ChangeNotifier {
  late File _imageFile;
  bool isDetecting = false;

  File get imageFile => _imageFile;

  DetectViewModel({required File imageFile}) {
    _imageFile = imageFile;
  }

  Future<void> detectWithIsolate(BuildContext context) async {
    isDetecting = true;
    notifyListeners();

    Map<String, double> detectedObjectMap = {"none": 0.0};
    File detectedImageFile = _imageFile;
    File croppedImageFile = _imageFile;
    
    final output = await runYoloInferenceInIsolate(ModelType.objectDetection, _imageFile.path, RootIsolateToken.instance!);
    if (output.containsKey('error')) {
      debugPrint('Isolate error: ${output['error']}');
      return;
    } else {
      debugPrint('Object detection inference time: ${output['elapsedMilliseconds']}ms');
    }
    
    if (output['classIndex'] != null && output['confidence'] != null) {
      final String object = LabelService().getObjectLabel(output['classIndex']);
      final double confidence = output['confidence'];
      detectedObjectMap = {object: confidence};
    }

    if (output['normalizedBboxMinmax'] != null) {
      detectedImageFile = await ImageService().drawBoundingBoxes(_imageFile, output['normalizedBboxMinmax']);
      croppedImageFile = await ImageService().cropImage(_imageFile, output['normalizedBboxMinmax']);
    }

    isDetecting = false;
    notifyListeners();

    if (context.mounted) {
      goToAnalyzeView(context, {
        'detectedObjectMap': detectedObjectMap,
        'detectedImageFile': detectedImageFile,
        'croppedImageFile': croppedImageFile,
      });
    }
  }

    void goToAnalyzeView(BuildContext context, Map<String, dynamic> output) {
    debugPrint("Going to Analyze View...");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AnalyzeView(
        detectionOutput: output,
      ))
    );
  }
}