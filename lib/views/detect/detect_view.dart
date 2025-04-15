import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'detect_viewmodel.dart';

class DetectView extends StatelessWidget {
  final File imageFile;

  const DetectView({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetectViewModel(imageFile: imageFile),
      child: const _DetectViewBody(),
    );
  }
}

class _DetectViewBody extends StatelessWidget {
  const _DetectViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DetectViewModel>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF832637), // Match splash screen
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildImageContainer(viewModel, screenHeight),
              const SizedBox(height: 20),
              _buildAnalyzeButton(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the header with the app logo and title.
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

  // Builds the container to display the image.
  Widget _buildImageContainer(DetectViewModel viewModel, double screenHeight) {
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
                  viewModel.imageFile,
                ),
              ),
            ),
          ),
          if (viewModel.isDetecting) _buildLoadingEffect(viewModel, screenHeight * 0.50),
        ],
      ),
    );
  }

  Widget _buildLoadingEffect(DetectViewModel viewModel, double containerHeight) {
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

  // Builds the analyze button.
  Widget _buildAnalyzeButton(DetectViewModel viewModel, BuildContext context) {
    const buttonColor = Color(0xFF628E6E); // Greenish color.
    const buttonTextColor = Colors.white;
    const buttonBorderRadius = 10.0;

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          elevation: 5,
          disabledBackgroundColor: buttonColor, // Keep green when disabled
          disabledForegroundColor: buttonTextColor, // Keep white text
        ),
        onPressed:
            viewModel.isDetecting ? null : () => viewModel.detect(context), // Disable when analyzing
        child: Text(
          viewModel.isDetecting ? 'Detecting' : 'Detect', // Change text dynamically
          style: const TextStyle(
            fontFamily: 'CinzelDecorative',
            fontSize: 18,
          ),
        ),
      ),
    );
  }

}