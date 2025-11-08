import 'dart:async';
import 'dart:convert';

import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/core/cloud/cloud_config.dart';
import 'package:lembreplus/data/services/cloud_sync_drive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Representa o usuário autenticado para sincronização na nuvem
class CloudUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  CloudUser({required this.uid, this.displayName, this.email, this.photoUrl});
}

/// Interface do serviço de sincronização em nuvem
abstract class CloudSyncService {
  Stream<CloudUser?> authStateChanges();
  Future<void> signInWithGoogle();
  Future<void> signOut();

  /// Liga/desliga sincronização automática
  Future<void> setAutoSyncEnabled(bool enabled);
  Stream<bool> autoSyncEnabled();

  /// Backup imediato dos dados locais para a nuvem
  Future<void> backupNow();

  /// Restaura os dados da nuvem para o dispositivo local
  Future<void> restoreNow();

  /// Inicia observação contínua para sincronização bidirecional
  Future<void> startRealtimeSync();
  Future<void> stopRealtimeSync();
}

/// Implementação padrão (Noop) que não depende de Firebase.
/// Exibe mensagens educativas e permite fluxo local sem quebras de build.
class NoopCloudSyncService implements CloudSyncService {
  final AppDatabase db;
  late final StreamController<CloudUser?> _authCtrl;
  late final StreamController<bool> _autoSyncCtrl;
  bool _auto = false;
  StreamSubscription? _countersSub;
  Timer? _debounce;
  static const String _prefsKeyAutoSync = 'cloud_auto_sync_enabled';

  NoopCloudSyncService(this.db) {
    _authCtrl = StreamController<CloudUser?>.broadcast(
      onListen: () {
        // Noop: não há usuário autenticado; emite estado inicial imediatamente
        // para evitar travar a UI em loading.
        _authCtrl.add(null);
      },
    );
    _autoSyncCtrl = StreamController<bool>.broadcast(
      onListen: () {
        // Garante que o assinante receba o estado atual imediatamente.
        _autoSyncCtrl.add(_auto);
      },
    );
    // Bootstrap: carregar preferências de auto-sync
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _auto = prefs.getBool(_prefsKeyAutoSync) ?? false;
      _autoSyncCtrl.add(_auto);
      if (_auto) {
        await startRealtimeSync();
      }
    } catch (_) {
      // Ignorar falhas de prefs
    }
  }

  @override
  Stream<CloudUser?> authStateChanges() => _authCtrl.stream;

  @override
  Future<void> signInWithGoogle() async {
    // Orienta sobre configuração necessária
    throw 'Login Google indisponível. Configure Google Sign-In (veja README).';
  }

  @override
  Future<void> signOut() async {
    _authCtrl.add(null);
  }

  @override
  Future<void> setAutoSyncEnabled(bool enabled) async {
    _auto = enabled;
    _autoSyncCtrl.add(_auto);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKeyAutoSync, _auto);
    } catch (_) {}
    if (_auto) {
      await startRealtimeSync();
    } else {
      await stopRealtimeSync();
    }
  }

  @override
  Stream<bool> autoSyncEnabled() => _autoSyncCtrl.stream;

  @override
  Future<void> backupNow() async {
    // Gera JSON em memória para demonstrar que o backup seria enviado à nuvem
    final counters = await db.getAllCounters();
    final categories = await db.getAllCategories();
    final history = await db.getAllHistory();
    final json = jsonEncode({
      'version': 1,
      'counters': counters
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'description': c.description,
                'eventDate': c.eventDate.toIso8601String(),
                'category': c.category,
                'recurrence': c.recurrence,
                'createdAt': c.createdAt.toIso8601String(),
                'updatedAt': c.updatedAt?.toIso8601String(),
              })
          .toList(),
      'categories': categories
          .map((cat) => {
                'id': cat.id,
                'name': cat.name,
                'normalized': cat.normalized,
              })
          .toList(),
      'history': history
          .map((h) => {
                'id': h.id,
                'counterId': h.counterId,
                'snapshot': h.snapshot,
                'operation': h.operation,
                'timestamp': h.timestamp.toIso8601String(),
              })
          .toList(),
    });
    // Aqui enviaríamos para a nuvem (Firestore/Storage). No Noop, apenas valida.
    if (json.isEmpty) {
      throw 'Falha ao preparar backup';
    }
  }

  @override
  Future<void> restoreNow() async {
    // No Noop, apenas demonstra fluxo: requer dados da nuvem
    throw 'Restauração indisponível sem provedor de nuvem configurado.';
  }

  @override
  Future<void> startRealtimeSync() async {
    if (!_auto) return;
    _countersSub ??= db.watchAllCounters().listen((_) => _onLocalChange());
    // Política: não sincronizar por mudanças de categorias
  }

  @override
  Future<void> stopRealtimeSync() async {
    await _countersSub?.cancel();
    _countersSub = null;
    _debounce?.cancel();
    _debounce = null;
  }

  void _onLocalChange() {
    if (!_auto) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 20), () async {
      try {
        await backupNow();
      } catch (_) {
        // silencioso em modo Noop
      }
    });
  }
}

// Fábrica que decide implementação com base na configuração
CloudSyncService createCloudSyncService(AppDatabase db) {
  if (useGoogleDriveCloudSync) {
    return GoogleDriveCloudSyncService(db);
  }
  return NoopCloudSyncService(db);
}