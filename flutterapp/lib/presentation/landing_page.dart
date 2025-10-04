import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),

      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'lib/assets/Logo_app_SportLink.png',
              width: 320,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('LoginPage'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.go('/main_view');
                  },
                  child: const Text('MainView '),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
