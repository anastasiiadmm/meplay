import 'package:flutter/material.dart';
import 'home.dart';
import '../app_theme.dart';


class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}


class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.megaPurple,
      extendBody: true,
      body: HomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bottomBar,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: AppIcons.home, activeIcon: AppIcons.homeActive, label: 'Главная'),
          BottomNavigationBarItem(icon: AppIcons.star, activeIcon: AppIcons.starActive, label: 'Избранное'),
          BottomNavigationBarItem(icon: AppIcons.user, activeIcon: AppIcons.userActive, label: 'Профиль'),
        ],
      ),
    );
  }
}
