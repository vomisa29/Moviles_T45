import 'package:flutter/material.dart';

class FooterBar extends StatelessWidget {
  const FooterBar({
    required this.items,
    required this.currentIndex,
    this.onItemTapped,
    super.key,
  });

  final List<FooterItem> items;
  final int currentIndex;
  final ValueChanged<int>? onItemTapped;

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
            children: List.generate(items.length, (index) {
              final item = items[index];
              return FooterButton(
                item: item,
                isSelected: index == currentIndex,
                onTap: () {
                  if (onItemTapped != null) {
                    onItemTapped!(index);
                  }
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class FooterItem {
  final IconData icon;
  final String label;
  const FooterItem(this.icon, this.label);
}

class FooterButton extends StatelessWidget {
  const FooterButton({
    required this.item,
    required this.isSelected,
    this.onTap,
    super.key,
  });

  final FooterItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF31B179);
    final Color inactiveColor = const Color(0xFF9BA19B);
    final Color currentColor = isSelected ? activeColor : inactiveColor;

    return TextButton(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(const Color(0x1F31B179)),
        shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 28, color: currentColor),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              color: currentColor,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}


