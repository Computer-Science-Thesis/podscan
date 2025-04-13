import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'result_viewmodel.dart';

class ResultView extends StatelessWidget {
  final String imagePlaceHolder;
  const ResultView({super.key, required this.imagePlaceHolder});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResultViewModel(imagePlaceHolder: imagePlaceHolder),
      child: const _ResultViewBody(),
    );
  }
}

class _ResultViewBody extends StatelessWidget {
  const _ResultViewBody();

  @override build(BuildContext context) {
    final viewModel = context.watch<ResultViewModel>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: _buildTitle(viewModel),
              expandedHeight: screenHeight * 0.4,
              collapsedHeight: screenHeight * 0.1,
              pinned: true,
              backgroundColor: Colors.red,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 15),
                const Text("Item 1", style: TextStyle(height: 5)),
                const Text("Item 2", style: TextStyle(height: 5)),
                const Text("Item 3", style: TextStyle(height: 5)),
                const Text("Item 4", style: TextStyle(height: 5)),
                const Text("Item 5", style: TextStyle(height: 5)),
                const Text("Item 6", style: TextStyle(height: 5)),
                const Text("Item 7", style: TextStyle(height: 5)),
                const Text("Item 8", style: TextStyle(height: 5)),
                const Text("Item 9", style: TextStyle(height: 5)),
                const Text("Item 10", style: TextStyle(height: 5)),
                Text('temp'),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ResultViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Result View"),
        Text(
          viewModel.imagePlaceHolder,
          style: TextStyle(fontSize: 16),
        ),
      ]
    );
  }
}