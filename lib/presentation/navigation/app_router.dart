import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/dashboard_page.dart';
import '../pages/counter_form_page.dart';
import '../pages/counter_list_page.dart';
import '../pages/counter_history_page.dart';
import '../pages/reports_page.dart';
import '../pages/backup_tabs_page.dart';
import '../widgets/app_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/counters',
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (context, state) => const MaterialPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/counters',
            name: 'counters',
            pageBuilder: (context, state) => const MaterialPage(child: CounterListPage()),
          ),
          GoRoute(
            path: '/counter/new',
            name: 'counter_new',
            pageBuilder: (context, state) => const MaterialPage(child: CounterFormPage()),
          ),

          GoRoute(
            path: '/counter/:id/history',
            name: 'counter_history',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return MaterialPage(child: CounterHistoryPage(counterId: id));
            },
          ),
          GoRoute(
            path: '/counter/:id/edit',
            name: 'counter_edit',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return MaterialPage(child: CounterFormPage(counterId: id));
            },
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => const MaterialPage(child: ReportsPage()),
          ),
          GoRoute(
            path: '/backup',
            name: 'backup',
            pageBuilder: (context, state) => MaterialPage(child: const BackupTabsPage(initialIndex: 1)),
          ),
          GoRoute(
            path: '/cloud-backup',
            name: 'cloud_backup',
            pageBuilder: (context, state) => MaterialPage(child: const BackupTabsPage(initialIndex: 0)),
          ),
        ],
      ),

    ],
  );
}