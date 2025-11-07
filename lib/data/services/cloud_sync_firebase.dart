import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/data/services/cloud_sync_service.dart';
import 'package:lembreplus/data/services/backup_codec.dart';
import 'dart:async' as async;

class FirebaseCloudSyncService implements CloudSyncService {
  final AppDatabase db;
  final _authCtrl = StreamController<CloudUser?>.broadcast();
  final _autoSyncCtrl = StreamController<bool>.broadcast();

  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final GoogleSignIn _signIn = GoogleSignIn(scopes: ['email']);

  bool _auto = false;
  async.StreamSubscription? _countersSub;
  async.StreamSubscription? _categoriesSub;
  async.Timer? _debounce;

  FirebaseCloudSyncService(this.db) {
    _autoSyncCtrl.add(_auto);
    _auth.userChanges().listen((u) {
      if (u == null) {
        _authCtrl.add(null);
      } else {
        _authCtrl.add(CloudUser(uid: u.uid, displayName: u.displayName, email: u.email));
      }
    });
  }

  @override
  Stream<CloudUser?> authStateChanges() => _authCtrl.stream;

  @override
  Future<void> signInWithGoogle() async {
    // Primeiro tenta signIn nativo; em caso de falha, usa web flow
    final googleUser = await _signIn.signIn();
    if (googleUser == null) {
      throw 'Login cancelado pelo usuário';
    }
    final googleAuth = await googleUser.authentication;
    final credential = fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _signIn.signOut();
    _authCtrl.add(null);
  }

  @override
  Future<void> setAutoSyncEnabled(bool enabled) async {
    _auto = enabled;
    _autoSyncCtrl.add(_auto);
    // Futuro: watchers para sync contínuo
  }

  @override
  Stream<bool> autoSyncEnabled() => _autoSyncCtrl.stream;

  DocumentReference<Map<String, dynamic>> _docRefForUser(String uid) {
    return _fs.collection('backups').doc(uid);
  }

  @override
  Future<void> backupNow() async {
    final u = _auth.currentUser;
    if (u == null) throw 'Usuário não autenticado';
    final jsonStr = await BackupCodec.encodeToJsonString(db);
    final data = {
      'data': jsonStr,
      'updatedAt': DateTime.now().toIso8601String(),
      'version': 1,
    };
    await _docRefForUser(u.uid).set(data, SetOptions(merge: true));
  }

  @override
  Future<void> restoreNow() async {
    final u = _auth.currentUser;
    if (u == null) throw 'Usuário não autenticado';
    final snap = await _docRefForUser(u.uid).get();
    if (!snap.exists) {
      throw 'Nenhum backup encontrado na nuvem';
    }
    final m = snap.data();
    final jsonStr = m?['data'] as String?;
    if (jsonStr == null || jsonStr.isEmpty) {
      throw 'Backup vazio ou inválido';
    }
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
    final u = _auth.currentUser;
    if (u == null) return; // requer usuário autenticado
    // Assinar mudanças locais e fazer backup com debounce
    _countersSub ??= db.watchAllCounters().listen((_) => _onLocalChange());
    _categoriesSub ??= db.watchAllCategories().listen((_) => _onLocalChange());
  }

  @override
  Future<void> stopRealtimeSync() async {
    await _countersSub?.cancel();
    await _categoriesSub?.cancel();
    _countersSub = null;
    _categoriesSub = null;
    _debounce?.cancel();
    _debounce = null;
  }

  void _onLocalChange() {
    if (!_auto) return;
    final u = _auth.currentUser;
    if (u == null) return;
    _debounce?.cancel();
    _debounce = async.Timer(const Duration(seconds: 20), () async {
      try {
        await backupNow();
      } catch (_) {
        // silencioso em segundo plano
      }
    });
  }
}