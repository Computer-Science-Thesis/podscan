import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class BaseModel {
  Interpreter? _interpreter;
  List<int>? _inputShape;
  List<int>? _outputShape;
  List<dynamic>? _baseOutput;

  bool get isLoaded => _interpreter != null && inputShape != null && _outputShape != null;
  bool get hasBaseOutput => _baseOutput != null && baseOutput!.isNotEmpty;
  List<dynamic>? get baseOutput => _baseOutput;
  List<int>? get inputShape => _inputShape;
  List<int>? get outputShape => _outputShape;

  Future<void> load({required String modelPath}) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _inputShape = _interpreter?.getInputTensors()[0].shape;
      _outputShape = _interpreter?.getOutputTensors()[0].shape;
    } catch (e) {
      _interpreter = null;
      debugPrint("Error loading model: $e");
    }
  }

  Future<void> runInference({required File imageFile}) async {
    if (!isLoaded) {
      throw Exception("Error: Attempting to use an unloaded model.");
    }

    // Read and decode the image
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image inputImage = img.decodeImage(imageBytes)!;

    // Resize the image based on input shape
    final width = _inputShape![2];
    final height = _inputShape![1];

    final img.Image resizedImage = img.copyResize(inputImage, width: width, height: height);

    // Normalize and convert to Float32
    Float32List input = Float32List(height * width * 3);
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);
        int index = y * width * 3 + x * 3;
        input[index + 0] = pixel.r / 255.0;
        input[index + 1] = pixel.g / 255.0;
        input[index + 2] = pixel.b / 255.0;
      }
    }

    List<dynamic> inputTensor = input.reshape(_inputShape!);
    _baseOutput = List.filled(_outputShape!.reduce((a, b) => a * b), 0).reshape(_outputShape!);

    _interpreter!.run(inputTensor, _baseOutput!);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _inputShape = null;
    _outputShape = null;
    _baseOutput = null;
  }
}