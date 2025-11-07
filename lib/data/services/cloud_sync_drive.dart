import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/services/backup_codec.dart';
import 'package:lembreplus/data/services/cloud_sync_service.dart';
import 'package:lembreplus/core/cloud/cloud_config.dart';

/// HTTP client que injeta os headers de autenticação do Google
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

/// Implementação de CloudSyncService usando Google Drive (sem Firebase)
class GoogleDriveCloudSyncService implements CloudSyncService {
  final AppDatabase db;
  late final StreamController<CloudUser?> _authCtrl;
  late final StreamController<bool> _autoSyncCtrl;
  bool _auto = false;

  final GoogleSignIn _signIn = GoogleSignIn(
    scopes: useDriveAppDataSpace
        ? const [
            'email',
            'https://www.googleapis.com/auth/drive.appdata',
          ]
        : const [
            'email',
            'https://www.googleapis.com/auth/drive.file',
          ],
  );

  StreamSubscription? _countersSub;
  Timer? _debounce;
  String? _backupFolderId; // cache do id da subpasta de backups
  static const String _prefsKeyAutoSync = 'cloud_auto_sync_enabled';

  GoogleDriveCloudSyncService(this.db) {
    _authCtrl = StreamController<CloudUser?>.broadcast(
      onListen: () {
        // Emite estado de autenticação atual assim que houver assinante.
        final acct = _signIn.currentUser;
        if (acct != null) {
          _authCtrl.add(CloudUser(
            uid: acct.id,
            displayName: acct.displayName,
            email: acct.email,
          ));
        } else {
          _authCtrl.add(null);
        }
      },
    );
    _autoSyncCtrl = StreamController<bool>.broadcast(
      onListen: () {
        // Emite estado atual do auto-sync imediatamente ao inscrever.
        _autoSyncCtrl.add(_auto);
      },
    );
    // Emite usuário atual ao iniciar
    _signIn.onCurrentUserChanged.listen((account) {
      if (account == null) {
        _authCtrl.add(null);
      } else {
        _authCtrl.add(CloudUser(
          uid: account.id,
          displayName: account.displayName,
          email: account.email,
        ));
      }
    });

    // Bootstrap: carrega preferências e tenta login silencioso
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _auto = prefs.getBool(_prefsKeyAutoSync) ?? false;
      // Notificar assinantes do estado carregado
      _autoSyncCtrl.add(_auto);
    } catch (_) {
      // Ignora falhas de prefs; mantém padrão falso
    }
    try {
      final acct = await _signIn.signInSilently();
      if (acct != null) {
        _authCtrl.add(CloudUser(
          uid: acct.id,
          displayName: acct.displayName,
          email: acct.email,
        ));
        // Se auto-sync habilitado, inicia observação contínua
        if (_auto) {
          await startRealtimeSync();
        }
      } else {
        _authCtrl.add(null);
      }
    } catch (_) {
      // Silencioso; usuário permanece não autenticado até login explícito
    }
  }

  Future<String> _ensureBackupFolderId(drive.DriveApi api) async {
    if (useDriveAppDataSpace) {
      // No appDataSpace, não há pasta arbitrária; retornamos marcador especial
      return 'appDataFolder';
    }
    if (_backupFolderId != null) return _backupFolderId!;
    // Procurar pasta existente com nome configurado
    final res = await api.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and name = '${cloudDriveFolderName.replaceAll("'", "\\'")}' and trashed = false",
      pageSize: 1,
      spaces: 'drive',
      $fields: 'files(id,name)'
    );
    final files = res.files ?? [];
    if (files.isNotEmpty) {
      _backupFolderId = files.first.id;
      return _backupFolderId!;
    }
    // Criar pasta
    final folderMeta = drive.File()
      ..name = cloudDriveFolderName
      ..mimeType = 'application/vnd.google-apps.folder';
    final created = await api.files.create(folderMeta);
    _backupFolderId = created.id;
    return _backupFolderId!;
  }

  @override
  Stream<CloudUser?> authStateChanges() => _authCtrl.stream;

  @override
  Future<void> signInWithGoogle() async {
    final account = await _signIn.signIn();
    if (account == null) throw 'Login cancelado';
    _authCtrl.add(CloudUser(uid: account.id, displayName: account.displayName, email: account.email));
  }

  @override
  Future<void> signOut() async {
    await _signIn.disconnect();
    await _signIn.signOut();
    _authCtrl.add(null);
  }

  @override
  Future<void> setAutoSyncEnabled(bool enabled) async {
    _auto = enabled;
    _autoSyncCtrl.add(_auto);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKeyAutoSync, _auto);
    } catch (_) {
      // Ignora erros de persistência
    }
    // Ajusta observação contínua conforme estado
    if (_auto) {
      await startRealtimeSync();
    } else {
      await stopRealtimeSync();
    }
  }

  @override
  Stream<bool> autoSyncEnabled() => _autoSyncCtrl.stream;

  Future<drive.DriveApi> _driveApi() async {
    final acct = _signIn.currentUser ?? await _signIn.signInSilently();
    if (acct == null) throw 'Usuário não autenticado';
    final headers = await acct.authHeaders;
    final client = GoogleAuthClient(headers);
    return drive.DriveApi(client);
  }

  String _timestampName() {
    final now = DateTime.now().toUtc();
    final ts = '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    return 'lembre_backup_$ts.json';
  }

  @override
  Future<void> backupNow() async {
    final api = await _driveApi();
    final jsonStr = await BackupCodec.encodeToJsonString(db);
    final bytes = utf8.encode(jsonStr);
    final media = drive.Media(Stream.value(Uint8List.fromList(bytes)), bytes.length);

    final fileMeta = drive.File()
      ..name = _timestampName()
      ..mimeType = 'application/json';
    if (useDriveAppDataSpace) {
      fileMeta.parents = ['appDataFolder'];
      await api.files.create(fileMeta, uploadMedia: media);
      return;
    }
    final folderId = await _ensureBackupFolderId(api);
    fileMeta.parents = [folderId];
    await api.files.create(fileMeta, uploadMedia: media);
  }

  @override
  Future<void> restoreNow() async {
    final acct = _signIn.currentUser ?? await _signIn.signInSilently();
    if (acct == null) throw 'Usuário não autenticado';
    final headers = await acct.authHeaders;
    final client = GoogleAuthClient(headers);

    // Busca o arquivo mais recente com padrão de nome do app
    final api = drive.DriveApi(client);
    String spaces = 'drive';
    String q = "mimeType = 'application/json' and name contains 'lembre_backup_'";
    if (useDriveAppDataSpace) {
      spaces = 'appDataFolder';
    } else {
      final folderId = await _ensureBackupFolderId(api);
      q = "$q and '$folderId' in parents";
    }
    final res = await api.files.list(
      q: q,
      orderBy: 'modifiedTime desc',
      pageSize: 1,
      spaces: spaces,
      $fields: 'files(id,name,modifiedTime,size)',
    );
    final files = res.files ?? [];
    if (files.isEmpty) {
      throw 'Nenhum backup encontrado no Google Drive';
    }
    final f = files.first;
    final url = Uri.parse('https://www.googleapis.com/drive/v3/files/${f.id}?alt=media');
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw 'Falha ao baixar backup do Drive (HTTP ${response.statusCode})';
    }
    final jsonStr = response.body;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final errors = BackupCodec.validate(data);
    if (errors.isNotEmpty) {
      final report = StringBuffer('Validação falhou (${errors.length} problemas):\n');
      for (final e in errors) { report.writeln('- $e'); }
      throw report.toString();
    }
    await BackupCodec.restore(db, data);
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
        // ignora erros em auto-sync
      }
    });
  }
}