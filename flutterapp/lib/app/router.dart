import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/landing_page.dart';
import '../presentation/login.dart';
import '../presentation/main_view.dart';
import '../presentation/register.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/landing_page',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/main_view',
        builder: (context, state) => const MainView(),
      ),
      GoRoute(
        path: '/landing_page',
        builder: (context, state) => const LandingPage(),
      ),
    ],
  );
}