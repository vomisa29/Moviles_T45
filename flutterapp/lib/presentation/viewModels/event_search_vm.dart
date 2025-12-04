import 'package:flutterapp/model/models/event.dart';
import 'package:flutterapp/model/models/venue.dart';
import 'package:flutterapp/model/repositories/event_repository_imp.dart';
import 'package:flutterapp/model/repositories/venue_repository_imp.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventSearchVm with ChangeNotifier {
  List<Event> _event = <Event>[];
  List<Event> get event => _event;

  bool _loaded = false;
  bool get loaded => _loaded;

  Venue _venue = Venue(id: "1", name: "evento", latitude: 2, longitude: 2, capacity: 2, bookingCount: 1);
  Venue get venue => _venue;

  final EventRepositoryImplementation eventRepository = EventRepositoryImplementation(venueRepository: VenueRepositoryImplementation());


  EventSearchVm(){
    _init();
  }

  Future<void> _init() async {
    //Intento de Cache

    // final prefs = await SharedPreferences.getInstance();
    // final allEvents = prefs.get("allEvents") ?? 0;

    // if (allEvents == 0){
    //   await getAll();
    //   await prefs.setString("allEvents", eventRepository.eventListToJSON(_event));
    // }else{
    //   String? stringEvents = prefs.getString("allEvents");
    //   _event = eventRepository.jsonToEventList(stringEvents?? "");
    //   notifyListeners();
    // }

    getAll();
    
  }

  Future<void> getByName(String eventName) async{
      final bool isConnected = await InternetConnection().hasInternetAccess;
      if (isConnected){
        _loaded = false;
        notifyListeners();
        _event = await eventRepository.getByName(eventName);
        _venue = await eventRepository.getVenue(event);
        _loaded = true;
        notifyListeners();        
      }else{
        _event = <Event>[];
        _loaded = true;
        notifyListeners();
      }
      
  }

  Future<void> getAll() async{
      final bool isConnected = await InternetConnection().hasInternetAccess;
      if (isConnected){
        _loaded = false;
        notifyListeners();
        _event = await eventRepository.getAll();
        _loaded = true;
        notifyListeners();
      }else{
        _event = <Event>[];
        _loaded = true;
      }
      notifyListeners();
  }

}