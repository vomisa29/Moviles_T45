import 'package:flutter/material.dart';
import 'widgets/footer_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/main_view_vm.dart';
import 'package:provider/provider.dart';

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
      FooterItem('lib/assets/SmallHomeIcon.png', 'Home'),
      FooterItem('lib/assets/SmallCompassIcon.png', 'Search'),
      FooterItem('lib/assets/SmallAddIcon.png', 'Add Event'),
      FooterItem('lib/assets/SmallUserIcon.png', 'Profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _buildMapSection(vm),
          ),
          const FooterBar(items: items),
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
