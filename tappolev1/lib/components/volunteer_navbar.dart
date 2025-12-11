import 'package:flutter/material.dart';
import 'package:tappolev1/pages/volunteer_flow/volunteer_activity.dart';
import '../pages/volunteer_flow/volunteer_home.dart';
import '../pages/general/user_profile.dart';

class VolunteerNavBar extends StatefulWidget {
  final int initialIndex;

  const VolunteerNavBar({super.key, this.initialIndex = 1});

  @override
  State<VolunteerNavBar> createState() => _VolunteerNavBarState();
}

class _VolunteerNavBarState extends State<VolunteerNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // 2. Initialize it here!
    // This grabs the value passed from AuthGate (0) and sets it before the screen builds.
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const VolunteerActivityPage(),
      const VolunteerHomePage(),
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
      // If it's an IconData, build a standard Icon
      iconWidget = Icon(iconOrImagePath, color: Colors.white);
    } else if (iconOrImagePath is String) {
      // If it's a String, treat it as an asset path and build an Image.asset
      iconWidget = Image.asset(
        iconOrImagePath,
        width: 24.0, // Set an appropriate size for the image icon
        height: 24.0,
        color: Colors
            .white, // Optional: You might need to set a color if the image is a vector/SVG that supports color overriding, or you can omit this.
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
