import 'package:flutter/material.dart';
import '../pages/senior_flow/senior_home.dart';
import '../pages/senior_flow/senior_activity.dart';

class SeniorNavBar extends StatefulWidget {
  const SeniorNavBar({super.key});

  @override
  State<SeniorNavBar> createState() => _SeniorNavBarState();
}

class _SeniorNavBarState extends State<SeniorNavBar> {
  int _selectedIndex = 1;

  // Placeholder pages
  static final List<Widget> _widgetOptions = <Widget>[
    const SeniorActivityPage(),
    const SeniorHomePage(),
    const Text('Profile Page'), // Placeholder for Profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          _buildNavItem(Icons.local_activity, 'Activity', 0),
          _buildNavItem(Icons.request_page, 'Request', 1),
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
    IconData icon,
    String label,
    int index,
  ) {
    const activeColor = Color(0xFFDE7E55);
    final bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
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
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
      label: '', // The label is handled by the custom Column
    );
  }
}
