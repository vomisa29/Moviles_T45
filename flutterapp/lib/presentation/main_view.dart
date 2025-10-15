import 'package:flutter/material.dart';
import 'widgets/footer_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/main_view_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'event_slider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewVm(),
      child: const MainViewBody(),
    );
  }
}

class MainViewBody extends StatelessWidget {
  const MainViewBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewVm>();

    const items = [
      FooterItem(CupertinoIcons.house_fill, 'Home'),
      FooterItem(CupertinoIcons.compass, 'Search'),
      FooterItem(CupertinoIcons.plus_circle, 'Add Event'),
      FooterItem(CupertinoIcons.person_crop_circle, 'Profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildMapSection(vm),
                if (vm.selectedEvent != null)
                  EventSlider(
                    key: ValueKey(vm.selectedEvent!.id),
                    event: vm.selectedEvent!,
                    onClose: vm.clearSelection,
                  ),
              ],
            ),
          ),
          const FooterBar(items: items, currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildMapSection(MainViewVm vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(child: Text(vm.errorMessage!));
    }

    if (vm.currentPosition == null) {
      return const Center(child: Text("Location unavailable"));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: vm.currentPosition!,
        zoom: 14.5,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: vm.markers,
    );
  }
}
