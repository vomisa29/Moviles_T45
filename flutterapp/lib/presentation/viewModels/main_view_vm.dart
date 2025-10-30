import 'package:flutter/material.dart';
import 'package:flutterapp/app/connectivity_notifier.dart';

class MainViewVm extends ChangeNotifier {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  bool _isConnected;
  bool _showConnectionStatus = false;
  bool _isFirstLoad = true;

  int get selectedIndex => _selectedIndex;
  PageController get pageController => _pageController;
  // Getter is no longer nullable
  bool get isConnected => _isConnected;
  bool get showConnectionStatus => _showConnectionStatus;

  // Constructor now takes the notifier and sets the initial state
  MainViewVm(ConnectivityNotifier connectivity) : _isConnected = connectivity.isConnected;

  // ProxyProvider will call this method on every update of ConnectivityNotifier
  void updateConnectivity(ConnectivityNotifier connectivity) {
    // If it's the first run after creation, don't trigger the snackbar
    if (_isFirstLoad) {
      _isConnected = connectivity.isConnected;
      _isFirstLoad = false;
      return; // Exit early
    }

    // For subsequent changes, update the state and show the snackbar
    if (_isConnected != connectivity.isConnected) {
      _isConnected = connectivity.isConnected;
      _showConnectionStatus = true;
      notifyListeners();
    }
  }

  void onPageChanged(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void onItemTapped(int index) {
    _selectedIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void snackbarShown() {
    _showConnectionStatus = false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

