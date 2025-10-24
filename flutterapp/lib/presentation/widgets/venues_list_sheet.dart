import 'package:flutter/material.dart';
import '../../model/models/venue.dart';

class VenuesListSheet extends StatelessWidget {
  final List<Venue> venues;

  const VenuesListSheet({super.key, required this.venues});

  @override
  Widget build(BuildContext context) {

    final sortedVenues = List<Venue>.from(venues)
      ..sort((a, b) => b.bookingCount.compareTo(a.bookingCount));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
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
              const Text(
                'Top Venues',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: sortedVenues.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final venue = sortedVenues[index];
                    return ListTile(
                      title: Text(
                        venue.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        'Booked ${venue.bookingCount} times',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
