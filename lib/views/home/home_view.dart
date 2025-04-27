import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeViewBody(),
    );
  }
}

class _HomeViewBody extends StatelessWidget {
  const _HomeViewBody();

  @override
  Widget build(BuildContext context) {
    final HomeViewModel viewModel = context.watch<HomeViewModel>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await viewModel.showExitConfirmationDialog(context);
        if (context.mounted && shouldPop) viewModel.exit(context);
      },
      child: Scaffold(
        body: _buildBody(viewModel, context),
      ),
    );
  }

  Widget _buildBody(HomeViewModel viewModel, BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFF832637),
      child: Column(
        children: [
          Expanded(child: _buildMainContent(viewModel, context)),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildMainContent(HomeViewModel viewModel, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 40),
        _buildButtons(viewModel, context),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(children: [
      Image.asset(
        'assets/images/logo.png',
        height: 100,
      ),
      const SizedBox(height: 10),
      RichText(
        text: const TextSpan(
          style: TextStyle(
            fontFamily: 'CinzelDecorative',
            fontSize: 32,
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
      ),
    ]);
  }

  Widget _buildButtons(HomeViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildButton(
            label: 'Take Photo',
            color: const Color(0xFFF1E6BB),
            textColor: Colors.black,
            onPressed: () => viewModel.checkCameraPermission(context),
          ),
          const SizedBox(height: 20),
          _buildButton(
            label: 'Upload Photo',
            color: const Color(0xFF628E6E),
            textColor: Colors.black,
            onPressed: () => viewModel.uploadPhoto(context),
          )
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(220, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.black.withValues(alpha: 0.3),
      child: const Text(
        'Developed by: Bicol University Students',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}