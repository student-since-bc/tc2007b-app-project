import 'package:flutter/material.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/chatbot_button.dart';

import '../screens/data_screen.dart';
import '../screens/survey_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/jcv_screen.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
} // Mainshell

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const DataScreen(),
      SurveyScreen(onVerResultados: () => setState(() => _index = 0)),
      const JcvScreen(),
      const ProfileScreen(),
    ]; // tabs

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: tabs),
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: _index,
        onSelected: (i) => setState(() => _index = i),
      ), // AppNavBar
      // Default endFloat location: bottom-right, just above the nav bar.
      floatingActionButton: const ChatbotButton(),
    );
  } // build()
} // MainShellState