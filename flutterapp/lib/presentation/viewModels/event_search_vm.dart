import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutterapp/model/models/event.dart';
import 'package:flutterapp/model/repositories/event_repository_imp.dart';
import 'package:flutterapp/model/repositories/venue_repository_imp.dart';
import 'package:flutterapp/model/serviceAdapters/auth_adapter.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:is_valid/is_valid.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class EventSearchVm with ChangeNotifier {
  List<Event> _event = "";
  List<Event> get event => _event;

  final EventRepositoryImplementation eventRepository = EventRepositoryImplementation(venueRepository: VenueRepositoryImplementation());


  Future<List<Event>> search(String eventName) async{
      final bool isConnected = await InternetConnection().hasInternetAccess;
      if (isConnected){
        return eventRepository.getByName(eventName);
      }
      
  }
}