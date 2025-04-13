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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FlutterLogo(size: 80),
              const SizedBox(height: 16),
              Text("Loading...", style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ]
          ),
        ),
      ),
    );
  }
}