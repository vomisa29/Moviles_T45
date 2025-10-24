import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/map_view.dart';
import 'package:flutterapp/presentation/viewModels/map_view_vm.dart'; // <-- Import MapViewVm
import 'widgets/footer_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'viewModels/main_view_vm.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainViewVm()),
        ChangeNotifierProvider(create: (_) => MapViewVm()),
      ],
      child: const MainViewBody(),
    );
  }
}

class MainViewBody extends StatelessWidget {
  const MainViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final mainVm = context.read<MainViewVm>();
    final selectedIndex = context.watch<MainViewVm>().selectedIndex;

    final List<Widget> pages = <Widget>[

      const MapView(),
      const Center(child: Text('Search Page')),
      const Center(child: Text('Add Event Page')),
      const Center(child: Text('Profile Page')),
    ];

    const items = [
      FooterItem(CupertinoIcons.house_fill, 'Home'),
      FooterItem(CupertinoIcons.compass, 'Search'),
      FooterItem(CupertinoIcons.plus_circle, 'Add Event'),
      FooterItem(CupertinoIcons.person_crop_circle, 'Profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: mainVm.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: FooterBar(
        items: items,
        currentIndex: selectedIndex,
        onItemTapped: mainVm.onItemTapped,
      ),
    );
  }
}
