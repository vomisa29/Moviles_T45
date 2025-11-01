import 'package:show_hide_password/show_hide_password.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/viewModels/event_search_vm.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
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

              const SizedBox(height: 24),

              //Recommended Events
              const Text(
                "Recommended Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Recommended events list
              Column(
                children: const [
                  EventTile(title: "Mazurén Park Meeting"),
                  EventTile(title: "Cedritos Match"),
                  EventTile(title: "Football 5"),
                  EventTile(title: "Football 5"),
                  EventTile(title: "Football 5"),
                ],
              ),

              const SizedBox(height: 24),

              // 📋 All Events
              const Text(
                "All Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Column(
                children: const [
                  EventTile(title: "Mazurén Park Meeting"),
                  EventTile(title: "Cedritos Match"),
                  EventTile(title: "Football 5"),
                  EventTile(title: "Football 5"),
                  EventTile(title: "Football 5"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventTile extends StatelessWidget {
  final String title;

  const EventTile({required this.title, super.key});

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
            onPressed: () {},
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