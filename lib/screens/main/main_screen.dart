import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/screens/home/home_screen.dart';
import 'package:woodline/screens/explore/explore_screen.dart';
import 'package:woodline/screens/orders/orders_screen.dart';
import 'package:woodline/screens/chat/chat_list_screen.dart';
import 'package:woodline/screens/profile/profile_screen.dart';
import 'package:woodline/theme/app_colors.dart';
import 'package:woodline/widgets/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const OrdersScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}