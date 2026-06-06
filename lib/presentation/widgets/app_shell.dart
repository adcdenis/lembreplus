import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final cs = Theme.of(context).colorScheme;
        final title = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isWide ? cs.onPrimary : cs.onPrimary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.event_note, size: 20, color: isWide ? cs.onPrimary : null),
            ),
            const SizedBox(width: 10),
            const Text('Lembre+'),
          ],
        );

      if (isWide) {
        final selectedIndex = _selectedIndexForLocation(GoRouterState.of(context).uri.toString());
        return Scaffold(
          appBar: AppBar(title: title, actions: const [
            _PremiumCrownButton(),
            _ThemeToggleButton(),
            Padding(
              padding: EdgeInsets.only(right: 12.0),
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
                minWidth: 72,
                minExtendedWidth: 200,
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: const _VersionFooter(),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(icon: Text('📋', style: TextStyle(fontSize: 20)), selectedIcon: Text('📋', style: TextStyle(fontSize: 22)), label: Text('Dashboard')),
                  NavigationRailDestination(icon: Text('🧮', style: TextStyle(fontSize: 20)), selectedIcon: Text('🧮', style: TextStyle(fontSize: 22)), label: Text('Contadores')),
                  NavigationRailDestination(icon: Text('📈', style: TextStyle(fontSize: 20)), selectedIcon: Text('📈', style: TextStyle(fontSize: 22)), label: Text('Relatórios')),
                  NavigationRailDestination(icon: Text('🔔', style: TextStyle(fontSize: 20)), selectedIcon: Text('🔔', style: TextStyle(fontSize: 22)), label: Text('Notificações')),
                  NavigationRailDestination(icon: Text('☁️', style: TextStyle(fontSize: 20)), selectedIcon: Text('☁️', style: TextStyle(fontSize: 22)), label: Text('Backup')),
                ],
              ),
              VerticalDivider(width: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
              Expanded(child: child),
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(title: title, centerTitle: false, actions: const [
          _PremiumCrownButton(),
          _ThemeToggleButton(),
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: _ProfileAvatar(),
          ),
        ]),
        drawer: _AppDrawer(onNavigateIndex: (index) => _goToIndex(context, index)),
        body: child,
      );
        });
  }

  int _selectedIndexForLocation(String location) {
    if (location.startsWith('/counters')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/backup')) return 4;
    if (location.startsWith('/cloud-backup')) return 4;
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
        context.go('/notifications');
        break;
      case 4:
        context.go('/cloud-backup');
        break;
    }
  }
}

class _AppDrawer extends ConsumerWidget {
  final ValueChanged<int> onNavigateIndex;
  const _AppDrawer({required this.onNavigateIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(premiumProvider);
    final cs = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    if (location.startsWith('/counters')) selectedIndex = 1;
    if (location.startsWith('/reports')) selectedIndex = 2;
    if (location.startsWith('/notifications')) selectedIndex = 3;
    if (location.startsWith('/backup')) selectedIndex = 4;
    if (location.startsWith('/cloud-backup')) selectedIndex = 4;

    Widget tile({required int index, required String label, required Widget leading, String? subtitle}) {
      final selected = selectedIndex == index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Material(
          color: selected ? cs.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Scaffold.maybeOf(context)?.closeDrawer();
              onNavigateIndex(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: selected
                    ? Border.all(color: cs.primary.withValues(alpha: 0.2))
                    : null,
              ),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                            color: selected ? cs.onPrimaryContainer : cs.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.chevron_right, size: 18, color: cs.primary),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header do Drawer com gradiente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primaryContainer, cs.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.event_note, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Lembre+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isPro ? Colors.amber : Colors.white24,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPro ? 'PRO' : 'FREE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isPro ? Colors.black : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Organize seus contadores', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  tile(index: 0, label: 'Dashboard', subtitle: 'Visão geral', leading: const Text('📋', style: TextStyle(fontSize: 22))),
                  tile(index: 1, label: 'Contadores', subtitle: 'Seus eventos', leading: const Text('🧮', style: TextStyle(fontSize: 22))),
                  tile(index: 2, label: 'Relatórios', subtitle: 'Análise detalhada', leading: const Text('📈', style: TextStyle(fontSize: 22))),
                  tile(index: 3, label: 'Notificações', subtitle: 'Lembretes agendados', leading: const Text('🔔', style: TextStyle(fontSize: 22))),
                  tile(index: 4, label: 'Backup', subtitle: 'Local e nuvem', leading: const Text('☁️', style: TextStyle(fontSize: 22))),
                ],
              ),
            ),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
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
          Icon(Icons.info_outline, size: 14, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(v, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

// Botão da coroa Pro com modal de simulação
class _PremiumCrownButton extends ConsumerWidget {
  const _PremiumCrownButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(premiumProvider);
    // Em produção, só exibimos o ícone de coroa no cabeçalho se o usuário for Pro
    if (!useSimulatedBilling && !isPro) {
      return const SizedBox.shrink();
    }
    return Tooltip(
      message: isPro ? 'Você é Pro! Obrigado pelo apoio.' : 'Seja Pro! Clique para saber mais',
      child: isPro
          ? _ShimmerIcon(
              onPressed: useSimulatedBilling ? () => _showPremiumDialog(context, ref) : null,
              child: Icon(
                Icons.workspace_premium,
                color: Colors.amber.shade600,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.workspace_premium_outlined),
              onPressed: useSimulatedBilling ? () => _showPremiumDialog(context, ref) : null,
            ),
    );
  }

  void _showPremiumDialog(BuildContext context, WidgetRef ref) {
    final isPro = ref.read(premiumProvider);
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('Assinatura Lembre+'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPro
                  ? 'Você está utilizando a versão Lembre+ Pro! Obrigado pelo apoio.'
                  : 'Você está utilizando a versão gratuita do Lembre+.',
            ),
            const SizedBox(height: 12),
            Text(
              'Recursos da versão Pro:\n'
              '• Lembretes ativos ilimitados (grátis até 10)\n'
              '• Categorias personalizadas ilimitadas\n'
              '• Backup automático em tempo real no Google Drive',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Simular Modo Pro:', style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: isPro,
                  activeThumbColor: Colors.amber,
                  onChanged: (val) async {
                    await ref.read(premiumProvider.notifier).setPremium(val);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// Widget de ícone com shimmer para a coroa Pro
class _ShimmerIcon extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  const _ShimmerIcon({required this.child, this.onPressed});

  @override
  State<_ShimmerIcon> createState() => _ShimmerIconState();
}

class _ShimmerIconState extends State<_ShimmerIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
              colors: const [
                Colors.amber,
                Colors.white,
                Colors.amber,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: child,
        );
      },
      child: IconButton(
        icon: widget.child,
        onPressed: widget.onPressed,
      ),
    );
  }
}

// Botão para alternar entre tema claro e escuro
class _ThemeToggleButton extends ConsumerWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
                  (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    
    return Tooltip(
      message: isDark ? 'Mudar para tema claro' : 'Mudar para tema escuro',
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            key: ValueKey(isDark),
          ),
        ),
        onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
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
    Widget defaultAvatar() => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.onPrimary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: cs.onPrimary.withValues(alpha: 0.1),
            child: Icon(Icons.person_outline, size: 18, color: cs.onPrimary.withValues(alpha: 0.7)),
          ),
        );

    return userAsync.maybeWhen(
      data: (user) {
        if (user == null || user.photoUrl == null) {
          return defaultAvatar();
        }
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.onPrimary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(user.photoUrl!),
            backgroundColor: cs.surface,
          ),
        );
      },
      orElse: () => defaultAvatar(),
    );
  }
}
