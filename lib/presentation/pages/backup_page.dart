import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lembreplus/core/cloud/cloud_config.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backup = ref.watch(backupServiceProvider);
    final cloudSvc = ref.watch(cloudSyncServiceProvider);
    final cloudUserAsync = ref.watch(cloudUserProvider);
    final autoSyncAsync = ref.watch(cloudAutoSyncProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backup',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text('Exportar e importar dados locais (JSON).'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final res = await backup.export();
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(res)));
                  }
                },
                icon: const Text('📤', style: TextStyle(fontSize: 20)),
                label: const Text('Exportar para JSON'),
              ),
              if (!kIsWeb)
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      final path = await backup.exportPath();
                      final now = DateTime.now();
                      final ts =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                      await Share.shareXFiles(
                        [XFile(path, mimeType: 'application/json')],
                        subject: 'Backup Lembre+',
                        text: 'Backup exportado em $ts',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Falha ao compartilhar: $e')),
                        );
                      }
                    }
                  },
                  icon: const Text('🔗', style: TextStyle(fontSize: 20)),
                  label: const Text('Exportar e compartilhar'),
                ),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final imported = await backup.import();
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(imported)));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Falha ao importar: $e')),
                      );
                    }
                  }
                },
                icon: const Text('📥', style: TextStyle(fontSize: 20)),
                label: const Text('Importar de JSON'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Nome do arquivo: lembre_backup_YYYYMMDD_HHMMSS.json (com carimbo de data/hora).',
          ),
          const SizedBox(height: 8),
          const Text('Android/iOS: salvo no diretório de documentos do app.'),
          const SizedBox(height: 8),
          const Text(
            'Web: o arquivo é baixado pelo navegador com o nome acima.',
          ),
          const SizedBox(height: 16),
          const Text('Formato JSON (chaves, obrigatoriedade e tipos):'),
          const SizedBox(height: 8),
          const SelectableText(
            'Raiz:\n'
            '- version: inteiro (obrigatório)\n'
            '- counters: lista (obrigatório)\n'
            '- categories: lista (obrigatório)\n'
            '- history: lista (obrigatório)\n\n'
            'Counter:\n'
            '- id: inteiro (obrigatório)\n'
            '- name: string (obrigatório)\n'
            '- description: string (opcional)\n'
            '- eventDate: string ISO-8601 (obrigatório)\n'
            '- category: string (opcional)\n'
            '- recurrence: string (opcional)\n'
            '- createdAt: string ISO-8601 (obrigatório)\n'
            '- updatedAt: string ISO-8601 (opcional)\n\n'
            'Category:\n'
            '- id: inteiro (obrigatório)\n'
            '- name: string (obrigatório)\n'
            '- normalized: string (obrigatório)\n\n'
            'History:\n'
            '- id: inteiro (obrigatório)\n'
            '- counterId: inteiro (obrigatório)\n'
            '- snapshot: string (obrigatório)\n'
            '- operation: string (obrigatório)\n'
            '- timestamp: string ISO-8601 (obrigatório)\n',
          ),
          const SizedBox(height: 12),
          const Text('Exemplo de JSON (importação/exportação):'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SelectableText(
              '{\n'
              '  "version": 1,\n'
              '  "counters": [\n'
              '    {\n'
              '      "id": 1,\n'
              '      "name": "Aniversário",\n'
              '      "description": "Aniversário João",\n'
              '      "eventDate": "2025-05-20T00:00:00.000Z",\n'
              '      "category": "Pessoal",\n'
              '      "recurrence": "yearly",\n'
              '      "createdAt": "2025-01-01T10:00:00.000Z",\n'
              '      "updatedAt": null\n'
              '    }\n'
              '  ],\n'
              '  "categories": [\n'
              '    { "id": 1, "name": "Pessoal", "normalized": "pessoal" }\n'
              '  ],\n'
              '  "history": [\n'
              '    {\n'
              '      "id": 1,\n'
              '      "counterId": 1,\n'
              '      "snapshot": "{...}",\n'
              '      "operation": "create",\n'
              '      "timestamp": "2025-01-01T10:00:00.000Z"\n'
              '    }\n'
              '  ]\n'
              '}\n',
              style: TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 32),
          const Text(
            'Sincronização na nuvem (Google)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (!useGoogleDriveCloudSync)
            const Text(
              'Para habilitar login Google e backup no Google Drive, ative o provedor Drive nas configurações do código.',
              style: TextStyle(color: Colors.orange),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              cloudUserAsync.when(
                data: (user) {
                  final status = user == null
                      ? 'Não autenticado'
                      : 'Autenticado: ${user.email ?? user.displayName ?? user.uid}';
                  return Expanded(child: Text(status));
                },
                loading: () => const Expanded(child: LinearProgressIndicator()),
                error: (e, _) => Expanded(child: Text('Erro auth: $e')),
              ),
              const SizedBox(width: 12),
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
              const SizedBox(width: 8),
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
              'Histórico de exports (Android/iOS)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<String>>(
              future: backup.listBackups(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(),
                  );
                }
                final files = snap.data ?? const [];
                if (files.isEmpty) {
                  return const Text(
                    'Nenhum backup encontrado no diretório do app.',
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: files.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final path = files[index];
                    final filename = path
                        .split('/')
                        .last
                        .split('\\')
                        .last; // suporta separadores diferentes
                    String? subtitle;
                    final re = RegExp(r'lembre_backup_(\d{8})_(\d{6})');
                    final m = re.firstMatch(filename);
                    if (m != null) {
                      final d = m.group(1)!; // YYYYMMDD
                      final t = m.group(2)!; // HHMMSS
                      subtitle =
                          'Exportado em ${d.substring(6, 8)}/${d.substring(4, 6)}/${d.substring(0, 4)} ${t.substring(0, 2)}:${t.substring(2, 4)}:${t.substring(4, 6)}';
                    }
                    return ListTile(
                      title: Text(filename),
                      subtitle: subtitle != null ? Text(subtitle) : null,
                      trailing: FilledButton.icon(
                        onPressed: () async {
                          try {
                            final msg = await backup.importFromPath(path);
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(msg)));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Falha na importação'),
                                  content: SingleChildScrollView(
                                    child: Text(e.toString()),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Fechar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                        icon: const Text('📥', style: TextStyle(fontSize: 20)),
                        label: const Text('Importar'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
