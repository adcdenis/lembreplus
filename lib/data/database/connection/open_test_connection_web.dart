import 'package:drift/drift.dart';
import 'package:drift/web.dart' as web;

QueryExecutor openTestConnection() {
  return web.WebDatabase('lembreplus_test');
}