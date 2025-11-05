import 'package:flutter_test/flutter_test.dart';
import 'package:lembreplus/domain/category_utils.dart';

void main() {
  test('normalizeCategory removes accents, spaces and special chars', () {
    final input = '  São_Paulo! Futebol & Lazer  ';
    final normalized = normalizeCategory(input);
    expect(normalized, 'sao-paulo-futebol-lazer');
  });

  test('normalizeCategory collapses multiple hyphens', () {
    final input = 'Áreas    Comuns__Do Prédio';
    final normalized = normalizeCategory(input);
    expect(normalized, 'areas-comuns-do-predio');
  });
}