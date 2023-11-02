import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded), label: "Home"),
    const BottomNavigationBarItem(
        icon: Icon(Icons.groups_2_rounded), label: "Groups"),
    const BottomNavigationBarItem(icon: Icon(Icons.add_rounded), label: "New"),
    const BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
  ];

  int _currentIndex = 0;

  void _onTapped(int val) {
    _currentIndex = val;
    switch (_currentIndex) {
      case 0:
        context.go("/feed");
        break;
      case 1:
        context.go("/groups");
        break;
      case 2:
        context.go("/new_post");
        break;
      case 3:
        context.go("/search");
        break;
      case 4:
        context.go("/profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: items,
        onTap: _onTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
