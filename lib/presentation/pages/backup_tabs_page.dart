import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backup_page.dart';
import 'cloud_backup_page.dart';

class BackupTabsPage extends ConsumerWidget {
  final int initialIndex; // 0: Nuvem, 1: Arquivo
  const BackupTabsPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: cs.surface,
            child: TabBar(
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.primary,
              tabs: const [
                Tab(text: 'Backup na Nuvem'),
                Tab(text: 'Backup Arquivo'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: const [
                CloudBackupPage(),
                BackupPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}