import 'package:flutter/material.dart';
import 'shell/main_shell.dart';
import 'widgets/placeholder_screen.dart';

class Routes {
  static const shell = '/';
  static const loginEmail = '/login/email';
  static const loginCode = '/login/code';
  static const loginError = '/login/error';
  static const privacy = '/privacy';
  static const surveyIntro = '/survey/intro';
  static const surveyQuestion = '/survey/question';
  static const surveyConfirm = '/survey/confirm';
  static const surveyDone = '/survey/done';
  static const adminHome = '/admin';
  static const surveyEditor = '/admin/editor';
  static const assignGroups = '/admin/groups';
  static const results = '/admin/results';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.shell: (context) => const MainShell(),
  Routes.loginEmail: (context) => const PlaceholderScreen(title: 'Iniciar sesión'),
  Routes.loginCode: (context) => const PlaceholderScreen(title: 'Código de verificación'),
  Routes.loginError: (context) => const PlaceholderScreen(title: 'Correo no válido'),
  Routes.privacy: (context) => const PlaceholderScreen(title: 'Aviso de privacidad'),
  Routes.surveyIntro: (context) => const PlaceholderScreen(title: 'Encuesta'),
  Routes.surveyQuestion: (context) => const PlaceholderScreen(title: 'Pregunta'),
  Routes.surveyConfirm: (context) => const PlaceholderScreen(title: 'Confirmar envío'),
  Routes.surveyDone: (context) => const PlaceholderScreen(title: 'Gracias'),
  Routes.adminHome: (context) => const PlaceholderScreen(title: 'Panel de administración'),
  Routes.surveyEditor: (context) => const PlaceholderScreen(title: 'Editar encuesta'),
  Routes.assignGroups: (context) => const PlaceholderScreen(title: 'Asignar a grupos'),
  Routes.results: (context) => const PlaceholderScreen(title: 'Resultados'),
};
