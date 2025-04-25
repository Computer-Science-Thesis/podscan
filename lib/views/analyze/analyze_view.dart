import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analyze_viewmodel.dart';

class AnalyzeView extends StatelessWidget {
  final Map<String, dynamic> detectionOutput;

  const AnalyzeView({super.key, required this.detectionOutput});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyzeViewModel(detectionOutput: detectionOutput),
      child: const _AnalyzeViewBody(),
    );
  }
}

class _AnalyzeViewBody extends StatelessWidget {
  const _AnalyzeViewBody();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = context.watch<AnalyzeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF832637),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildImageContainer(viewModel, screenHeight),
              const SizedBox(height: 5),
              _buildMessage(viewModel),
              const SizedBox(height: 20),
              _buildActionButtons(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 80.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(width: 8),
          _buildTitle(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 70,
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'CinzelDecorative',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'POD',
            style: TextStyle(color: Color(0xFF7ED957)),
          ),
          TextSpan(
            text: 'SCAN',
            style: TextStyle(color: Color(0xFFFFDE59)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(AnalyzeViewModel viewModel, double screenHeight) {
    const borderColor = Colors.white;
    const borderThickness = 2.0;
    const borderRadius = 5.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            height: screenHeight * 0.50, // 50% of screen height
            width: double.infinity, // Full width
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: borderThickness,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: FittedBox(
                fit: BoxFit.cover, // Ensures the image fills the container
                alignment: Alignment.center, // Centers the image
                child: Image.file(
                  viewModel.drawnImageFile,
                ),
              ),
            ),
          ),
          if (viewModel.isAnalyzing) _buildLoadingEffect(screenHeight * 0.50),
        ],
      ),
    );
  }

  Widget _buildLoadingEffect(double containerHeight) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: containerHeight,
      color: Colors.black.withValues(alpha: 0.5), // Semi-transparent overlay
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              backgroundColor: Colors.grey[700], // Visible background
              strokeWidth: 6, // Thicker for better visibility
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(AnalyzeViewModel viewModel) {
    String message = 'No Cacao Detected';
    if (viewModel.detectedObject == 'cacao') {
      message = 'Cacao Detected!';
    } else if (viewModel.detectedObject == 'plastic-cacao') {
      message = 'Cacao Detected with Plastic!';
    }

    return Center(
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          if (viewModel.detectedObject == 'cacao') ...[
            Text(
              'Confidence: ${(viewModel.confidenceScore * 100).toStringAsFixed(2)}%',
              style: const TextStyle(
                fontFamily: 'CinzelDecorative',
                fontSize: 15,
                color: Colors.white70,
              ),
            )
          ],
          if (viewModel.detectedObject == 'plastic-cacao') ...[
            const SizedBox(height: 8),
            Center(
              // Centering the warning text
              child: Text(
                '⚠ Please remove the plastic before proceeding.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'CinzelDecorative',
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRetryButton(AnalyzeViewModel viewModel, BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF628E6E),
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
      ),
      onPressed: () => viewModel.goBack(context),
      child: const Text(
        'Retry',
        style: TextStyle(
          fontFamily: 'CinzelDecorative',
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(AnalyzeViewModel viewModel, BuildContext context) {
    const buttonColor = Color(0xFF628E6E); // Greenish color.
    const buttonTextColor = Colors.white;
    const buttonBorderRadius = 10.0;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        elevation: 5,
        disabledBackgroundColor: buttonColor, // Keep green when disabled
        disabledForegroundColor: buttonTextColor, // Keep white text
      ),
      onPressed: viewModel.isAnalyzing ? null : () => viewModel.analyzeWithIsolate(context), // Disable when analyzing
      child: Text(
        viewModel.isAnalyzing ? 'Analyzing' : 'Analyze', // Change text dynamically
        style: const TextStyle(
          fontFamily: 'CinzelDecorative',
          fontSize: 18
        ),
      ),
    );
  }

  Widget _buildActionButtons(AnalyzeViewModel viewModel, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = (constraints.maxWidth - 15) / 2;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 15,
          runSpacing: 10,
          children: [
            SizedBox(
              width: viewModel.detectedObject == 'cacao' ? buttonWidth : constraints.maxWidth,
              child: _buildRetryButton(viewModel, context),
            ),
            if (viewModel.detectedObject == 'cacao')
              SizedBox(
                width: buttonWidth,
                child: _buildAnalyzeButton(viewModel, context),
              ),
          ],
        );
      },
    );
  }

}