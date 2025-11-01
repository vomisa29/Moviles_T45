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
  bool get isConnected => _isConnected;
  bool get showConnectionStatus => _showConnectionStatus;

  MainViewVm(ConnectivityNotifier connectivity) : _isConnected = connectivity.isConnected;

  void updateConnectivity(ConnectivityNotifier connectivity) {
    if (_isFirstLoad) {
      _isConnected = connectivity.isConnected;
      _isFirstLoad = false;
      return;
    }

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

