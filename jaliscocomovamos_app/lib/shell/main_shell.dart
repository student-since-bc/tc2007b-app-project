import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';

import '../screens/data_screen.dart';
import '../screens/survey_screen.dart';
import '../screens/profile_screen.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
} // Mainshell

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _tabs = const [
    DataScreen(),
    SurveyScreen(),
    ProfileScreen(),
  ]; // tabs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: _tabs),
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: _index,
        onSelected: (i) => setState(() => _index = i),
      ), // AppNavBar
    );
  } // build()
} // MainShellState