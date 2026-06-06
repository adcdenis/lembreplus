import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lembreplus/state/premium_provider.dart';

class PremiumPaywallWidget extends ConsumerWidget {
  final String? customMessage;
  const PremiumPaywallWidget({super.key, this.customMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(premiumProvider);
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer.withValues(alpha: 0.15),
                cs.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge de Coroa Real
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 48,
                  color: Colors.amber,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(delay: 2.seconds, duration: 1500.ms)
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.08, 1.08),
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 16),
              Text(
                'Lembre+ Pro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                customMessage ?? 'Desbloqueie todo o poder da produtividade sem limites.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Recursos Premium
              _buildFeatureRow(
                context,
                icon: Icons.check_circle_outline_rounded,
                title: 'Lembretes Ilimitados',
                description: 'Crie quantos lembretes ativos desejar. Sem travas.',
              ),
              _buildFeatureRow(
                context,
                icon: Icons.label_important_rounded,
                title: 'Categorias Personalizadas',
                description: 'Crie e organize seus lembretes com categorias personalizadas ilimitadas.',
              ),
              _buildFeatureRow(
                context,
                icon: Icons.cloud_done_outlined,
                title: 'Sincronização em Nuvem',
                description: 'Backup automático e em tempo real direto no seu Google Drive.',
              ),
              _buildFeatureRow(
                context,
                icon: Icons.security_update_good_outlined,
                title: 'Sua privacidade garantida',
                description: 'Seus dados permanecem 100% sob seu controle.',
              ),
              const SizedBox(height: 24),
              
              // Botão de Compra / Simulação
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Color(0xFFF57F17)], // amber -> amber.shade800
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black87,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  onPressed: () async {
                    if (useSimulatedBilling) {
                      await ref.read(premiumProvider.notifier).setPremium(!isPro);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  !isPro
                                      ? 'Modo Pro ativado com sucesso!'
                                      : 'Modo Pro desativado. Retornou para versão grátis.',
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      // Fluxo real de compra da Google Play Billing em Produção
                      try {
                        await ref.read(premiumProvider.notifier).buyPro();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              content: Text('Falha ao iniciar compra: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    isPro 
                        ? 'Desativar Versão Pro (Testar Free)' 
                        : (useSimulatedBilling ? 'Ativar Lembre+ Pro (Simulação)' : 'Desbloquear Lembre+ Pro'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ),
              ).animate().scale(delay: 500.ms, duration: 250.ms),
              const SizedBox(height: 12),
              Text(
                useSimulatedBilling 
                    ? 'Esta é uma simulação de pagamento da Google Play. Clique para testar o comportamento imediatamente.'
                    : 'Adquira a versão premium e desbloqueie todos os recursos de forma vitalícia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (!useSimulatedBilling) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(premiumProvider.notifier).restorePurchases();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('Verificação de compras anteriores iniciada.'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                            content: Text('Erro ao restaurar compras: $e'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restaurar Compras Anteriores'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
