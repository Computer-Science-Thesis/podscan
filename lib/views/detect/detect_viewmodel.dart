import 'dart:io';
import 'package:flutter/material.dart';
import '../analyze/analyze_view.dart';

class DetectViewModel with ChangeNotifier {
  final File imageFile;

  DetectViewModel({required this.imageFile});

  void detect(BuildContext context) {
    debugPrint("Detecting...");
    goToAnalyzeView(context);
  }

  void goBack(BuildContext context) {
    debugPrint("Going Back...");
    Navigator.of(context).pop();
  }

  void goToAnalyzeView(BuildContext context) {
    debugPrint("Going to Analyze View...");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AnalyzeView(imagePlaceHolder: "Detected Image"))
    );
  }
}