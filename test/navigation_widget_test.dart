import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lembreplus/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/state/providers.dart';

void main() {
  testWidgets('Navegação via Drawer para Backup', (WidgetTester tester) async {
    final db = AppDatabase.test();
    addTearDown(() async => db.close());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const LembrePlusApp(),
      ),
    );

    // Garantir que existe o título no AppBar
    expect(find.text('Lembre+'), findsWidgets);

    // Abrir o Drawer tocando no botão de menu (tooltip localizável)
    final BuildContext scaffoldContext = tester.element(find.byType(Scaffold).first);
    final localizations = MaterialLocalizations.of(scaffoldContext);
    await tester.tap(find.byTooltip(localizations.openAppDrawerTooltip));
    await tester.pumpAndSettle();

    // Tap em "Backup"
    await tester.tap(find.widgetWithText(ListTile, 'Backup'));
    await tester.pumpAndSettle();

    // Deve exibir a página de Backup
    expect(find.text('Backup'), findsWidgets);
    expect(find.text('Exportar e importar dados locais (JSON).'), findsWidgets);
  });
}