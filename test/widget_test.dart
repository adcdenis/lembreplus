// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lembreplus/main.dart';

void main() {
  testWidgets('App exibe título Lembre+', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LembrePlusApp()));
    await tester.pump();
    expect(find.text('Lembre+'), findsWidgets);

    // Limpa a árvore de widgets e processa timers pendentes de animações/shimmer/drift
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.idle();
  });
}
