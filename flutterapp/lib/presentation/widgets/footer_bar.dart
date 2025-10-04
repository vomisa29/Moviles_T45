import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FooterBar extends StatelessWidget {
  const FooterBar({required this.items, super.key});

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
              return FooterButton(
                item: e,
                onTap: () {
                  //Eventualmente navegacion aca
                },
              );
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
  const FooterButton({required this.item, this.onTap, super.key});

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
              item.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF9BA19B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
