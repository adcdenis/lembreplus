import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;
      final title = Row(
        children: const [
          Icon(Icons.event_note),
          SizedBox(width: 8),
          Text('Lembre+'),
        ],
      );

      if (isWide) {
        final selectedIndex = _selectedIndexForLocation(GoRouterState.of(context).uri.toString());
        return Scaffold(
          appBar: AppBar(title: title),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => _goToIndex(context, index),
                extended: constraints.maxWidth >= 1200,
                // Quando extended=true, labelType deve ser null/none.
                labelType: (constraints.maxWidth >= 1200)
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                  NavigationRailDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: Text('Contadores')),
                  NavigationRailDestination(icon: Icon(Icons.summarize_outlined), selectedIcon: Icon(Icons.summarize), label: Text('Resumo')),
                  NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text('Relatórios')),
                  NavigationRailDestination(icon: Icon(Icons.backup_outlined), selectedIcon: Icon(Icons.backup), label: Text('Backup')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(title: title, centerTitle: false),
        drawer: _AppDrawer(onNavigateIndex: (index) => _goToIndex(context, index)),
        body: child,
      );
    });
  }

  int _selectedIndexForLocation(String location) {
    if (location.startsWith('/counters')) return 1;
    if (location.startsWith('/summary')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/backup')) return 4;
    return 0; // dashboard default
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/counters');
        break;
      case 2:
        context.go('/summary');
        break;
      case 3:
        context.go('/reports');
        break;
      case 4:
        context.go('/backup');
        break;
    }
  }
}

class _AppDrawer extends StatelessWidget {
  final ValueChanged<int> onNavigateIndex;
  const _AppDrawer({required this.onNavigateIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.event_note, size: 24),
                    SizedBox(width: 8),
                    Text('Lembre+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Text('📋', style: TextStyle(fontSize: 20)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateIndex(0);
              },
            ),
            ListTile(
              leading: const Text('🧮', style: TextStyle(fontSize: 20)),
              title: const Text('Contadores'),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateIndex(1);
              },
            ),
            ListTile(
              leading: const Text('📊', style: TextStyle(fontSize: 20)),
              title: const Text('Resumo'),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateIndex(2);
              },
            ),
            ListTile(
              leading: const Text('📈', style: TextStyle(fontSize: 20)),
              title: const Text('Relatórios'),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateIndex(3);
              },
            ),
            ListTile(
              leading: const Text('🔄', style: TextStyle(fontSize: 20)),
              title: const Text('Backup'),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateIndex(4);
              },
            ),
          ],
        ),
      ),
    );
  }
}