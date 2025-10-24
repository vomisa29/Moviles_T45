import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/models/venue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'event_slider.dart';
import 'viewModels/map_view_vm.dart';
import 'widgets/venues_list_sheet.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapViewBody();
  }
}

class MapViewBody extends StatelessWidget {
  const MapViewBody({super.key});

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
    final vm = context.watch<MapViewVm>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.currentPosition == null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(vm.errorMessage!, textAlign: TextAlign.center),
      ));
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: vm.currentPosition ?? const LatLng(0, 0),
            zoom: 14.5,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: vm.markers,
        ),
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
                style: _buttonStyle(),
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
                style: _buttonStyle(),
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
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
