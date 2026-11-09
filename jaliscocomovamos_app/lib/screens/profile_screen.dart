import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _nombresRol = {'estudiante': 'Estudiante', 'admin': 'Administrador'};

  @override
  Widget build(BuildContext context) {
    // Se reconstruye cada vez que se inicia o cierra sesión
    return StreamBuilder(
      stream: AuthService.cambios,
      builder: (context, _) => FutureBuilder<Map<String, dynamic>?>(
        future: AuthService.perfil(),
        builder: (context, snapshot) => _build(context, snapshot.data),
      ),
    );
  }

  Widget _build(BuildContext context, Map<String, dynamic>? perfil) {
    final haySesion = AuthService.haySesion;
    final correo = perfil?['correo'] as String? ?? AuthService.usuario?.email;
    final rol = _nombresRol[perfil?['rol']] ?? 'Estudiante';

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

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            haySesion ? (correo ?? '') : 'Invitado',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(haySesion
                              ? 'Rol: $rol'
                              : 'Inicia sesión con tu correo @tec.mx para contestar encuestas'),
                        ],
                      ),
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
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Aviso de privacidad'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(Routes.privacy),
            ),

            const Divider(),


            const Spacer(),


            SizedBox(
              width: double.infinity,
              child: haySesion
                  ? OutlinedButton.icon(
                      onPressed: AuthService.cerrarSesion,
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    )
                  : FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.loginEmail),
                      icon: const Icon(Icons.login),
                      label: const Text('Iniciar sesión'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
