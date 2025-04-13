import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analyze_viewmodel.dart';

class AnalyzeView extends StatelessWidget {
  final String imagePlaceHolder;

  const AnalyzeView({super.key, required this.imagePlaceHolder});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyzeViewModel(imagePlaceHolder: imagePlaceHolder),
      child: const _AnalyzeViewBody(),
    );
  }
}

class _AnalyzeViewBody extends StatelessWidget {
  const _AnalyzeViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyzeViewModel>();
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(viewModel, theme),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildImage(viewModel, theme),
              SizedBox(height: screenHeight * 0.05),
              _buildButtons(viewModel, context, theme),
            ]
          )
        ),
      ),
    );
  }

  Widget _buildTitle(AnalyzeViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Analyze View",
          style: theme.textTheme.titleLarge,
        ),
        Text(
          viewModel.imagePlaceHolder,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ]
    );
  }

  Widget _buildImage(AnalyzeViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          viewModel.imagePlaceHolder,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildButtons(AnalyzeViewModel viewModel, BuildContext context, ThemeData theme) {
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
          onPressed: () => viewModel.analyze(context),
          icon: const Icon(Icons.analytics),
          label: const Text("Analyze"),
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