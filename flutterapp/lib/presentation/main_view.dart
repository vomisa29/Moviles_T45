import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/event_search.dart';
import 'package:flutterapp/presentation/map_view.dart';
import 'package:flutterapp/presentation/viewModels/map_view_vm.dart';
import 'package:flutterapp/presentation/viewModels/create_event_vm.dart'; // Import CreateEventVm
import 'widgets/footer_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'viewModels/main_view_vm.dart';
import 'profile_view.dart';
import 'create_event_view.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapViewVm()),
        ChangeNotifierProvider(create: (_) => CreateEventVm()), // Hoist CreateEventVm here
      ],
      child: const MainViewBody(),
    );
  }
}

class MainViewBody extends StatefulWidget {
  const MainViewBody({super.key});

  @override
  State<MainViewBody> createState() => _MainViewBodyState();
}

class _MainViewBodyState extends State<MainViewBody> {

  @override
  Widget build(BuildContext context) {
    final mainVm = context.watch<MainViewVm>();

    if (mainVm.showConnectionStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showConnectivitySnackBar(mainVm.isConnected);
          mainVm.snackbarShown();
        }
      });
    }

    final selectedIndex = mainVm.selectedIndex;
    final List<Widget> pages = <Widget>[
      const MapView(),
      const EventSearch(),
      const CreateEventView(),
      const ProfileView(),
    ];

    const items = [
      FooterItem(CupertinoIcons.house_fill, 'Home'),
      FooterItem(CupertinoIcons.compass, 'Search'),
      FooterItem(CupertinoIcons.plus_circle, 'Add Event'),
      FooterItem(CupertinoIcons.person_crop_circle, 'Profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (!mainVm.isConnected)
              Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.wifi_slash, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'No Internet Connection',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                controller: mainVm.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterBar(
        items: items,
        currentIndex: selectedIndex,
        onItemTapped: mainVm.onItemTapped,
      ),
    );
  }

  void _showConnectivitySnackBar(bool isConnected) {
    if (!mounted) return;
    if (isConnected) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: "You are back online!",
        ),
      );
    }
  }
}


