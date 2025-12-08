import 'package:flutter/material.dart';
import '../pages/senior_flow/senior_home.dart';
import '../pages/senior_flow/senior_activity.dart';
import '../pages/general/user_profile.dart';
import '../services/call_listener_service.dart';
import '../services/auth_service.dart';

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

  BottomNavigationBarItem _buildNavItem(
    Object iconOrImagePath, // Change the type to Object or dynamic
    String label,
    int index,
  ) {
    const activeColor = Color(0xFFDE7E55);
    // const activeGradient = LinearGradient(
    //   colors: [
    //     Color.fromARGB(255, 255, 203, 173),
    //     Color(0xFFDE7E55), // Starting color (your original color)
    //     // Ending color (a lighter shade for effect)
    //   ],
    //   begin: Alignment.topLeft,
    //   end: Alignment.bottomRight,
    // );
    final bool isSelected = _selectedIndex == index;

    // 1. Conditional Widget Building
    Widget iconWidget;
    if (iconOrImagePath is IconData) {
      iconWidget = Icon(iconOrImagePath, color: Colors.white);
    } else if (iconOrImagePath is String) {
      iconWidget = Image.asset(
        iconOrImagePath,
        width: 24.0,
        height: 24.0,
        color: Colors.white,
      );
    } else {
      // Fallback/Error case
      iconWidget = const SizedBox.shrink();
    }

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: isSelected
                ? BoxDecoration(
                    color: activeColor,
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
            child: iconWidget, // Use the dynamically created widget
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
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
