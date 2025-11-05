import 'package:drift/drift.dart';
import 'package:drift/web.dart' as web;

LazyDatabase openConnection() {
  return LazyDatabase(() async => web.WebDatabase('lembreplus'));
}