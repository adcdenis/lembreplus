import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'presentation/navigation/app_router.dart';
import 'presentation/widgets/app_lifecycle_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _seedFirstRunSamples();
  runApp(const ProviderScope(child: LembrePlusApp()));
}

Future<void> _seedFirstRunSamples() async {
  final prefs = await SharedPreferences.getInstance();
  final done = prefs.getBool('first_run_seed_done') ?? false;
  if (done) return;
  final db = AppDatabase();
  final existing = await db.getAllCounters();
  if (existing.isNotEmpty) {
    await prefs.setBool('first_run_seed_done', true);
    return;
  }
  final now = DateTime.now();
  final nextYearBirthday = DateTime(now.year + 1, now.month, now.day);
  final nextMonth = DateTime(now.year, now.month + 1, now.day);
  final inTwoMonths = DateTime(now.year, now.month + 2, 15);
  final inTenDays = now.add(const Duration(days: 10));
  final inThirtyDays = now.add(const Duration(days: 30));

  await db.insertCategory(
    CategoriesCompanion.insert(name: 'Pessoal', normalized: 'pessoal'),
  );
  await db.insertCategory(
    CategoriesCompanion.insert(name: 'Saúde', normalized: 'saude'),
  );
  await db.insertCategory(
    CategoriesCompanion.insert(name: 'Financeiro', normalized: 'financeiro'),
  );
  await db.insertCategory(
    CategoriesCompanion.insert(name: 'Documentos', normalized: 'documentos'),
  );
  await db.insertCategory(
    CategoriesCompanion.insert(name: 'Veículo', normalized: 'veiculo'),
  );

  final c1Id = await db.insertCounter(
    CountersCompanion.insert(
      name: 'Aniversário',
      description: const drift.Value('Exemplo de lembrete anual'),
      eventDate: nextYearBirthday,
      category: const drift.Value('Pessoal'),
      recurrence: const drift.Value('yearly'),
      createdAt: now,
      updatedAt: const drift.Value(null),
    ),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c1Id, offsetMinutes: 10080),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c1Id, offsetMinutes: 1440),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c1Id, offsetMinutes: 120),
  );

  final c2Id = await db.insertCounter(
    CountersCompanion.insert(
      name: 'Consulta médica',
      description: const drift.Value('Exemplo de lembrete de saúde'),
      eventDate: nextMonth,
      category: const drift.Value('Saúde'),
      recurrence: const drift.Value('none'),
      createdAt: now,
      updatedAt: const drift.Value(null),
    ),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c2Id, offsetMinutes: 1440),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c2Id, offsetMinutes: 120),
  );

  final c3Id = await db.insertCounter(
    CountersCompanion.insert(
      name: 'Pagamento do cartão',
      description: const drift.Value('Exemplo de lembrete mensal'),
      eventDate: inThirtyDays,
      category: const drift.Value('Financeiro'),
      recurrence: const drift.Value('monthly'),
      createdAt: now,
      updatedAt: const drift.Value(null),
    ),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c3Id, offsetMinutes: 4320),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c3Id, offsetMinutes: 1440),
  );

  final c4Id = await db.insertCounter(
    CountersCompanion.insert(
      name: 'Renovação da CNH',
      description: const drift.Value('Exemplo de lembrete de documentos'),
      eventDate: inTwoMonths,
      category: const drift.Value('Documentos'),
      recurrence: const drift.Value('none'),
      createdAt: now,
      updatedAt: const drift.Value(null),
    ),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c4Id, offsetMinutes: 10080),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c4Id, offsetMinutes: 2880),
  );

  final c5Id = await db.insertCounter(
    CountersCompanion.insert(
      name: 'Licenciamento do veículo',
      description: const drift.Value('Exemplo de lembrete anual'),
      eventDate: inTenDays,
      category: const drift.Value('Veículo'),
      recurrence: const drift.Value('yearly'),
      createdAt: now,
      updatedAt: const drift.Value(null),
    ),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c5Id, offsetMinutes: 4320),
  );
  await db.insertAlert(
    CounterAlertsCompanion.insert(counterId: c5Id, offsetMinutes: 1440),
  );

  await db.insertCounter(
    CountersCompanion.insert(
      name: 'Data de casamento',
      description: const drift.Value('Exemplo de evento passado'),
      eventDate: DateTime(now.year - 5, now.month, now.day),
      category: const drift.Value('Pessoal'),
      recurrence: const drift.Value('none'),
      createdAt: now,
      updatedAt: const drift.Value(null),
    ),
  );

  await db.insertCounter(
    CountersCompanion.insert(
      name: 'Data de nascimento',
      description: const drift.Value('Exemplo de evento passado'),
      eventDate: DateTime(now.year - 20, now.month, now.day),
      category: const drift.Value('Pessoal'),
      recurrence: const drift.Value('none'),
      createdAt: now,
      updatedAt: const drift.Value(null),
    ),
  );

  await prefs.setBool('first_run_seed_done', true);
}

class LembrePlusApp extends StatelessWidget {
  const LembrePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleSync(
      child: MaterialApp.router(
        title: 'Lembre+',
        theme: AppTheme.light(),
        // darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: AppRouter.router,
      ),
    );
  }
}
