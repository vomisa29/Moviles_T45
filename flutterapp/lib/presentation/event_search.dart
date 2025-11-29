import 'dart:developer';
import 'package:flutterapp/model/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/viewModels/event_search_vm.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
                },
                inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                ],
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
              const Text(
                "All Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(),

              Consumer<EventSearchVm>(
                builder: (context, eventSearchVm, _) {
                  log('Loaded: ${eventSearchVm.loaded}');
                  if (!eventSearchVm.loaded) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (eventSearchVm.event.isEmpty) {
                      return Center(child: Text('No hay eventos disponibles'));
                    }

                    return ListView.builder(
                      itemCount: eventSearchVm.event.length,
                      itemBuilder: (BuildContext context, int index) {
                        log(eventSearchVm.event.toString());
                        //Event event = eventSearchVm.event[index];
                        return EventTile(title: eventSearchVm.event[index].name, event: eventSearchVm.event[index]);
                      },
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

  const EventTile({required this.title,required this.event, super.key});

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
              EventDetail(event: event); 
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

  const EventDetail({required this.event, super.key});

  @override
  Widget build(BuildContext context){
    return Text(event.name);
  }
}