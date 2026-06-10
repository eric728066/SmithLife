import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/token_storage.dart';
import '../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final hasToken = await TokenStorage.hasToken();
    if (mounted) {
      context.go(hasToken ? '/home' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.orangeBg,
      body: Center(
        child: Text(
          'SMITHLIFE',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
