import 'package:flutter/material.dart';
import '../pages/senior_flow/senior_home.dart';
import '../pages/senior_flow/senior_activity.dart';
import '../pages/general/user_profile.dart';
import '../services/call_listener_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class SeniorNavBar extends StatefulWidget {
  final int initialIndex;

  const SeniorNavBar({super.key, this.initialIndex = 1});

  @override
  State<SeniorNavBar> createState() => _SeniorNavBarState();
}

class _SeniorNavBarState extends State<SeniorNavBar> {
  final AuthService authService = AuthService();

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();

    // 1. Get current user ID
    final userId = authService.getCurrentUserId();

    // 2. Start the global listener
    if (userId != null) {
      callListener.startListening(userId);
    }

    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    callListener.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const SeniorActivityPage(),
      const SeniorHomePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          _buildNavItem(Icons.menu, 'Activity', 0),
          _buildNavItem(
            Image.asset('assets/images/requestlogo.png'),
            'Request',
            1,
          ),
          _buildNavItem(Icons.person, 'Profile', 2),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF192133),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(dynamic icon, String label, int index) {
    final activeColor = AppColors.lighterOrange;
    final bool isSelected = _selectedIndex == index;

    final Color iconColor = isSelected ? Colors.white : Colors.grey;

    // 2. Conditional Widget Building
    Widget iconWidget;

    if (icon is IconData) {
      // FIX: Pass the 'iconColor' here!
      iconWidget = Icon(icon, size: 24, color: iconColor);
    } else if (icon is Widget) {
      // For images, we usually leave them as-is (original colors).
      // If you want the image to ALSO turn white/grey, wrap it in ColorFiltered.
      iconWidget = SizedBox(width: 24, height: 24, child: icon);
    } else {
      iconWidget = const SizedBox();
    }

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: isSelected
                ? BoxDecoration(
                    color: activeColor, // Background becomes Orange
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withAlpha(50),
                        spreadRadius: 5.0,
                        blurRadius: 20.0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  )
                : null,
            child: iconWidget,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 11,
              fontFamily: 'Archivo',
            ),
          ),
        ],
      ),
      label: '',
    );
  }
}
