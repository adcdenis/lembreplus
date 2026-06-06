import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lembreplus/core/text_sanitizer.dart';
// Removida a seção de nuvem desta tela. Recursos de nuvem foram movidos para CloudBackupPage.

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backup = ref.watch(backupServiceProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.save_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup Local',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    Text(
                      'Exportar e importar dados (JSON)',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Card de Ações
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.import_export_rounded, size: 20, color: cs.primary),
                      const SizedBox(width: 8),
                      const Text('Ações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ActionButton(
                        icon: Icons.upload_file_rounded,
                        label: 'Exportar JSON',
                        color: cs.primary,
                        onPressed: () async {
                          final res = await backup.export();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                          }
                        },
                      ),
                      if (!kIsWeb)
                        _ActionButton(
                          icon: Icons.share_rounded,
                          label: 'Exportar e Compartilhar',
                          color: cs.tertiary,
                          onPressed: () async {
                            try {
                              final path = await backup.exportPath();
                              final now = DateTime.now();
                              final ts =
                                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                              final subject = sanitizeForShare('Backup Lembre+');
                              final text = sanitizeForShare('Backup exportado em $ts');
                              await Share.shareXFiles(
                                [XFile(path, mimeType: 'application/json')],
                                subject: subject,
                                text: text,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Falha ao compartilhar: $e')),
                                );
                              }
                            }
                          },
                        ),
                      _ActionButton(
                        icon: Icons.download_rounded,
                        label: 'Importar JSON',
                        color: cs.secondary,
                        outlined: true,
                        onPressed: () async {
                          try {
                            final imported = await backup.import();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(imported)));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Falha ao importar: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info card
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('Informações', style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _infoItem(Icons.file_present_outlined, 'Nome do arquivo: lembre_backup_YYYYMMDD_HHMMSS.json', cs),
                  const SizedBox(height: 6),
                  _infoItem(Icons.phone_android_outlined, 'Android/iOS: salvo no diretório de documentos do app.', cs),
                  const SizedBox(height: 6),
                  _infoItem(Icons.web_outlined, 'Web: o arquivo é baixado pelo navegador.', cs),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Documentação colapsável
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: Icon(Icons.code_rounded, size: 20, color: cs.onSurfaceVariant),
                title: const Text('Formato JSON (documentação)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                children: [
                  const SelectableText(
                    'Raiz:\n'
                    '- version: inteiro (obrigatório) [2]\n'
                    '- counters: lista (obrigatório)\n'
                    '- categories: lista (obrigatório)\n'
                    '- history: lista (obrigatório)\n'
                    '- alerts: lista (opcional; presente na versão 2)\n\n'
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
                    '- timestamp: string ISO-8601 (obrigatório)\n\n'
                    'Alerts:\n'
                    '- id: inteiro (obrigatório)\n'
                    '- counterId: inteiro (obrigatório)\n'
                    '- offsetMinutes: inteiro (obrigatório)\n',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text('Exemplo:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const SelectableText(
                      '{\n'
                      '  "version": 2,\n'
                      '  "counters": [ { "id": 1, "name": "Aniversário", ... } ],\n'
                      '  "categories": [ { "id": 1, "name": "Pessoal", "normalized": "pessoal" } ],\n'
                      '  "history": [ { "id": 1, "counterId": 1, ... } ],\n'
                      '  "alerts": [ { "id": 1, "counterId": 1, "offsetMinutes": 120 } ]\n'
                      '}\n',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Histórico de exports
          if (!kIsWeb) ...[
            Row(
              children: [
                Icon(Icons.folder_open_rounded, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                const Text(
                  'Histórico de Exports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.folder_off_outlined, size: 40, color: cs.onSurface.withValues(alpha: 0.15)),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhum backup encontrado',
                              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: files.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final path = files[index];
                    final filename = path
                        .split('/')
                        .last
                        .split('\\')
                        .last;
                    String? subtitle;
                    final re = RegExp(r'lembre_backup_(\d{8})_(\d{6})');
                    final m = re.firstMatch(filename);
                    if (m != null) {
                      final d = m.group(1)!;
                      final t = m.group(2)!;
                      subtitle =
                          'Exportado em ${d.substring(6, 8)}/${d.substring(4, 6)}/${d.substring(0, 4)} ${t.substring(0, 2)}:${t.substring(2, 4)}:${t.substring(4, 6)}';
                    }
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.file_present_rounded, size: 20, color: cs.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(filename, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  if (subtitle != null)
                                    Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async {
                                try {
                                  final msg = await backup.importFromPath(path);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Falha na importação'),
                                        content: SingleChildScrollView(child: Text(e.toString())),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Fechar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded, size: 16),
                                  SizedBox(width: 4),
                                  Text('Importar', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _infoItem(IconData icon, String text, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool outlined;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
      ),
    );
  }
}
