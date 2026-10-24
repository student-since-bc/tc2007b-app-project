import 'package:flutter/material.dart';

/// Floating circular button that opens the chatbot panel.
/// Answers are local/mock for now (no backend yet).
class ChatbotButton extends StatelessWidget {
  const ChatbotButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'chatbot',
      shape: const CircleBorder(),
      tooltip: 'Asistente',
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => const ChatbotSheet(),
      ),
      child: const Icon(Icons.chat_bubble_outline),
    );
  } // build()
} // ChatbotButton

class _Mensaje {
  final String texto;
  final bool esUsuario;

  const _Mensaje(this.texto, {required this.esUsuario});
} // _Mensaje

/// Chat panel shown inside the bottom sheet.
class ChatbotSheet extends StatefulWidget {
  const ChatbotSheet({super.key});

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
} // ChatbotSheet

class _ChatbotSheetState extends State<ChatbotSheet> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_Mensaje> _mensajes = [
    const _Mensaje(
      '¡Hola! Soy el asistente de Jalisco Cómo Vamos. ¿En qué te puedo ayudar?',
      esUsuario: false,
    ),
  ];

  static const _sugerencias = ['Encuestas', 'Datos', 'Donaciones', 'Perfil'];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  } // dispose()

  // TODO: replace with the real chatbot backend.
  String _responder(String pregunta) {
    final p = pregunta.toLowerCase();
    if (p.contains('encuesta')) {
      return 'En "Mis encuestas" puedes ver y contestar las encuestas asignadas a tu grupo.';
    }
    if (p.contains('dato')) {
      return 'En "Datos" encontrarás indicadores sobre la calidad de vida en Jalisco.';
    }
    if (p.contains('don')) {
      return 'En "Donaciones" puedes apoyar el trabajo de Jalisco Cómo Vamos.';
    }
    if (p.contains('perfil') || p.contains('cuenta')) {
      return 'En "Perfil" puedes consultar tu información y cerrar sesión.';
    }
    return 'Aún estoy aprendiendo. Prueba preguntando por encuestas, datos, donaciones o tu perfil.';
  } // _responder()

  void _enviar(String texto) {
    final t = texto.trim();
    if (t.isEmpty) return;

    setState(() {
      _mensajes.add(_Mensaje(t, esUsuario: true));
      _mensajes.add(_Mensaje(_responder(t), esUsuario: false));
    });
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  } // _enviar()

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      // Keeps the input above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.smart_toy_outlined, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text('Asistente', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _mensajes.length,
                itemBuilder: (context, i) {
                  final m = _mensajes[i];
                  return Align(
                    alignment: m.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: m.esUsuario ? scheme.primary : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        m.texto,
                        style: TextStyle(
                          color: m.esUsuario ? scheme.onPrimary : scheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sugerencias.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(_sugerencias[i]),
                  onPressed: () => _enviar(_sugerencias[i]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _enviar,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Enviar',
                    icon: const Icon(Icons.send),
                    color: scheme.primary,
                    onPressed: () => _enviar(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // build()
} // _ChatbotSheetState
