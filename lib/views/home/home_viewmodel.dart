import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../detect/detect_view.dart';

class HomeViewModel with ChangeNotifier {
  late String imagePlaceHolder;

  Future<void> checkCameraPermission(BuildContext context) async {
    if (await Permission.camera.request().isGranted) {
      if (context.mounted) await takePhoto(context);
    } else if (await Permission.camera.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> takePhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null && context.mounted) goToDetectView(File(photo.path), context);
    } catch (e) {
      debugPrint("Error: $e");
    }

  }

  Future<void> uploadPhoto(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) goToDetectView(File(pickedFile.path), context);
  }

    Future<bool> showExitConfirmationDialog(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Exit"),
            content: Text("Closing the app will end your session. Do you want to continue?"),
            actions: [
              TextButton(
                onPressed: () =>Navigator.of(context).pop(false), // Stay in app
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit app
                child: Text("Yes"),
              ),
            ],
          ),
        )) ?? false; // Default to false if dialog is dismissed
  }

  void closeApp(BuildContext context) {
    debugPrint("Exiting...");
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void goToDetectView(File imageFile, BuildContext context) {
    debugPrint("Going to Detect View...");
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetectView(imageFile: imageFile))
    );
  }

}