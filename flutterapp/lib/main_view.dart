import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    const pinAsset = 'lib/Images/Logo_app_SportLink_Small.png';
    const pinSize = 100.0;
    const items = [
      FooterItem('lib/Images/SmallHomeIcon.png', 'Home'),
      FooterItem('lib/Images/SmallCompassIcon.png', 'Search'),
      FooterItem('lib/Images/SmallAddIcon.png', 'Add Event'),
      FooterItem('lib/Images/SmallUserIcon.png', 'Profile'),
    ];

    return Scaffold(

      backgroundColor: Colors.white,
      body: Column(
        children: [

      Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'lib/Images/MapImage.png',
                  fit: BoxFit.cover,
                ),

                Align(
                  alignment: const Alignment(-0.80, -0.70),
                  child: Image.asset(pinAsset, width: pinSize, height: pinSize),
                ),
                Align(
                  alignment: const Alignment(0.70, -0.55),
                  child: Image.asset(pinAsset, width: pinSize, height: pinSize),
                ),
                Align(
                  alignment: const Alignment(-0.55, 0.10),
                  child: Image.asset(pinAsset, width: pinSize, height: pinSize),
                ),
                Align(
                  alignment: const Alignment(0.00, 0.60),
                  child: Image.asset(pinAsset, width: pinSize, height: pinSize),
                ),
                Align(
                  alignment: const Alignment(0.85, 0.20),
                  child: Image.asset(pinAsset, width: pinSize, height: pinSize),
                ),
              ],
            ),
          ),
          FooterBar(items: items),
        ],
      ),
    );
  }
}

class FooterBar extends StatelessWidget {
  const FooterBar({required this.items});

  final List<FooterItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((e) {
              return FooterButton(item: e, onTap: () {
                //aqui eventualmente ponemos logica de navegacion
              });
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class FooterItem {
  final String assetPath;
  final String label;
  const FooterItem(this.assetPath, this.label);
}

class FooterButton extends StatelessWidget {
  const FooterButton({required this.item, this.onTap});

  final FooterItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              item.assetPath,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              item.label, style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF9BA19B), fontWeight: FontWeight.w700
              ),
            ),
          ],
        ),
      ),
    );
  }
}
