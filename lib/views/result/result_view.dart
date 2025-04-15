import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'result_viewmodel.dart';

class ResultView extends StatelessWidget {
  final Map<String, dynamic> analysisOutput;
  const ResultView({super.key, required this.analysisOutput});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResultViewModel(analysisOutput: analysisOutput),
      child: const _ResultViewBody(),
    );
  }
}

class _ResultViewBody extends StatelessWidget {
  const _ResultViewBody();
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = context.watch<ResultViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF832637),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.3,
            collapsedHeight: screenHeight * 0.2,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image(
                      image: Image.file(viewModel.imageFile).image,
                      fit: BoxFit.cover,
                    ),
                    // Bottom Gradient Effect
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 350, // Adjust as needed
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8), // Dark at bottom
                              Colors.transparent, // Fades upward
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 15),
              _buildContent(viewModel, context),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ResultViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          _buildVarietyBox(viewModel), //for Cacao Variety
          const SizedBox(height: 10),
          _buildOtherPossibleBox(viewModel), // for Other Possible Variety
          const SizedBox(height: 10),
          _buildDescriptionBox(viewModel), // for Description
          const SizedBox(height: 10),
          _buildResultsBox(viewModel), // for Results
          const SizedBox(height: 15),
          _buildHomeButton(viewModel, context),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildVarietyBox(ResultViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              viewModel.topVariety,
              style: const TextStyle(
                fontFamily: 'CinzelDecorative',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          Center(
            child: Text(
              viewModel.topVarietyNSICNumber,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 100, 100, 100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherPossibleBox(ResultViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Variety Confidences:',
            style: TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ...viewModel.possibleVarietiesWithConfidences
              .map((v) => Text(v, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox(ResultViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description:',
            style: TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Text(
            viewModel.cacaoDescription,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBox(ResultViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Results:',
            style: TextStyle(
              fontFamily: 'CinzelDecorative',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          if (viewModel.topDisease == 'HEALTHY') ...[
            _buildInfoRow('Pod Condition:', 'Healthy'),
            const SizedBox(height: 10),
            _buildExpandableSection(viewModel),
          ] else ...[
            _buildInfoRow('Disease Type:', viewModel.topDisease),
            _buildInfoRow("Common Cause:", viewModel.topPest),
            if (viewModel.topDisease == 'Black Pod Rot')
              _buildInfoRow('Other Possible Causes:', 'P. Megakarya, P. Citrophthora, P. Capsici'),
            _buildInfoRow('Severity Level:', viewModel.severityLevel),
            const SizedBox(height: 10),
            _buildExpandableSection(viewModel),
          ],
        ],
      ),
    );
  }

    Widget _buildExpandableSection(ResultViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: viewModel.toggleExpand,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'What to do?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: 'CinzelDecorative',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(viewModel.isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        if (viewModel.isExpanded)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[300],
            child: Text(
              viewModel.recommendation,
              style: const TextStyle(fontSize: 15),
            ),
          ),
      ],
    );
  }

  Widget _buildHomeButton(ResultViewModel viewModel, BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF628E6E),
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
        ),
        onPressed: () => viewModel.goBack(context),
        child: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'CinzelDecorative',
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}