import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/models/venue.dart';
import 'package:flutterapp/presentation/viewModels/events_at_venue_vm.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/models/event.dart';

class EventsAtVenueSheet extends StatelessWidget {
  final Venue venue;
  final Function(Event) onEventSelected;

  const EventsAtVenueSheet({
    super.key,
    required this.venue,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventsAtVenueVm(venue: venue),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'Events at ${venue.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Consumer<EventsAtVenueVm>(
                    builder: (context, vm, _) {
                      if (vm.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (vm.error != null) {
                        return Center(child: Text(vm.error!));
                      }
                      if (vm.events.isEmpty) {
                        return const Center(
                          child: Text("No upcoming events at this venue."),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: vm.events.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final event = vm.events[index];
                          return _buildEventTile(context, event);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, Event event) {
    final timeFormat = DateFormat('MMM d, hh:mm a');
    final duration = event.endTime.difference(event.startTime);
    final durationString = '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';

    return ListTile(
      title: Text(
        event.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${timeFormat.format(event.startTime)}  ·  Duration: $durationString',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: const Icon(CupertinoIcons.chevron_forward),
      onTap: () {
        Navigator.of(context).pop();
        onEventSelected(event);
      },
    );
  }
}
