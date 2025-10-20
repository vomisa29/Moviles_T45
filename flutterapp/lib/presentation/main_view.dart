import 'package:flutter/material.dart';
import 'package:flutterapp/model/models/venue.dart';
import 'widgets/footer_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'viewModels/main_view_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'event_slider.dart';
import 'widgets/venues_list_sheet.dart';

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
  const MainViewBody({super.key});

  void _showVenuesSheet(BuildContext context, List<Venue> venues) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VenuesListSheet(venues: venues),
    );
  }

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
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(CupertinoIcons.sportscourt),
                        label: const Text('Venues'),
                        onPressed: () => _showVenuesSheet(context, vm.allVenues),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: Icon(vm.filterState == EventFilterState.nearby
                            ? CupertinoIcons.globe
                            : CupertinoIcons.location_solid),
                        label: Text(vm.filterState == EventFilterState.nearby
                            ? 'Show All'
                            : 'Show Nearby'),
                        onPressed: vm.toggleEventFilter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
