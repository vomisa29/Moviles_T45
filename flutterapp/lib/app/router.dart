import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/landing_page.dart';
import '../presentation/login.dart';
import '../presentation/main_view.dart';
import '../presentation/register.dart';
import 'auth_notifier.dart';

GoRouter createRouter(AuthNotifier authNotifier) {
  return GoRouter(

    refreshListenable: authNotifier,

    initialLocation: '/main_view',

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

    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authNotifier.isLoggedIn;

      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';


      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/main_view';
      }

      return null;
    },
  );
}
