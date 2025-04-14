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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(viewModel, theme),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _buildImage(viewModel, theme),
                ),
              ),
              _buildButtons(viewModel, context, theme),
            ]
          )
        ),
      ),
    );
  }

  Widget _buildTitle(DetectViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detect View",
          style: theme.textTheme.titleLarge,
        ),
        Text(
          "temporary",
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ]
    );
  }

  Widget _buildImage(DetectViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Container(
        width: double.infinity,
        height: 900,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          "temporary",
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildButtons(DetectViewModel viewModel, BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => viewModel.goBack(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text("Back"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          )
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => viewModel.detect(context),
          icon: const Icon(Icons.search),
          label: const Text("Detect"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          )
        ),
      ],
    );
  }

}