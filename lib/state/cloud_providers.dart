import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Valor inicial persistido de auto-sync (para evitar piscar falso na UI)
final cloudAutoSyncInitialProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('cloud_auto_sync_enabled') ?? false;
});

/// Evento de restauração: emite a data/hora do backup restaurado
final cloudRestoreEventProvider = StreamProvider<DateTime>((ref) {
  final svc = ref.read(cloudSyncServiceProvider);
  return svc.restoreEvents();
});

/// Evento de backup: emite a data/hora local do backup criado
final cloudBackupEventProvider = StreamProvider<DateTime>((ref) {
  final svc = ref.read(cloudSyncServiceProvider);
  return svc.backupEvents();
});

class CloudActionInfo {
  final DateTime? when;
  final String? fileName;
  const CloudActionInfo({this.when, this.fileName});
}

DateTime? _parseTsToLocal(String ts) {
  try {
    final year = int.parse(ts.substring(0, 4));
    final month = int.parse(ts.substring(4, 6));
    final day = int.parse(ts.substring(6, 8));
    final hour = int.parse(ts.substring(9, 11));
    final minute = int.parse(ts.substring(11, 13));
    final second = int.parse(ts.substring(13, 15));
    return DateTime.utc(year, month, day, hour, minute, second).toLocal();
  } catch (_) {
    return null;
  }
}

final cloudLastBackupInfoProvider = FutureProvider<CloudActionInfo>((ref) async {
  // Recarrega quando um novo backup é emitido
  ref.watch(cloudBackupEventProvider);
  final prefs = await SharedPreferences.getInstance();
  final ts = prefs.getString('cloud_last_backup_timestamp');
  final file = prefs.getString('cloud_last_backup_file');
  return CloudActionInfo(when: ts != null ? _parseTsToLocal(ts) : null, fileName: file);
});

final cloudLastRestoreInfoProvider = FutureProvider<CloudActionInfo>((ref) async {
  // Recarrega quando uma restauração é emitida
  ref.watch(cloudRestoreEventProvider);
  final prefs = await SharedPreferences.getInstance();
  final ts = prefs.getString('cloud_last_restore_timestamp');
  final file = prefs.getString('cloud_last_restore_file');
  return CloudActionInfo(when: ts != null ? _parseTsToLocal(ts) : null, fileName: file);
});
