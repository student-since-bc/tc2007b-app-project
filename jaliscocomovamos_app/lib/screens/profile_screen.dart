import 'package:flutter/material.dart';
import '../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Card Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Default Grey Circle Avatar
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User Details
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juan Pérez',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Rol: Investigador'), // Participant, investigator, or guest
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Button
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Add settings action
              },
            ),
            const Divider(),

            const Spacer(), // Pushes the exit button to the bottom

            // Exit / Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigates back to the login screen
                  Navigator.of(context).pushReplacementNamed(Routes.loginEmail);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}