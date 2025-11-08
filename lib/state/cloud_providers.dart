import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/data/services/cloud_sync_service.dart';
import 'providers.dart' show databaseProvider; // reuse existing provider

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final db = ref.read(databaseProvider);
  return createCloudSyncService(db);
});

final cloudUserProvider = StreamProvider<CloudUser?>((ref) {
  final svc = ref.read(cloudSyncServiceProvider);
  return svc.authStateChanges();
});

final cloudAutoSyncProvider = StreamProvider<bool>((ref) {
  final svc = ref.read(cloudSyncServiceProvider);
  return svc.autoSyncEnabled();
});
