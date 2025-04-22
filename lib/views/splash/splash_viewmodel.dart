import 'package:flutter/material.dart';
import 'package:podscan/core/services/model_service.dart';
import '../../core/services/label_service.dart';
import '../home/home_view.dart';

class SplashViewModel with ChangeNotifier {
  Future<void> initializeApp(BuildContext context) async {
    Future.wait([
      LabelService().loadAllLabels(),
      ModelService().prepareAllModels(),
    ]);

    if (!context.mounted) return;

    goToHomeView(context);
  }

  void goToHomeView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeView())
    );
  }
}