import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lembreplus/data/models/counter.dart' as model;
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/data/models/category.dart' as cat;
import 'package:lembreplus/domain/category_utils.dart';
import 'package:lembreplus/domain/time_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lembreplus/presentation/widgets/animated_button.dart';

class CounterFormPage extends ConsumerStatefulWidget {
  final int? counterId;
  final String? initialCategory;
  const CounterFormPage({super.key, this.counterId, this.initialCategory});

  @override
  ConsumerState<CounterFormPage> createState() => _CounterFormPageState();
}

class _CounterFormPageState extends ConsumerState<CounterFormPage> {
  bool _canPopSafely(BuildContext context) {
    try {
      return GoRouter.of(context).canPop();
    } catch (_) {
      return true;
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  TextEditingController? _categoryFieldCtrl;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _recurrence = Recurrence.none.name;
  int _customRecurrenceValue = 1;
  String _customRecurrenceUnit = 'hours';
  List<int> _alertOffsets = []; 
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _loadForEditIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifService = ref.read(notificationServiceProvider);
      notifService.init().then((_) => notifService.requestPermissions());
    });
  }

  Future<void> _loadForEditIfNeeded() async {
    final id = widget.counterId;
    if (id != null) {
      final repo = ref.read(counterRepositoryProvider);
      final c = await repo.byId(id);
      if (c != null) {
        final now = DateTime.now();
        final definition = RecurrenceDefinition.parse(c.recurrence);
        final effective = definition.isNone
            ? c.eventDate
            : nextRecurringDateFromString(c.eventDate, c.recurrence, now);
        final useEffective =
            !definition.isNone &&
            effective.isAfter(now) &&
            effective != c.eventDate;
        final base = useEffective ? effective : c.eventDate;
        setState(() {
          _nameCtrl.text = c.name;
          _descCtrl.text = c.description ?? '';
          _categoryCtrl.text = c.category ?? '';
          _categoryFieldCtrl?.text = c.category ?? '';
          _date = base;
          _time = TimeOfDay(hour: base.hour, minute: base.minute);
          _loadRecurrence(c.recurrence);
          _alertOffsets = List.from(c.alertOffsets);
          _createdAt = c.createdAt;
        });
      }
    } else if (widget.initialCategory != null) {
      setState(() {
        _categoryCtrl.text = widget.initialCategory!;
        _categoryFieldCtrl?.text = widget.initialCategory!;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.counterId != null;
    final categoriesAsync = ref.watch(categoriesProvider);

    return PopScope(
      canPop: _canPopSafely(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/counters');
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  isEdit ? 'Editar Contador' : 'Novo Contador',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _date = DateTime(
                              picked.year, picked.month, picked.day,
                              _date.hour, _date.minute,
                            ));
                          }
                        },
                        icon: const Icon(Icons.date_range, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year.toString().substring(2)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _time,
                          );
                          if (picked != null) setState(() => _time = picked);
                        },
                        icon: const Icon(Icons.access_time, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(_time.format(context), style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          final now = DateTime.now();
                          setState(() {
                            _date = now;
                            _time = TimeOfDay(hour: now.hour, minute: now.minute);
                          });
                        },
                        icon: const Icon(Icons.schedule, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Agora', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                  maxLength: 100,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                  maxLines: 2,
                  maxLength: 300,
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue tv) {
                        final q = tv.text.trim().toLowerCase();
                        return categoriesAsync.maybeWhen(
                          data: (cats) {
                            if (q.isEmpty) return cats.map((c) => c.name);
                            final nq = normalizeCategory(q);
                            return cats.where((c) =>
                                c.name.toLowerCase().contains(q) ||
                                c.normalized.contains(nq)).map((c) => c.name);
                          },
                          orElse: () => const [],
                        );
                      },
                      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                        _categoryFieldCtrl = textController;
                        if (_categoryCtrl.text.isNotEmpty && textController.text.isEmpty) {
                          textController.text = _categoryCtrl.text;
                        }
                        return TextFormField(
                          controller: textController,
                          focusNode: focusNode,
                          maxLength: 100,
                          onChanged: (v) {
                            _categoryCtrl.text = v;
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Selecione ou digite uma categoria',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_categoryCtrl.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _categoryCtrl.clear();
                                      textController.clear();
                                      setState(() {});
                                    },
                                  ),
                                Builder(builder: (ctx) {
                                  final cats = categoriesAsync.maybeWhen(
                                      data: (list) => list, orElse: () => const <cat.Category>[]);
                                  if (cats.isEmpty) return const SizedBox.shrink();
                                  return PopupMenuButton<String>(
                                    icon: const Icon(Icons.list),
                                    onSelected: (value) {
                                      _categoryCtrl.text = value;
                                      textController.text = value;
                                      setState(() {});
                                    },
                                    itemBuilder: (ctx) => cats.map((c) => 
                                      PopupMenuItem(value: c.name, child: Text(c.name))).toList(),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                      onSelected: (value) {
                        _categoryCtrl.text = value;
                        _categoryFieldCtrl?.text = value;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (cats) {
                        if (cats.isEmpty) return const SizedBox.shrink();
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: cats.map((c) {
                              final selected = _categoryCtrl.text.trim() == c.name;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InputChip(
                                  label: Text(c.name),
                                  selected: selected,
                                  onPressed: () {
                                    _categoryCtrl.text = c.name;
                                    _categoryFieldCtrl?.text = c.name;
                                    setState(() {});
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Recorrência', border: OutlineInputBorder()),
                  child: Column(
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _recurrence,
                          isExpanded: true,
                          items: [
                            ...Recurrence.values.where((r) => r != Recurrence.every6Hours && r != Recurrence.every12Hours).map((r) => 
                              DropdownMenuItem(value: r.name, child: Text(_labelForRecurrence(r)))),
                            const DropdownMenuItem(value: 'custom', child: Text('Personalizado')),
                          ],
                          onChanged: (v) => setState(() => _recurrence = v ?? Recurrence.none.name),
                        ),
                      ),
                      if (_recurrence == 'custom') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: _customRecurrenceValue.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Valor', border: OutlineInputBorder()),
                                onChanged: (v) => setState(() => _customRecurrenceValue = int.tryParse(v) ?? 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _customRecurrenceUnit,
                                decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'hours', child: Text('Horas')),
                                  DropdownMenuItem(value: 'days', child: Text('Dias')),
                                  DropdownMenuItem(value: 'years', child: Text('Anos')),
                                ],
                                onChanged: (v) => setState(() => _customRecurrenceUnit = v ?? 'hours'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lembretes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        if (_alertOffsets.length < 5)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isEdit && widget.counterId != null) ...[
                                IconButton(
                                  onPressed: () async {
                                    final notifService = ref.read(notificationServiceProvider);
                                    final pending = await notifService.getPendingNotifications();
                                    // Filtra notificações deste contador (id ~ 100 == counterId)
                                    final myAlerts = pending
                                        .where((n) => (n.id ~/ 100) == widget.counterId)
                                        .toList();

                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Notificações Ativas'),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            child: myAlerts.isEmpty
                                                ? const Text('Nenhuma notificação agendada para este contador.')
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: myAlerts.length,
                                                    itemBuilder: (ctx, i) {
                                                      final n = myAlerts[i];
                                                      return ListTile(
                                                        title: Text('ID: ${n.id}'),
                                                        subtitle: Text('${n.title}\n${n.body}'),
                                                        isThreeLine: true,
                                                      );
                                                    },
                                                  ),
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
                                  },
                                  icon: const Icon(Icons.notifications_active_outlined),
                                  tooltip: 'Verificar Notificações',
                                ),
                                const SizedBox(width: 8),
                              ],
                              TextButton.icon(
                                onPressed: _showAddAlertDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Adicionar'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (_alertOffsets.isEmpty)
                      const Center(child: Text('Nenhum lembrete configurado', style: TextStyle(color: Colors.grey)))
                    else
                      ..._alertOffsets.asMap().entries.map((entry) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: Text(_formatAlertOffset(entry.value)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _alertOffsets.removeAt(entry.key)),
                          ),
                        ),
                      )),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedInteractiveItem(
                        child: FilledButton.icon(
                          onPressed: _onSubmit,
                          icon: const Icon(Icons.save),
                          label: Text(isEdit ? 'Salvar' : 'Criar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        if (_canPopSafely(context)) {
                          context.pop();
                        } else {
                          context.go('/counters');
                        }
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  void _loadRecurrence(String? recurrence) {
    final definition = RecurrenceDefinition.parse(recurrence);
    if (definition.isCustom) {
      _recurrence = 'custom';
      _customRecurrenceValue = definition.count!;
      _customRecurrenceUnit = definition.unit!.name;
      return;
    }
    _recurrence = definition.recurrence.name;
  }

  String _labelForRecurrence(Recurrence r) {
    switch (r) {
      case Recurrence.none: return 'Nenhuma';
      case Recurrence.every6Hours: return '6 horas';
      case Recurrence.every12Hours: return '12 horas';
      case Recurrence.daily: return 'Diário';
      case Recurrence.weekly: return 'Semanal';
      case Recurrence.monthly: return 'Mensal';
      case Recurrence.yearly: return 'Anual';
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(counterRepositoryProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final notifService = ref.read(notificationServiceProvider);
    final isPro = ref.read(premiumProvider);

    // 1. Limite de lembretes ativos (máximo 10 na versão gratuita)
    if (!isPro) {
      final now = DateTime.now();
      final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
      final recurrenceStr = _recurrence == 'custom' ? '$_customRecurrenceValue $_customRecurrenceUnit' : _recurrence;
      
      // Calcula lembretes ativos do contador que está sendo salvo
      final effectiveEventDate = RecurrenceDefinition.parse(recurrenceStr).isNone
          ? dt
          : nextRecurringDateFromString(dt, recurrenceStr, now);
      
      int activeAlertsForThisCounter = 0;
      for (final offset in _alertOffsets) {
        final scheduledDate = effectiveEventDate.subtract(Duration(minutes: offset));
        if (scheduledDate.isAfter(now)) {
          activeAlertsForThisCounter++;
        }
      }

      // Calcula lembretes ativos dos outros contadores
      final counters = await repo.all();
      int activeAlertsForOtherCounters = 0;
      for (final c in counters) {
        if (widget.counterId != null && c.id == widget.counterId) {
          continue;
        }
        final cEffectiveEventDate = RecurrenceDefinition.parse(c.recurrence).isNone
            ? c.eventDate
            : nextRecurringDateFromString(c.eventDate, c.recurrence, now);
        
        for (final offset in c.alertOffsets) {
          final scheduledDate = cEffectiveEventDate.subtract(Duration(minutes: offset));
          if (scheduledDate.isAfter(now)) {
            activeAlertsForOtherCounters++;
          }
        }
      }

      final totalActiveAlerts = activeAlertsForOtherCounters + activeAlertsForThisCounter;
      if (!mounted) return;
      if (totalActiveAlerts > 10) {
        _showProLimitDialog(
          context,
          'Você atingiu o limite máximo de 10 lembretes ativos na versão gratuita. '
          'Atualmente você tem $activeAlertsForOtherCounters lembretes ativos em outros contadores '
          'e está configurando mais $activeAlertsForThisCounter neste contador. '
          'Faça upgrade para a versão Pro para ter lembretes ilimitados!',
        );
        return;
      }
    }

    final catName = _categoryCtrl.text.trim();

    // 2. Limite de categorias personalizadas (exclusivo Pro)
    if (catName.isNotEmpty) {
      final normCat = normalizeCategory(catName);
      final isDefault = ['pessoal', 'saude', 'financeiro', 'documentos', 'veiculo'].contains(normCat);
      if (!isPro && !isDefault) {
        if (!mounted) return;
        _showProLimitDialog(
          context,
          'A criação de categorias personalizadas ("$catName") é exclusiva da versão Pro. '
          'Use as categorias padrão (Pessoal, Saúde, Financeiro, Documentos, Veículo) ou faça upgrade!',
        );
        return;
      }
    }

    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    if (catName.isNotEmpty) {
      await categoryRepo.create(cat.Category(name: catName, normalized: normalizeCategory(catName)));
    }

    final c = model.Counter(
      id: widget.counterId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      eventDate: dt,
      category: catName.isEmpty ? null : catName,
      recurrence: _recurrence == 'custom' ? '$_customRecurrenceValue $_customRecurrenceUnit' : _recurrence,
      alertOffsets: _alertOffsets,
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    int? savedId;
    if (widget.counterId == null) {
      savedId = await repo.createWithHistory(c);
    } else {
      await repo.updateWithHistory(c);
      savedId = widget.counterId;
    }

    if (savedId != null) {
      await notifService.syncAllCounterNotifications(ref.read(databaseProvider));
    }
    if (mounted) {
      if (_canPopSafely(context)) {
        context.pop();
      } else {
        context.go('/counters');
      }
    }
  }

  String _formatAlertOffset(int minutes) {
    if (minutes < 60) return '$minutes min antes';
    if (minutes < 1440) return '${minutes ~/ 60} h antes';
    return '${minutes ~/ 1440} d antes';
  }

  void _showAddAlertDialog() {
    int val = 1;
    String unit = 'minutes';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Adicionar Lembrete'),
          content: Row(
            children: [
              Expanded(child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) => val = int.tryParse(v) ?? 1,
              )),
              const SizedBox(width: 8),
              Expanded(child: DropdownButton<String>(
                value: unit,
                items: const [
                  DropdownMenuItem(value: 'minutes', child: Text('Minutos')),
                  DropdownMenuItem(value: 'hours', child: Text('Horas')),
                  DropdownMenuItem(value: 'days', child: Text('Dias')),
                ],
                onChanged: (v) => setDialogState(() => unit = v!),
              )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(onPressed: () {
              int mins = val;
              if (unit == 'hours') mins *= 60;
              if (unit == 'days') mins *= 1440;
              setState(() { _alertOffsets.add(mins); _alertOffsets.sort(); });
              Navigator.pop(ctx);
            }, child: const Text('Adicionar')),
          ],
        ),
      ),
    );
  }

  void _showProLimitDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('Recurso Premium'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showQuickUpgradeDialog(context);
            },
            child: const Text('Ver Versão Pro'),
          ),
        ],
      ),
    );
  }

  void _showQuickUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ativar Modo Pro (Simulação)'),
        content: const Text(
          'Deseja simular a compra da versão Pro do Lembre+ para desbloquear este e outros recursos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Agora não'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  await ref.read(premiumProvider.notifier).setPremium(true);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modo Pro ativado com sucesso! Salve seu lembrete novamente.'),
                      ),
                    );
                  }
                },
                child: const Text('Ativar Pro'),
              );
            },
          ),
        ],
      ),
    );
  }
}