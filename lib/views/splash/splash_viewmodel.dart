import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../../core/services/sample_service.dart';

class SplashViewModel with ChangeNotifier {
  final SampleService _sampleService = SampleService();

  Future<void> initializeApp(BuildContext context) async {
    await _sampleService.load();

    if (!context.mounted) return;

    goToHomeView(context);
  }

  void goToHomeView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeView())
    );
  }
}