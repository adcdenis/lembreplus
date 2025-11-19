import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:intl/intl.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ouve eventos de restauração e mostra uma mensagem com data/hora exata
    ref.listen(cloudRestoreEventProvider, (prev, next) {
      next.whenData((dt) {
        final formatted = DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados atualizados. Restauração de $formatted.')),
        );
      });
    });
    return PopScope(
      // Intercepta sempre o botão voltar para aplicar regra:
      // voltar leva à listagem de contadores; somente nela perguntar para sair.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        // Se o Drawer estiver aberto, feche-o e não trate como "voltar" da página
        final scaffoldState = Scaffold.maybeOf(context);
        if (scaffoldState?.isDrawerOpen == true) {
          scaffoldState!.closeDrawer();
          return;
        }
        final router = GoRouter.of(context);
        final location = GoRouterState.of(context).uri.toString();
        if (location == '/counters') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sair do aplicativo'),
              content: const Text('Deseja realmente fechar o app?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sair')),
              ],
            ),
          );
          if (confirm == true) {
            SystemNavigator.pop();
          }
        } else {
          // Qualquer outra página: voltar navega para a listagem de contadores
          router.go('/counters');
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
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
          appBar: AppBar(title: title, actions: const [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: _ProfileAvatar(),
            ),
          ]),
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
                useIndicator: true,
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                trailing: const Padding(
                  padding: EdgeInsets.all(12),
                  child: _VersionFooter(),
                ),
                destinations: const [
                  NavigationRailDestination(icon: Text('📋', style: TextStyle(fontSize: 20)), selectedIcon: Text('📋', style: TextStyle(fontSize: 20)), label: Text('Dashboard')),
                  NavigationRailDestination(icon: Text('🧮', style: TextStyle(fontSize: 20)), selectedIcon: Text('🧮', style: TextStyle(fontSize: 20)), label: Text('Contadores')),
                  NavigationRailDestination(icon: Text('📈', style: TextStyle(fontSize: 20)), selectedIcon: Text('📈', style: TextStyle(fontSize: 20)), label: Text('Relatórios')),
                  NavigationRailDestination(icon: Text('🔄', style: TextStyle(fontSize: 20)), selectedIcon: Text('🔄', style: TextStyle(fontSize: 20)), label: Text('Backup')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(title: title, centerTitle: false, actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: _ProfileAvatar(),
          ),
        ]),
        drawer: _AppDrawer(onNavigateIndex: (index) => _goToIndex(context, index)),
        body: child,
      );
    }),
    );
  }

  int _selectedIndexForLocation(String location) {
    if (location.startsWith('/counters')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/backup')) return 3;
    if (location.startsWith('/cloud-backup')) return 3;
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
        context.go('/reports');
        break;
      case 3:
        context.go('/cloud-backup');
        break;
    }
  }
}

class _AppDrawer extends StatelessWidget {
  final ValueChanged<int> onNavigateIndex;
  const _AppDrawer({required this.onNavigateIndex});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    if (location.startsWith('/counters')) selectedIndex = 1;
    if (location.startsWith('/reports')) selectedIndex = 2;
    if (location.startsWith('/backup')) selectedIndex = 3;
    if (location.startsWith('/cloud-backup')) selectedIndex = 3;

    Widget tile({required int index, required String label, required Widget leading}) {
      final selected = selectedIndex == index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: leading,
          title: Text(label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              )),
          selected: selected,
          selectedTileColor: cs.primaryContainer,
          tileColor: cs.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () {
            Scaffold.maybeOf(context)?.closeDrawer();
            onNavigateIndex(index);
          },
        ),
      );
    }

    return Drawer(
      backgroundColor: cs.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primaryContainer, cs.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                children: [
                  tile(index: 0, label: 'Dashboard', leading: const Text('📋', style: TextStyle(fontSize: 20))),
                  tile(index: 1, label: 'Contadores', leading: const Text('🧮', style: TextStyle(fontSize: 20))),
                  tile(index: 2, label: 'Relatórios', leading: const Text('📈', style: TextStyle(fontSize: 20))),
                  tile(index: 3, label: 'Backup', leading: const Text('🔄', style: TextStyle(fontSize: 20))),
                ],
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _VersionFooter(),
            ),
          ],
        ),
      ),
    );
  }
}

// Rodapé com a versão do aplicativo
class _VersionFooter extends ConsumerWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(appVersionProvider);
    final scheme = Theme.of(context).colorScheme;
    return versionAsync.when(
      loading: () => Text('Versão...', style: TextStyle(color: scheme.onSurfaceVariant)),
      error: (err, _) => Text('Versão indisponível', style: TextStyle(color: scheme.onSurfaceVariant)),
      data: (v) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(v, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// Avatar do usuário (topo direito): mostra foto do Google quando logado,
// e avatar padrão quando deslogado.
class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(cloudUserProvider);
    final cs = Theme.of(context).colorScheme;
    Widget defaultAvatar() => CircleAvatar(
          radius: 16,
          backgroundColor: cs.surface,
          child: Icon(Icons.account_circle, size: 20, color: cs.onSurfaceVariant),
        );

    return userAsync.maybeWhen(
      data: (user) {
        if (user == null || user.photoUrl == null) {
          return defaultAvatar();
        }
        return CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(user.photoUrl!),
          backgroundColor: cs.surface,
        );
      },
      orElse: () => defaultAvatar(),
    );
  }
}