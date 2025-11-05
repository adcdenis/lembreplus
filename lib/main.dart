import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';

void main() {
  runApp(const ProviderScope(child: LembrePlusApp()));
}

class LembrePlusApp extends StatelessWidget {
  const LembrePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lembre+',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}
