import 'package:flutter/material.dart';
import 'package:tasks/features/profile/presentation/profile_page.dart';
import 'package:tasks/features/tasks/presentation/tasks_page.dart';
import 'package:tasks/features/teams/presentation/teams_page.dart';


class HomePage extends StatefulWidget {
  final Map<String, dynamic> currentUser; // 👈 full user profile

  const HomePage({super.key, required this.currentUser,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages; // 👈 declare it

  @override
  void initState() {
    super.initState();
    _pages = [
      TasksPage(currentUser: widget.currentUser), // 👈 safe in initState
      const TeamsPage(),
      const ProfilePage(),
    ];
  }


  // الصفحات
  // final List<Widget> _pages = [
  //   TasksPage(currentUser: widget.currentUser),
  //   TeamsPage(),
  //   ProfilePage(),
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
