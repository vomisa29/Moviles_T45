import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/models/event.dart';
import '../model/models/venue.dart';
import 'viewModels/event_slider_vm.dart';

class EventSlider extends StatefulWidget {
  const EventSlider({
    required this.event,
    required this.onClose,
    super.key,
  });

  final Event event;
  final VoidCallback onClose;

  @override
  State<EventSlider> createState() => _EventSliderState();
}

class _EventSliderState extends State<EventSlider> {
  final DraggableScrollableController _controller = DraggableScrollableController();

  static const double _minChildSize = 0.15;
  static const double _initialChildSize = 0.55;
  static const double _maxChildSize = 0.90;
  static const double _epsilon = 0.01;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeClose);
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeClose);
    _controller.dispose();
    super.dispose();
  }

  void _maybeClose() {
    if (_controller.size <= (_minChildSize + _epsilon)) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey(widget.event.id),
      create: (_) => EventSliderVm(event: widget.event),
      child: Consumer<EventSliderVm>(
        builder: (context, vm, _) {
          final media = MediaQuery.of(context);
          final spacing = media.size.height * 0.015;
          final hp = media.size.width * 0.04;
          final handleW = media.size.width * 0.10;
          final handleH = media.size.height * 0.004;
          final iconSize = media.size.width * 0.06;

          return DraggableScrollableSheet(
            controller: _controller,
            initialChildSize: _initialChildSize,
            minChildSize: _minChildSize,
            maxChildSize: _maxChildSize,
            snap: true,
            snapSizes: const [_minChildSize, 0.55, _maxChildSize],
            builder: (context, scrollController) {
              return Material(
                elevation: 12,
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Scrollbar(
                  controller: scrollController,
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _PinnedHeaderDelegate(
                          minExtent: spacing * 2.2,
                          maxExtent: spacing * 2.2,
                          builder: (context, shrinkOffset, overlapsContent) {
                            return Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: hp),
                              child: Row(
                                children: [
                                  Container(
                                    width: handleW,
                                    height: handleH,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(CupertinoIcons.xmark_circle),
                                    color: const Color(0xFF9BA19B),
                                    tooltip: 'Close',
                                    onPressed: widget.onClose,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(hp, spacing, hp, spacing),
                            child: Builder(
                                builder: (context) {
                                  if (vm.isLoading) {
                                    return SizedBox(
                                      height: media.size.height * 0.25,
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  } else if (vm.error != null) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: spacing),
                                      child: Center(
                                        child: Text(
                                          vm.error!,
                                          style: const TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  } else if (vm.venue == null) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: spacing),
                                      child: const Center(child: Text('No venue info.')),
                                    );
                                  } else {
                                    return _EventCardContents(
                                      event: vm.event,
                                      venue: vm.venue!,
                                      spacing: spacing,
                                      iconSize: iconSize,
                                    );
                                  }
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
  });

  @override
  final double minExtent;
  @override
  final double maxExtent;

  final Widget Function(BuildContext, double shrinkOffset, bool overlapsContent) builder;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        builder != oldDelegate.builder;
  }
}

class _EventCardContents extends StatelessWidget {
  const _EventCardContents({
    required this.event,
    required this.venue,
    required this.spacing,
    required this.iconSize,
  });

  final Event event;
  final Venue venue;
  final double spacing;
  final double iconSize;

  String _formatDate(DateTime dt) =>
      "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";

  String _formatTimeRange(DateTime start, DateTime end) {
    final durH = end.difference(start).inMinutes / 60.0;
    final h = durH.toStringAsFixed(1).replaceAll('.0', '');
    return "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} · $h hours";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const green = Color(0xFF31B179);
    const grey = Color(0xFF9BA19B);
    final media = MediaQuery.of(context);

    final booked = event.booked;
    final max = event.maxCapacity;
    final progress = (max > 0) ? (booked / max).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event', style: theme.textTheme.labelMedium?.copyWith(color: grey)),
        SizedBox(height: spacing * 0.6),
        Text(
          event.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: spacing),

        Row(
          children: [
            Icon(CupertinoIcons.calendar, color: const Color(0xFFEA6D65), size: iconSize),
            SizedBox(width: spacing),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(event.startTime), style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(_formatTimeRange(event.startTime, event.endTime), style: const TextStyle(color: grey)),
              ],
            ),
          ],
        ),
        SizedBox(height: spacing),

        Row(
          children: [
            Icon(CupertinoIcons.location_solid, color: const Color(0xFFEA6D65), size: iconSize),
            SizedBox(width: spacing),
            Expanded(
              child: Text(
                venue.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),

        Row(
          children: [
            Icon(CupertinoIcons.person_3_fill, color: const Color(0xFFEA6D65), size: iconSize),
            SizedBox(width: spacing),
            Text('$booked/$max participants', style: const TextStyle(fontWeight: FontWeight.w700)),
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

        Row(
          children: [
            Icon(CupertinoIcons.number, color: const Color(0xFFEA6D65), size: iconSize),
            SizedBox(width: spacing),
            const Text('Times booked', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(width: spacing),
            Text('${venue.bookingCount}', style: const TextStyle(color: grey)),
          ],
        ),
        SizedBox(height: spacing * 1.5),

        SizedBox(
          width: double.infinity,
          height: media.size.height * 0.06,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              //aqui ponemos para registrarse al evento luego
            },
            child: const Text('Reserve'),
          ),
        ),
      ],
    );
  }
}

