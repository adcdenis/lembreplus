import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/dashboard_page.dart';
import '../pages/counter_form_page.dart';
import '../pages/counter_list_page.dart';
import '../pages/counter_history_page.dart';
import '../pages/reports_page.dart';
import '../pages/backup_tabs_page.dart';
import '../pages/scheduled_notifications_page.dart';
import 'package:lembreplus/presentation/widgets/app_shell.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';

class TopLevelPopScope extends StatelessWidget {
  final Widget child;
  const TopLevelPopScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sair do aplicativo'),
            content: const Text('Deseja realmente fechar o app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sair'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context, 
  required GoRouterState state, 
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

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
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const TopLevelPopScope(child: DashboardPage())),
          ),
          GoRoute(
            path: '/counters',
            name: 'counters',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const TopLevelPopScope(child: CounterListPage())),
          ),
          GoRoute(
            path: '/counter/new',
            name: 'counter_new',
            pageBuilder: (context, state) {
              final selectedCategory = state.extra as String?;
              return buildPageWithDefaultTransition(context: context, state: state, child: CounterFormPage(initialCategory: selectedCategory));
            },
          ),

          GoRoute(
            path: '/counter/:id/history',
            name: 'counter_history',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return buildPageWithDefaultTransition(context: context, state: state, child: CounterHistoryPage(counterId: id));
            },
          ),
          GoRoute(
            path: '/counter/:id/edit',
            name: 'counter_edit',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return buildPageWithDefaultTransition(context: context, state: state, child: CounterFormPage(counterId: id));
            },
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const TopLevelPopScope(child: ReportsPage())),
          ),
          GoRoute(
            path: '/backup',
            name: 'backup',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const TopLevelPopScope(child: BackupTabsPage(initialIndex: 1))),
          ),
          GoRoute(
            path: '/cloud-backup',
            name: 'cloud_backup',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const TopLevelPopScope(child: BackupTabsPage(initialIndex: 0))),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const TopLevelPopScope(child: ScheduledNotificationsPage())),
          ),
        ],
      ),

    ],
  );
}