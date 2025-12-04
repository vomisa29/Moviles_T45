import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/presentation/viewModels/attendees_list_vm.dart';
import 'package:provider/provider.dart';

class AttendeesListDialog extends StatelessWidget {
  final String eventId;

  const AttendeesListDialog({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendeesListVm(eventId: eventId),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Who's Going?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: Consumer<AttendeesListVm>(
              builder: (context, vm, _) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.error != null) {
                  return Center(child: Text(vm.error!));
                }

                if (vm.attendees.isEmpty) {
                  return const Center(child: Text("No one has booked this event yet."));
                }

                return ListView.builder(
                  itemCount: vm.attendees.length,
                  itemBuilder: (context, index) {
                    final user = vm.attendees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: CachedNetworkImageProvider(
                          user.avatarUrl ?? 'https://i.imgur.com/w3UEu8o.jpeg',
                        ),
                      ),
                      title: Text(
                        user.username ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
