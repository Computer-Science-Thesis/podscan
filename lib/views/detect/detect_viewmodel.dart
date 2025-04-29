import 'dart:io';
import 'dart:typed_data';
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
      final Uint8List imageBytes = await _imageFile.readAsBytes();
      final List<File?> imageFutures = await Future.wait([
        ImageService().drawBoundingBoxes(imageBytes, output['normalizedBboxMinmax']),
        ImageService().cropImage(imageBytes, output['normalizedBboxMinmax'])
      ]);
      detectedImageFile = imageFutures[0] ?? _imageFile; 
      croppedImageFile = imageFutures[1] ?? _imageFile; 
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

  Future<bool> showBackConfirmationDialog(BuildContext context) async {
    if (isDetecting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You can't go back during detection."),
          duration: Duration(seconds: 2),
        )
      );
      return false;
    }

    bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Back'),
        content: Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  void goBack(BuildContext context) {
    debugPrint("Going Back...");
    Navigator.of(context).pop();
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