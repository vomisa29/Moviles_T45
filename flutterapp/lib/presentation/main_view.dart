import 'package:flutter/material.dart';
import 'widgets/footer_bar.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      FooterItem('lib/assets/SmallHomeIcon.png', 'Home'),
      FooterItem('lib/assets/SmallCompassIcon.png', 'Search'),
      FooterItem('lib/assets/SmallAddIcon.png', 'Add Event'),
      FooterItem('lib/assets/SmallUserIcon.png', 'Profile'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          //Aqui ya pongo el mapa
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'Map will be displayed here',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            ),
          ),
          const FooterBar(items: items),
        ],
      ),
    );
  }
}
