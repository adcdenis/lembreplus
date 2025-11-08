import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/core/cloud/cloud_config.dart';

class CloudBackupPage extends ConsumerWidget {
  const CloudBackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudSvc = ref.watch(cloudSyncServiceProvider);
    final cloudUserAsync = ref.watch(cloudUserProvider);
    final autoSyncAsync = ref.watch(cloudAutoSyncProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backup na Nuvem',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Sincronize seus dados com a nuvem (Google).'),
          const SizedBox(height: 16),
          if (!useGoogleDriveCloudSync)
            const Text(
              'Para habilitar login Google e backup no Google Drive, ative o provedor Drive nas configurações do código.',
              style: TextStyle(color: Colors.orange),
            ),
          const SizedBox(height: 12),
          // Status de autenticação na primeira linha; botões na linha abaixo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cloudUserAsync.when(
                data: (user) {
                  final status = user == null
                      ? 'Não autenticado'
                      : 'Autenticado: ${user.email ?? user.displayName ?? user.uid}';
                  return Text(status, maxLines: 1, overflow: TextOverflow.ellipsis);
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erro auth: $e', maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await cloudSvc.signInWithGoogle();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login Google concluído')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Falha no login: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar com Google'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await cloudSvc.signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logout concluído')),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: autoSyncAsync.asData?.value ?? false,
                onChanged: (v) async {
                  await cloudSvc.setAutoSyncEnabled(v);
                  if (v) {
                    await cloudSvc.startRealtimeSync();
                  } else {
                    await cloudSvc.stopRealtimeSync();
                  }
                },
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Text('Sincronização automática'),
                  if (autoSyncAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await cloudSvc.backupNow();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Backup enviado para nuvem'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Falha ao enviar: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Backup na nuvem'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await cloudSvc.restoreNow();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restauração concluída')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Falha ao restaurar: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('Restaurar da nuvem'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!kIsWeb) ...[
            const Text(
              'Observação: Esta tela foca apenas recursos de nuvem. Exports locais continuam na tela Backup.',
            ),
          ],
        ],
      ),
    );
  }
}