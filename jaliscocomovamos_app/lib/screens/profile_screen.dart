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

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [

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

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jane Doe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Rol: Participante'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),


            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Add settings action
              },
            ),
            const Divider(),

            const Spacer(),


            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
  
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