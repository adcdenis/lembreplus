import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/models/counter.dart';
import 'package:lembreplus/data/models/category.dart' as model;
import 'package:lembreplus/data/models/counter_history.dart' as hist;
import 'package:lembreplus/data/repositories/counter_repository.dart';
import 'package:lembreplus/data/repositories/category_repository.dart';
import 'package:lembreplus/data/repositories/history_repository.dart';
import 'package:lembreplus/data/services/backup_service.dart';
export 'cloud_providers.dart';

// Database
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// Repositories
final counterRepositoryProvider = Provider<CounterRepository>((ref) => CounterRepository(ref.read(databaseProvider)));
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository(ref.read(databaseProvider)));
final historyRepositoryProvider = Provider<HistoryRepository>((ref) => HistoryRepository(ref.read(databaseProvider)));
final backupServiceProvider = Provider<BackupService>((ref) => BackupServiceImpl(ref.read(databaseProvider)));

// Streams of data
final countersProvider = StreamProvider<List<Counter>>((ref) => ref.watch(counterRepositoryProvider).watchAll());
final categoriesProvider = StreamProvider<List<model.Category>>((ref) => ref.watch(categoryRepositoryProvider).watchAll());
final historyProvider = StreamProvider.family<List<hist.CounterHistory>, int>((ref, counterId) =>
    ref.watch(historyRepositoryProvider).watchByCounter(counterId));

// Versão do aplicativo para exibir no rodapé do menu lateral
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return 'v${info.version} (build ${info.buildNumber})';
});