import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app/router.dart';
import 'app/auth_notifier.dart';
import 'package:go_router/go_router.dart';
import 'app/connectivity_notifier.dart';
import 'presentation/viewModels/main_view_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  final authNotifier = AuthNotifier();

  final router = createRouter(authNotifier);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authNotifier),
        ChangeNotifierProvider(create: (_) => ConnectivityNotifier()),
        ChangeNotifierProxyProvider<ConnectivityNotifier, MainViewVm>(
          create: (context) => MainViewVm(context.read<ConnectivityNotifier>()),
          update: (context, connectivity, previousVm) =>
          previousVm!..updateConnectivity(connectivity),
        ),
      ],
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SportLink',
      debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}

