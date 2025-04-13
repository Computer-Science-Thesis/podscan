import 'package:flutter/material.dart';
import '../detect/detect_view.dart';

class HomeViewModel with ChangeNotifier {
  late String imagePlaceHolder;

  void takePhoto(BuildContext context) {
    debugPrint("Taking Photo...");
    imagePlaceHolder = "Captured Photo.";
    goToDetectView(context);
  }

  void uploadPhoto(BuildContext context) {
    debugPrint("Uploading Photo...");
    imagePlaceHolder = "Uploaded Photo.";
    goToDetectView(context);
  }

  void goToDetectView(BuildContext context) {
    debugPrint("Going to Detect View...");
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetectView(imagePlaceHolder: imagePlaceHolder))
    );
  }

}