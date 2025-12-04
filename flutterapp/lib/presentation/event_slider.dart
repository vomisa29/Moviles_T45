import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../app/auth_notifier.dart';
import '../model/models/event.dart';
import '../model/models/venue.dart';
import 'viewModels/main_view_vm.dart';
import 'viewModels/event_slider_vm.dart';
import 'widgets/attendees_list_dialog.dart';

class EventSlider extends StatefulWidget {
  const EventSlider({
    required this.event,
    required this.onClose,
    this.onBookingChanged,
    super.key,
  });

  final Event event;
  final VoidCallback onClose;
  final VoidCallback? onBookingChanged;

  @override
  State<EventSlider> createState() => _EventSliderState();
}

class _EventSliderState extends State<EventSlider> {
  final DraggableScrollableController _controller = DraggableScrollableController();

  static const double _minChildSize = 0.15;
  static const double _initialChildSize = 0.55;
  static const double _maxChildSize = 0.90;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.size <= _minChildSize + 0.01) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _initialChildSize,
      minChildSize: _minChildSize,
      maxChildSize: _maxChildSize,
      snap: true,
      snapSizes: const [_minChildSize, _initialChildSize, _maxChildSize],
      builder: (context, scrollController) {
        return _EventContent(
          event: widget.event,
          onClose: widget.onClose,
          scrollController: scrollController,
          onBookingChanged: widget.onBookingChanged,
        );
      },
    );
  }
}

class _EventContent extends StatelessWidget {
  const _EventContent({
    required this.event,
    required this.onClose,
    required this.scrollController,
    this.onBookingChanged,
  });

  final Event event;
  final VoidCallback onClose;
  final ScrollController scrollController;
  final VoidCallback? onBookingChanged;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthNotifier>().user?.uid;

    return ChangeNotifierProvider(
      key: ValueKey(event.id),
      create: (_) => EventSliderVm(event: event, currentUserId: currentUserId),
      child: Material(
        elevation: 12,
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _SheetHandle(onClose: onClose),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Consumer<EventSliderVm>(
                    builder: (context, vm, _) {
                      if (vm.isLoading) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (vm.error != null && !vm.isBooking) {
                        return Center(child: Text(vm.error!, style: const TextStyle(color: Colors.red)));
                      }
                      if (vm.venue == null) {
                        return const Center(child: Text('Venue information not found.'));
                      }
                      return _EventDetails(
                          event: vm.event,
                          venue: vm.venue!,
                          onBookingChanged: onBookingChanged);
                    },
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

class _EventDetails extends StatelessWidget {
  const _EventDetails({required this.event, required this.venue, this.onBookingChanged});

  final Event event;
  final Venue venue;
  final VoidCallback? onBookingChanged;

  String _formatDate(DateTime dt) => "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  String _formatTimeRange(DateTime start, DateTime end) {
    final durH = end.difference(start).inMinutes / 60.0;
    final h = durH.toStringAsFixed(1).replaceAll('.0', '');
    return "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} · $h hours";
  }

  @override
  Widget build(BuildContext context) {
    final sliderVm = context.watch<EventSliderVm>();
    final authNotifier = context.watch<AuthNotifier>();
    final mainVm = context.watch<MainViewVm>();
    final isConnected = mainVm.isConnected;

    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    const green = Color(0xFF31B179);
    const red = Colors.red;
    const blue = Colors.blueAccent;
    final hp = media.size.width * 0.04;
    final spacing = media.size.height * 0.015;
    final iconSize = media.size.width * 0.06;
    final progress = (event.maxCapacity > 0) ? (event.booked / event.maxCapacity).clamp(0.0, 1.0) : 0.0;

    final bool isReserved = sliderVm.isReserved;
    final bool isOrganizer = sliderVm.isOrganizer;
    final bool canInteract = authNotifier.isLoggedIn;

    Color buttonColor;
    String buttonText;
    VoidCallback? onPressedAction;

    if (isOrganizer) {
      buttonColor = blue;
      buttonText = 'Edit Event';
      onPressedAction = () => context.push('/edit_event_view', extra: event);
    } else {
      if (isReserved) {
        buttonColor = red;
        buttonText = 'Cancel Booking';
      } else {
        buttonColor = green;
        buttonText = 'Reserve';
      }
      onPressedAction = () async {
        await sliderVm.handleBooking(authNotifier.user?.uid);
        if (sliderVm.error == null) {
          onBookingChanged?.call();
        }
      };
    }

    if (!canInteract || !isConnected) {
      onPressedAction = null;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event', style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF9BA19B))),
          SizedBox(height: spacing * 0.6),
          Text(event.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: spacing),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _InfoRow(icon: CupertinoIcons.calendar, text: _formatDate(event.startTime), subText: _formatTimeRange(event.startTime, event.endTime), iconSize: iconSize),
                    SizedBox(height: spacing),
                    _InfoRow(icon: CupertinoIcons.location_solid, text: venue.name, iconSize: iconSize),
                    SizedBox(height: spacing),
                    _InfoRow(icon: CupertinoIcons.person_3_fill, text: '${event.booked}/${event.maxCapacity} participants', iconSize: iconSize),
                  ],
                ),
              ),

              if (!isOrganizer && canInteract) const SizedBox(width: 16),

              if (!isOrganizer && canInteract)
                Expanded(
                  flex: 2,
                  child: _buildAffinityScore(context, sliderVm, isConnected),
                ),
            ],
          ),
          SizedBox(height: spacing * 0.4),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: media.size.height * 0.008,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor: const AlwaysStoppedAnimation<Color>(green),
            ),
          ),
          SizedBox(height: spacing),

          Text(event.description, style: theme.textTheme.bodyMedium, maxLines: 5, overflow: TextOverflow.ellipsis),
          SizedBox(height: spacing * 1.5),


          if (isOrganizer || isReserved) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(CupertinoIcons.group),
                label: const Text("See Who's Attending"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black54,
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AttendeesListDialog(eventId: event.id);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],


          SizedBox(
            width: double.infinity,
            height: media.size.height * 0.06,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: onPressedAction == null ? Colors.grey[400] : buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: sliderVm.isBooking ? null : onPressedAction,
              child: sliderVm.isBooking
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(buttonText),
            ),
          ),
          if (!isConnected && !isOrganizer)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  "Connect to the internet to calculate affinity and manage bookings.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          SizedBox(height: spacing * 2),
        ],
      ),
    );
  }

  Widget _buildAffinityScore(BuildContext context, EventSliderVm vm, bool isConnected) {
    if (!isConnected && vm.affinityScore == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.wifi_slash, size: 24, color: Colors.grey),
          SizedBox(height: 6),
          Text(
            'Affinity offline',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    }

    if (vm.isLoadingAffinity) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
          SizedBox(height: 8),
          Text(
            'Calculating...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    }

    if (vm.affinityScore == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.question_circle, size: 24, color: Colors.grey),
          SizedBox(height: 6),
          Text(
            'Cannot calculate',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    }

    final scorePercent = (vm.affinityScore! * 100).toInt();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Your Affinity", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: vm.affinityScore,
                strokeWidth: 5,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color.lerp(Colors.orange, Colors.green, vm.affinityScore!)!),
              ),
            ),
            Text('$scorePercent%', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.subText, required this.iconSize});
  final IconData icon;
  final String text;
  final String? subText;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFEA6D65), size: iconSize),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              if (subText != null)
                Text(subText!, style: const TextStyle(color: Color(0xFF9BA19B))),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            color: const Color(0xFF9BA19B),
            tooltip: 'Close',
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
