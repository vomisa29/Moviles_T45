import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/auth_notifier.dart';
import '../model/models/event.dart';
import 'event_slider.dart';
import 'viewModels/profile_view_vm.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _showLogoutConfirmation(BuildContext context, ProfileViewVm vm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("Log Out"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                vm.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthNotifier>().user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please log in to see your profile."),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ProfileViewVm(userId),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFBF8),
        body: Consumer<ProfileViewVm>(
          builder: (context, vm, child) {
            switch (vm.state) {
              case ProfileState.loading:
                return const Center(child: CircularProgressIndicator());
              case ProfileState.error:
                return Center(child: Text(vm.errorMessage ?? "An unknown error occurred."));
              case ProfileState.notConfigured:
                return _buildNotConfiguredView(context, vm);
              case ProfileState.ready:
                if (vm.user == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildProfileReadyView(context, vm);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNotConfiguredView(BuildContext context, ProfileViewVm vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You haven't configured your profile yet!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38B480),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => vm.navigateToConfiguration(context),
              child: const Text("Configure now!"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileReadyView(BuildContext context, ProfileViewVm vm) {
    final theme = Theme.of(context).textTheme;
    const greenColor = Color(0xFF38B480);
    final user = vm.user!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("User Profile", style: theme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'Log Out',
                  onPressed: () => _showLogoutConfirmation(context, vm),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.avatarUrl ?? 'https://i.imgur.com/w3UEu8o.jpeg'),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username!, style: theme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: user.sportList!.map((sport) => _buildChip(sport, _getSportIcon(sport))).toList(),
                      ),
                      const SizedBox(height: 8),
                      if (user.avgRating != null)
                        _buildStarRating(user.avgRating!)
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "This user doesn't have a rating yet",
                            style: theme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        user.description!,
                        style: theme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => vm.navigateToConfiguration(context),
                child: const Text("Edit Profile"),
              ),
            ),
            const SizedBox(height: 32),
            Text("Upcoming Events", style: theme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildEventsList(context, vm.upcomingEvents, greenColor, "You don't have any upcoming events."),
            const SizedBox(height: 32),
            Text("Posted Events", style: theme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildEventsList(context, vm.postedEvents, greenColor, "You haven't posted any events yet."),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, List<Event> events, Color color, String emptyMessage) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(emptyMessage, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      );
    }
    final vm = context.read<ProfileViewVm>();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isUpcoming = event.startTime.isAfter(DateTime.now());
        return _buildEventItem(context, event, isUpcoming, color, vm);
      },
    );
  }

  Widget _buildEventItem(BuildContext context, Event event, bool isUpcoming, Color color, ProfileViewVm vm) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(isUpcoming ? CupertinoIcons.check_mark_circled : CupertinoIcons.time,
              color: isUpcoming ? Colors.green : Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(dateFormat.format(event.startTime), style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (builderContext) => EventSlider(
                  event: event,
                  onClose: () => Navigator.pop(builderContext),
                  onBookingChanged: () {
                    vm.loadData();
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("View event"),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.sports;
    }
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.black54),
      label: Text(label),
      backgroundColor: Colors.white,
      shape: const StadiumBorder(side: BorderSide(color: Colors.black26)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}
