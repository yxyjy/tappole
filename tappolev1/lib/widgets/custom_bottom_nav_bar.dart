import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const Color _navBackground = Color(0xFF192133);
  static const Color _activeAccent = Color(0xFFDE7E55);
  static const Color _iconAndText = Colors.white;

  @override
  Widget build(BuildContext context) {
    final List<_NavItemData> items = const <_NavItemData>[
      _NavItemData(label: 'Activity', icon: Icons.history_rounded),
      _NavItemData(label: 'Request', icon: Icons.request_page_rounded),
      _NavItemData(label: 'Profile', icon: Icons.person_rounded),
    ];

    return Material(
      color: _navBackground,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: List.generate(items.length, (int index) {
              final bool selected = index == currentIndex;
              return Expanded(
                child: _NavItem(
                  data: items[index],
                  selected: selected,
                  onTap: () => onTabSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  static const Color _activeAccent = Color(0xFFDE7E55);
  static const Color _iconAndText = Colors.white;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected ? _activeAccent : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: _activeAccent.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(
              data.icon,
              color: _iconAndText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: const TextStyle(
              color: _iconAndText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;

  const _NavItemData({
    required this.label,
    required this.icon,
  });
}
