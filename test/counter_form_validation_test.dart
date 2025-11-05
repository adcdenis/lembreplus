import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/presentation/pages/counter_form_page.dart';
import 'package:lembreplus/state/providers.dart';

void main() {
  testWidgets('Formulário exige nome do contador', (WidgetTester tester) async {
    final db = AppDatabase.test();
    addTearDown(() async => db.close());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: Scaffold(body: CounterFormPage())),
      ),
    );

    // Botão Criar sem preencher nome deve mostrar erro de validação
    final createIcon = find.byIcon(Icons.save);
    expect(createIcon, findsOneWidget);
    await tester.tap(createIcon);
    await tester.pump();

    expect(find.text('Informe um nome'), findsOneWidget);
  });
}