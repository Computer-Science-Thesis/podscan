import 'dart:io';
import 'package:flutter/material.dart';
import '../result/result_view.dart';

class AnalyzeViewModel with ChangeNotifier {
  final Map<String, dynamic> detectionOutput;
  late File _imageFile;
  late File _drawnImageFile;

  File get drawnImageFile => _drawnImageFile;

  AnalyzeViewModel({required this.detectionOutput}) {
    _imageFile = detectionOutput["originalImageFile"];
    _drawnImageFile = detectionOutput["detectedImageFile"];
    debugPrint(_imageFile.path);
    debugPrint(_drawnImageFile.path);
  }

  void analyze(BuildContext context) {
    debugPrint("Analyzing...");
    goToResultView(context);
  }

  void goBack(BuildContext context) {
    debugPrint("Going Back...");
    Navigator.of(context).pop();
  }

  void goToResultView(BuildContext context) {
    debugPrint("Going to Result View...");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultView(imagePlaceHolder: "Analyzed Image"))
    );
  }
}