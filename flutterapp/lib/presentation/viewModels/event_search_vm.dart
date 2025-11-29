import 'package:flutterapp/model/models/event.dart';
import 'package:flutterapp/model/repositories/event_repository_imp.dart';
import 'package:flutterapp/model/repositories/venue_repository_imp.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class EventSearchVm with ChangeNotifier {
  List<Event> _event = <Event>[];
  List<Event> get event => _event;

  bool _loaded = false;
  bool get loaded => _loaded;

  final EventRepositoryImplementation eventRepository = EventRepositoryImplementation(venueRepository: VenueRepositoryImplementation());

  EventSearchVm(){
    _init();
  }

  Future<void> _init() async {
    getAll();
  }

  Future<void> getByName(String eventName) async{
      final bool isConnected = await InternetConnection().hasInternetAccess;
      if (isConnected){
        _loaded = false;
        notifyListeners();
        _event = await eventRepository.getByName(eventName);
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

  Future<void> getRecomended(String eventName) async{
      //TODO
  }

}