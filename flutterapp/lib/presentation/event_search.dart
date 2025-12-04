import 'dart:developer';
import 'package:flutterapp/model/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/models/venue.dart';
import 'package:flutterapp/model/repositories/venue_repository_int.dart';
import 'package:flutterapp/presentation/viewModels/event_search_vm.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import "package:intl/intl.dart";

class EventSearch extends StatelessWidget {
  const EventSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return _EventSearchState();
  }
}


class _EventSearchState extends StatelessWidget{

  final EventSearchVm eventSearchVm = EventSearchVm();

  final _searchController = TextEditingController();

  static final formater = LengthLimitingTextInputFormatter(30);

  bool searched = false;
  Venue venueSearched = Venue(id: "1", name: "727272", latitude: 2, longitude: 2, capacity: 2, bookingCount: 1);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => eventSearchVm,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              //Search Bar
              TextField(
                onSubmitted: (value) {
                  searched=true;
                  eventSearchVm.getByName(value);
                },
                inputFormatters: [formater],                                         
                decoration: InputDecoration(
                  hintText: "Search for an event",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: _searchController,
              ),

              //EventList(eventSearchVm: eventSearchVm,loaded: eventSearchVm.loaded),
              const SizedBox(height: 24),

              // All Events
              Consumer<EventSearchVm>(
                builder: (context, eventSearchVm, _) {
                  String headerString = "All Events";

                  if(searched && eventSearchVm.event.isNotEmpty){
                    headerString = "Found an Event!";
                  }else if(!eventSearchVm.event.isNotEmpty){
                    headerString = "";
                  }
                  return  Text(
                    headerString,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      ),
                    );
                  }
              ),

              const SizedBox(height:20),

              Consumer<EventSearchVm>(
                builder: (context, eventSearchVm, _) {
                  if (!eventSearchVm.loaded) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (eventSearchVm.event.isEmpty) {
                      return Center(child: Text('There are no events available. :('));
                    }
                    log(eventSearchVm.event.toString());
                    return SizedBox(
                        height: 500,
                        child:ListView.builder(
                          itemCount: eventSearchVm.event.length,
                          itemBuilder: (BuildContext context, int index) {
                            //Event event = eventSearchVm.event[index];
                            return EventTile(title: eventSearchVm.event[index].name, event: eventSearchVm.event[index], venue: eventSearchVm.venue);
                          },
                        )
                    );
                  }
                }
              ),
              
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class EventTile extends StatelessWidget {
  final String title;
  final Event event;
  final Venue venue;

  const EventTile({required this.title,required this.event, required this.venue, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                const Icon(Icons.access_time_filled, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetail(event: event, venue: venue),
                ),
              );
            },
            child: const Text(
              "View event",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


class EventDetail extends StatelessWidget{
  final Event event;
  final Venue venue;

  const EventDetail({required this.event, required this.venue, super.key});

  @override
  Widget build(BuildContext context){
    return Card.outlined(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 40),

          Text(
            event.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_month, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(event.startTime),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Duration: ${((event.endTime.difference(event.startTime).inMinutes)/60).ceil()} hours.",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_city, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bogotá, Colombia",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.people, size: 20),
              const SizedBox(width: 8),
              Text(
                "${event.assisted?.toString() ?? event.booked.toString()}/${event.booked} Participants" ,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: event.assistanceRate ?? 1,
              minHeight: 7,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About this Event",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  "Rating del Evento: ${event.avgRating?.toString() ?? "0"}",
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}


