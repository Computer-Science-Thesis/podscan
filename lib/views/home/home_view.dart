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
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Home (Stateful)")),
      body: SafeArea(
        child: Center(
          child: _buildButtons(viewModel, context),
        ),
      ),
    );
  }

  Widget _buildButtons(HomeViewModel viewModel, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => viewModel.takePhoto(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text("Take Photo"),
        ),
        ElevatedButton.icon(
          onPressed: () => viewModel.uploadPhoto(context),
          icon: const Icon(Icons.photo_library),
          label: const Text("Upload Photo"),
        )
      ]
    );
  }
}