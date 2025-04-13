import 'package:flutter/material.dart';
import '../result/result_view.dart';

class AnalyzeViewModel with ChangeNotifier {
  final String imagePlaceHolder;

  AnalyzeViewModel({required this.imagePlaceHolder});

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