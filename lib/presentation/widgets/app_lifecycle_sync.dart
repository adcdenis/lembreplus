import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/state/cloud_providers.dart';
import 'package:lembreplus/data/services/cloud_sync_service.dart';

/// Envolve a árvore de widgets e observa o ciclo de vida do app.
/// Quando o app é pausado/inativado/fechado, dispara um backup na nuvem
/// se o auto-sync estiver habilitado e houver usuário autenticado.
class AppLifecycleSync extends StatefulWidget {
  final Widget child;
  const AppLifecycleSync({super.key, required this.child});

  @override
  State<AppLifecycleSync> createState() => _AppLifecycleSyncState();
}

class _AppLifecycleSyncState extends State<AppLifecycleSync>
    with WidgetsBindingObserver {
  CloudSyncService? _svc;
  CloudUser? _user;
  bool _auto = false;
  StreamSubscription? _authSub;
  StreamSubscription<bool>? _autoSub;
  DateTime? _lastBackupAttempt;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    // Tentar obter o container do Riverpod; se não existir, desativa silenciosamente
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      _svc = container.read(cloudSyncServiceProvider);
      _authSub = _svc!.authStateChanges().listen((u) {
        _user = u;
      });
      _autoSub = _svc!.autoSyncEnabled().listen((enabled) {
        _auto = enabled;
      });
    } catch (_) {
      // Sem ProviderScope acima: não há sincronização automática neste contexto (ex.: testes simples)
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _autoSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _triggerBackupIfNeeded();
    }
  }

  void _triggerBackupIfNeeded() {
    final svc = _svc;
    if (svc == null) return;
    if (!_auto) return;
    if (_user == null) return;
    final now = DateTime.now();
    // Evitar disparos muito frequentes em transições rápidas
    if (_lastBackupAttempt != null &&
        now.difference(_lastBackupAttempt!).inSeconds < 15) {
      return;
    }
    _lastBackupAttempt = now;
    Future.microtask(() async {
      try {
        await svc.backupNow();
      } catch (_) {
        // Silenciar erros aqui; a UI de Backup mostra feedback manual
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}