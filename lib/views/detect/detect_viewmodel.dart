import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:podscan/core/isolates/base_isolation.dart';
import 'package:podscan/core/services/image_service.dart';
import 'package:podscan/core/services/label_service.dart';
import 'package:podscan/core/isolates/yolov5s_isolation.dart';
import 'package:podscan/core/services/model_service.dart';
import 'package:podscan/views/analyze/analyze_view.dart';

class DetectViewModel with ChangeNotifier {
  late File _imageFile;
  bool isDetecting = false;

  InferenceIsolate? _inferenceIsolate;

  File get imageFile => _imageFile;

  DetectViewModel({required File imageFile}) {
    _imageFile = imageFile;
  }

  Future<void> detectWithIsolate(BuildContext context) async {
    final stopWatch = Stopwatch()..start();

    isDetecting = true;
    notifyListeners();

    Map<String, double> detectedObjectMap = {"none": 0.0};
    File detectedImageFile = _imageFile;
    File croppedImageFile = _imageFile;

    try {
      _inferenceIsolate = await runYoloInferenceInIsolate(ModelType.objectDetection, _imageFile.path, RootIsolateToken.instance!);
      final objectDetectionOutput = await _inferenceIsolate!.result;

      if (objectDetectionOutput.containsKey('error')) {
        debugPrint('Isolate error: ${objectDetectionOutput['error']}');
        return;
      } else {
        debugPrint('Object detection inference time: ${objectDetectionOutput['elapsedMilliseconds']}ms');
      }
      
      if (objectDetectionOutput['classIndex'] != null && objectDetectionOutput['confidence'] != null) {
        final String object = LabelService().getObjectLabel(objectDetectionOutput['classIndex']);
        final double confidence = objectDetectionOutput['confidence'];
        detectedObjectMap = {object: confidence};
      }

      if (objectDetectionOutput['normalizedBboxMinmax'] != null) {
        final Uint8List imageBytes = await _imageFile.readAsBytes();
        final List<File?> imageFutures = await Future.wait([
          ImageService().drawBoundingBoxes(imageBytes, objectDetectionOutput['normalizedBboxMinmax']),
          ImageService().cropImage(imageBytes, objectDetectionOutput['normalizedBboxMinmax'])
        ]);
        detectedImageFile = imageFutures[0] ?? _imageFile;
        croppedImageFile = imageFutures[1] ?? _imageFile;
      }
      
    } catch (e) {
      debugPrint("Error during detection: $e");
    } finally {
      stopWatch.stop();
      debugPrint("Total detection process time: ${stopWatch.elapsedMilliseconds}ms");

      isDetecting = false;
      _inferenceIsolate = null;
      notifyListeners();
    }

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
    debugPrint("Killing running isolate...");
    _inferenceIsolate?.stop();
    _inferenceIsolate = null;

    debugPrint("Going back...");
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