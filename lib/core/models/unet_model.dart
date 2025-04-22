import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:podscan/core/models/base_model.dart';

class UNetModel extends BaseModel {
  // [[normalizedPixelValue, normalizedPixelValue, ..., normalizedPixelValue]
  //  [normalizedPixelValue, normalizedPixelValue, ..., normalizedPixelValue]]
  List<List<double>>? _normalizedPixelValues;

  bool get hasOutput => _normalizedPixelValues != null && _normalizedPixelValues!.isNotEmpty;
  List<List<double>>? get normalizedPixelValues => _normalizedPixelValues;

  @override
  Future<void> runInference({required File imageFile}) async {
    await super.runInference(imageFile: imageFile);
    if (!hasBaseOutput) {
      _normalizedPixelValues = null;
      return;
    }

    final int height = outputShape![1];
    final int width = outputShape![2];
    _normalizedPixelValues = List.generate(height, (i) => List.generate(width, (j) => baseOutput![0][i][j][0]));
  }

  Future<File?> generateImage() async {
    if (!hasOutput) {
      return null;
    }

    List<List<double>> nPixVals = _normalizedPixelValues!;

    final int height = outputShape![1];
    final int width = outputShape![2];

    final img.Image image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int pixelValue = ((nPixVals[y][x] as num) * 255).clamp(0, 255).toInt();
        final img.ColorRgb8 pixelColor = img.ColorRgb8(pixelValue, pixelValue, pixelValue);
        image.setPixel(x, y, pixelColor);
      }
    }

    final Directory temporaryDirectory = await getTemporaryDirectory();
    final String imagePath = "$temporaryDirectory/mask_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final File imageFile = File(imagePath);
    await imageFile.writeAsBytes(img.encodeJpg(image));

    return imageFile;
  }

  static double podDiseaseIntersectionRatio({
    required List<List<double>>? targetMask,
    required List<List<double>>? referenceMask,
    double threshold = 0.8,
  }) {
    if (targetMask == null || referenceMask == null) return 0.0;
    final List<int> targetMaskShape = _getShape(targetMask);
    final List<int> referenceMaskShape = _getShape(referenceMask);
    if (!_areShapesEqual(targetMaskShape, referenceMaskShape)) return 0.0;
    

    int referenceCount = 0;
    int intersectionCount = 0;

    for (int y = 0; y < targetMaskShape[0]; y++) {
      for (int x = 0; x < targetMaskShape[1]; x++) {
        if (referenceMask[y][x] >= threshold) {
          referenceCount++;
          if (targetMask[y][x] >= threshold) {
            intersectionCount++;
          }
        }
      }
    }

    return referenceCount == 0 ? 0.0 : intersectionCount / referenceCount;
  }

  static List<int> _getShape(List<List<double>> matrix) {
    int rows = matrix.length;
    int cols = rows > 0 ? matrix[0].length : 0;

    return [rows, cols];
  }

  static bool _areShapesEqual(List<int> shape1, List<int> shape2) {
    if (shape1.length != shape2.length) return false;
    for (int i = 0; i < shape1.length; i++) {
      if (shape1[i] != shape2[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _normalizedPixelValues = null;
    super.dispose();
  }
}