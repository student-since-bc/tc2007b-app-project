import 'package:flutter/material.dart';
import 'shell/main_shell.dart';
import 'widgets/placeholder_screen.dart';

import 'surveys/survey_intro.dart';
import 'surveys/survey_question.dart';
import 'surveys/survey_confirm.dart';
import 'surveys/survey_done.dart';

import 'screens/login_screen.dart';
import 'screens/donation_screen.dart';
import 'auth/login_code.dart';
import 'auth/privacy_notice.dart';

class Routes {
  static const shell = '/';
  static const loginEmail = '/login/email';
  static const loginCode = '/login/code';
  static const loginError = '/login/error';
  static const privacy = '/privacy';
  static const donation = '/donation';
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
  Routes.loginEmail: (context) => const LoginScreen(),
  Routes.loginCode: (context) => const LoginCodeScreen(),
  Routes.loginError: (context) => const PlaceholderScreen(title: 'Correo no válido'),
  Routes.privacy: (context) => const PrivacyNoticeScreen(),
  Routes.donation: (context) => const DonationScreen(),
  Routes.surveyIntro: (context) => const SurveyIntroScreen(),
  Routes.surveyQuestion: (context) => const SurveyQuestionScreen(),
  Routes.surveyConfirm: (context) => const SurveyConfirmScreen(),
  Routes.surveyDone: (context) => const SurveyDoneScreen(),
  Routes.adminHome: (context) => const PlaceholderScreen(title: 'Panel de administración'),
  Routes.surveyEditor: (context) => const PlaceholderScreen(title: 'Editar encuesta'),
  Routes.assignGroups: (context) => const PlaceholderScreen(title: 'Asignar a grupos'),
  Routes.results: (context) => const PlaceholderScreen(title: 'Resultados'),
};
