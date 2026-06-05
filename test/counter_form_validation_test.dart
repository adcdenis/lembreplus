import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/presentation/pages/counter_form_page.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/services/notification_service.dart';

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions() async {}
}

void main() {
  testWidgets('Formulário exige nome do contador', (WidgetTester tester) async {
    final db = AppDatabase.test();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
        ],
        child: const MaterialApp(home: Scaffold(body: CounterFormPage())),
      ),
    );

    // Valida o formulário sem preencher o nome.
    final formState = tester.state<FormState>(find.byType(Form));
    expect(formState.validate(), isFalse);
    await tester.pump();

    expect(find.text('Informe um nome'), findsOneWidget);

    // Aguarda as animações de entrada terminarem antes de desinflar o widget
    await tester.pump(const Duration(seconds: 2));

    // Limpa a árvore de widgets primeiro para disparar o dispose dos providers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));

    // Fecha o banco de dados e aguarda a conclusão dos timers internos do Drift
    await db.close();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.idle();
  });
}
