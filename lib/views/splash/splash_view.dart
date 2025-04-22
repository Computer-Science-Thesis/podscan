import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: const _SplashViewBody(),
    );
  }
}

class _SplashViewBody extends StatefulWidget {
  const _SplashViewBody();

  @override
  State<_SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<_SplashViewBody> {
  @override
  void initState() {
    super.initState();

    // Call after widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SplashViewModel>().initializeApp(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Color(0xFF832637), // Set background color
      body: SafeArea(child: _buildLogo()),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 120,
        ),
        const SizedBox(width: 10),
        // _buildDivider(),
        const SizedBox(width: 10),
        _buildAppTitle(),
      ],
    );
  }

  Widget _buildAppTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'CinzelDecorative', // Apply custom font
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: 'POD',
            style: TextStyle(
              color: Color(0xFF7ED957), // Green color for "POD"
            ),
          ),
          TextSpan(
            text: 'SCAN',
            style: TextStyle(
              color: Color(0xFFFFDE59), // Yellow color for "SCAN"
            ),
          ),
        ],
      ),
    );
  }
}