import 'package:flutter/material.dart';
import '../../core/services/label_service.dart';
import '../home/home_view.dart';

class SplashViewModel with ChangeNotifier {
  Future<void> initializeApp(BuildContext context) async {
    Future.wait([LabelService().loadAllLabels()]);

    if (!context.mounted) return;

    goToHomeView(context);
  }

  void goToHomeView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeView())
    );
  }
}