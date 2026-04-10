import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/presentation/pages/backup_page.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Tela de backup arquivo exibe conteúdo principal', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.test();
    addTearDown(() async => db.close());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: Scaffold(body: BackupPage())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Backup'), findsWidgets);
    expect(
      find.text('Exportar e importar dados locais (JSON, compatível com nuvem: inclui alertas).'),
      findsOneWidget,
    );
    expect(find.text('Exportar para JSON'), findsOneWidget);
    expect(find.text('Importar de JSON'), findsOneWidget);
  });
}
