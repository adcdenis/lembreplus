import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/state/providers.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backup = ref.watch(backupServiceProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Backup', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('Exportar e importar dados locais (JSON).'),
          const SizedBox(height: 24),
          Row(children: [
            ElevatedButton.icon(
              onPressed: () async {
                final res = await backup.export();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                }
              },
              icon: const Icon(Icons.backup_outlined),
              label: const Text('Exportar para JSON'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  final imported = await backup.import();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(imported)));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao importar: $e')));
                  }
                }
              },
              icon: const Icon(Icons.restore),
              label: const Text('Importar de JSON'),
            ),
          ]),
          const SizedBox(height: 12),
          const Text('Local de backup: /documents/lembre_backup.json (em plataformas nativas).'),
          const SizedBox(height: 8),
          const Text('No Web, o arquivo será baixado com o nome lembre_backup.json.'),
        ],
      ),
    );
  }
}