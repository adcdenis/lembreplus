// ignore_for_file: deprecated_member_use
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase openConnection() {
  // Usar IndexedDB diretamente no ambiente web de desenvolvimento para evitar erros de WebAssembly
  return LazyDatabase(() async => WebDatabase('lembreplus'));
}