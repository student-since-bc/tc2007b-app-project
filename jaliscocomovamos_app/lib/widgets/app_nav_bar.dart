import 'package:flutter/material.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  }); // AppNavBar()

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      destinations: const [
        // Button 0: Consultas
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Consultas',
        ),
        // Button 1: Encuestas
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Encuestas',
        ),
        // Button 2: Jalisco Cómo Vamos (incluye donaciones)
        NavigationDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: 'JCV',
          tooltip: 'Jalisco Cómo Vamos',
        ),
        // Button 3: Perfil
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ], // Destinations
    );
  } // build()
} // AppNavBar