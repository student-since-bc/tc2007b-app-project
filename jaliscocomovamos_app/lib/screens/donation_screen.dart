import 'package:flutter/material.dart';
import '../mock/mock_data.dart'; // Textos.avisoSalidaDonacion

/// Donation screen (navigation only for now).
/// The button does NOT open any external page yet.
class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Donaciones')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 72,
            color: theme.colorScheme.primary,
            semanticLabel: 'Donaciones',
          ),
          const SizedBox(height: 24),
          Text(
            'Apoya a Jalisco Cómo Vamos', // TODO: final copy from JCV
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text(Textos.avisoSalidaDonacion)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // TODO: open the real donation URL once JCV confirms it.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente')),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Donar'),
          ),
        ],
      ),
    );
  } // build()
} // DonationScreen
