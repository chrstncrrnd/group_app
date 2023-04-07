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
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    const BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
  ];

  int _currentIndex = 0;

  void _onTapped(int val) {
    _currentIndex = val;
    switch (_currentIndex) {
      case 0:
        context.go("/");
        break;
      case 1:
        context.go("/search");
        break;
      case 2:
        context.go("/profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _currentIndex,
        onTap: _onTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
