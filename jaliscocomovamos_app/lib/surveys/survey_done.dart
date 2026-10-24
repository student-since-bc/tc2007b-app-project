import 'package:flutter/material.dart';
import '../mock/mock_data.dart';

class SurveyDoneScreen extends StatelessWidget {
  const SurveyDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 96,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Gracias!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  Textos.respuestaAnonima,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Button back to the list
                FilledButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Volver a mis encuestas'),
                ),
              ], // children
            ),
          ),
        ),
      ),
    );
  } // build()
} // SurveyDoneScreen