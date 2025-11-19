import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lembreplus/data/models/counter.dart' as model;
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/domain/time_utils.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/domain/report_export.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _type = 'Todos'; // Todos | Passado | Futuro
  String _recurrence = 'Todos'; // Todos | Nenhuma | Semanal | Mensal | Anual
  String _category = 'Todas';
  final _descCtrl = TextEditingController();
  DateTime _now = DateTime.now();

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final base = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final base = _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _type = 'Todos';
      _recurrence = 'Todos';
      _category = 'Todas';
      _descCtrl.clear();
    });
  }

  DateTime _effectiveDate(DateTime base, String? recurrence) {
    final r = Recurrence.fromString(recurrence);
    return nextRecurringDate(base, r, _now);
  }

  String _labelForRecurrence(Recurrence r) {
    switch (r) {
      case Recurrence.none:
        return 'Nenhuma';
      case Recurrence.weekly:
        return 'Semanal';
      case Recurrence.monthly:
        return 'Mensal';
      case Recurrence.yearly:
        return 'Anual';
    }
  }

  String _formatDiff(DateTime target) {
    final diff = calendarDiff(_now, target);
    final parts = <String>[];
    if (diff.years > 0) parts.add('${diff.years} ano${diff.years == 1 ? '' : 's'}');
    if (diff.months > 0) parts.add('${diff.months} m${diff.months == 1 ? 'ês' : 'eses'}');
    if (diff.days > 0) parts.add('${diff.days} dia${diff.days == 1 ? '' : 's'}');
    if (diff.hours > 0) parts.add('${diff.hours} hora${diff.hours == 1 ? '' : 's'}');
    if (diff.minutes > 0) parts.add('${diff.minutes} minuto${diff.minutes == 1 ? '' : 's'}');
    if (parts.isEmpty) parts.add('${diff.seconds} segundo${diff.seconds == 1 ? '' : 's'}');
    return parts.join(', ');
  }

  List<model.Counter> _applyFilters(List<model.Counter> list, List<String> categories) {
    List<model.Counter> out = List.of(list);
    // Date range filters (inclusive day)
    if (_startDate != null) {
      out = out.where((c) => c.eventDate.isAfter(DateTime(_startDate!.year, _startDate!.month, _startDate!.day).subtract(const Duration(seconds: 1)))).toList();
    }
    if (_endDate != null) {
      out = out.where((c) => c.eventDate.isBefore(DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59))).toList();
    }
    if (_type != 'Todos') {
      out = out.where((c) {
        final eff = _effectiveDate(c.eventDate, c.recurrence);
        final past = isPast(eff, now: _now);
        return _type == 'Passado' ? past : !past; // Futuro
      }).toList();
    }
    if (_recurrence != 'Todos') {
      out = out.where((c) {
        final r = Recurrence.fromString(c.recurrence);
        return (_recurrence == 'Nenhuma' && r == Recurrence.none) ||
            (_recurrence == 'Semanal' && r == Recurrence.weekly) ||
            (_recurrence == 'Mensal' && r == Recurrence.monthly) ||
            (_recurrence == 'Anual' && r == Recurrence.yearly);
      }).toList();
    }
    if (_category != 'Todas') {
      out = out.where((c) => (c.category ?? '') == _category).toList();
    }
    if (_descCtrl.text.trim().isNotEmpty) {
      final q = _descCtrl.text.trim().toLowerCase();
      out = out.where((c) => (c.description ?? '').toLowerCase().contains(q)).toList();
    }
    return out;
  }

  List<ReportRow> _toReportRows(List<model.Counter> counters) {
    return counters.map((c) {
      final eff = _effectiveDate(c.eventDate, c.recurrence);
      final past = isPast(eff, now: _now);
      final diffLabel = _formatDiff(eff);
      return ReportRow(
        nome: c.name,
        descricao: c.description ?? '',
        dataHora: c.eventDate,
        categoria: c.category ?? '-'
        ,
        repeticao: _labelForRecurrence(Recurrence.fromString(c.recurrence)),
        tempoFormatado: past ? diffLabel : diffLabel,
      );
    }).toList();
  }

  Future<void> _generateAndShareXlsx(List<ReportRow> rows) async {
    final file = await generateXlsxReport(rows);
    await shareFile(file, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  Future<void> _generateAndSharePdf(List<ReportRow> rows) async {
    final file = await generatePdfReport(rows);
    await shareFile(file, mimeType: 'application/pdf');
  }

  String _pluralize(int value, String singular, String plural) =>
      value == 1 ? singular : plural;

  @override
  Widget build(BuildContext context) {
    final countersAsync = ref.watch(countersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd/MM/yyyy');


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Text('📈', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Relatórios', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          const Text('Gere relatórios detalhados dos seus contadores.'),
          const SizedBox(height: 16),

          // Filtros
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Data início',
                                hintText: 'dd/mm/aaaa',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _pickStartDate(context),
                                ),
                              ),
                              controller: TextEditingController(text: _startDate == null ? '' : df.format(_startDate!)),
                              onTap: () => _pickStartDate(context),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Data fim',
                                hintText: 'dd/mm/aaaa',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _pickEndDate(context),
                                ),
                              ),
                              controller: TextEditingController(text: _endDate == null ? '' : df.format(_endDate!)),
                              onTap: () => _pickEndDate(context),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_type),
                              initialValue: _type,
                              items: const [
                                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                                DropdownMenuItem(value: 'Passado', child: Text('Passado')),
                                DropdownMenuItem(value: 'Futuro', child: Text('Futuro')),
                              ],
                              onChanged: (v) => setState(() => _type = v ?? 'Todos'),
                              decoration: const InputDecoration(labelText: 'Tipo'),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_recurrence),
                              initialValue: _recurrence,
                              items: const [
                                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                                DropdownMenuItem(value: 'Nenhuma', child: Text('Nenhuma')),
                                DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                                DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                                DropdownMenuItem(value: 'Anual', child: Text('Anual')),
                              ],
                              onChanged: (v) => setState(() => _recurrence = v ?? 'Todos'),
                              decoration: const InputDecoration(labelText: 'Tipo de repetição'),
                            ),
                          ),
                          categoriesAsync.when(
                            loading: () => SizedBox(width: itemWidth, child: const LinearProgressIndicator()),
                            error: (e, st) => SizedBox(width: itemWidth, child: const Text('Erro categorias')), 
                            data: (cats) {
                              final items = ['Todas', ...cats.map((c) => c.name)];
                              if (!items.contains(_category)) _category = 'Todas';
                              return SizedBox(
                                width: itemWidth,
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(_category),
                                  initialValue: _category,
                                  items: items
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _category = v ?? 'Todas'),
                                  decoration: const InputDecoration(labelText: 'Categoria'),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TextField(
                              controller: _descCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Descrição',
                                hintText: 'Filtrar por texto na descrição',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth, // Full width for the button
                            child: FilledButton.tonalIcon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.filter_alt_off),
                              label: const Text('Limpar filtros'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _now = DateTime.now()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recalcular tempo'),
                      ),
                      countersAsync.when(
                        loading: () => const SizedBox(),
                        error: (e, st) => const SizedBox(),
                        data: (counters) {
                          final cats = categoriesAsync.maybeWhen(data: (v) => v.map((c) => c.name).toList(), orElse: () => <String>[]);
                          final filtered = _applyFilters(counters, cats);
                          final rows = _toReportRows(filtered);
                          return Wrap(spacing: 8, children: [
                            FilledButton.icon(
                              onPressed: rows.isEmpty ? null : () => _generateAndShareXlsx(rows),
                              icon: const Icon(Icons.grid_on),
                              label: const Text('Gerar Excel'),
                            ),
                            FilledButton.icon(
                              onPressed: rows.isEmpty ? null : () => _generateAndSharePdf(rows),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Gerar PDF'),
                            ),
                            Text('Atualizado às ${DateFormat('HH:mm').format(_now)}',
                                style: TextStyle(color: cs.onSurfaceVariant)),
                          ]);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Prévia dos dados
          countersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erro ao carregar: $e')),
            data: (counters) {
              final cats = categoriesAsync.maybeWhen(data: (v) => v.map((c) => c.name).toList(), orElse: () => <String>[]);
              final filtered = _applyFilters(counters, cats);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${filtered.length} contador(es) encontrado(s)',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final c = filtered[i];
                          final eff = _effectiveDate(c.eventDate, c.recurrence);
                          final past = isPast(eff, now: _now);
                          final diff = calendarDiff(_now, eff);
                          
                          final tint = !past ? cs.primaryContainer : cs.errorContainer;
                          final recurrenceVal = Recurrence.fromString(c.recurrence);

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outlineVariant),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: !past
                                    ? [
                                        cs.primaryContainer.withValues(alpha: 0.6),
                                        cs.primaryContainer.withValues(alpha: 0.3),
                                      ]
                                    : [
                                        cs.errorContainer.withValues(alpha: 0.6),
                                        cs.errorContainer.withValues(alpha: 0.3),
                                      ],
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: !past
                                            ? cs.primary.withValues(alpha: 0.1)
                                            : cs.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        !past ? '🗓️' : '🕰️',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: !past ? cs.primary : cs.error,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (diff.years > 0) ...[
                                        _CounterBox(
                                          value: diff.years,
                                          label: _pluralize(diff.years, 'Ano', 'Anos'),
                                          tint: tint,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      if (diff.months > 0) ...[
                                        _CounterBox(
                                          value: diff.months,
                                          label: _pluralize(diff.months, 'Mês', 'Meses'),
                                          tint: tint,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      _CounterBox(
                                        value: diff.days,
                                        label: _pluralize(diff.days, 'Dia', 'Dias'),
                                        tint: tint,
                                      ),
                                      const SizedBox(width: 4),
                                      _CounterBox(
                                        value: diff.hours,
                                        label: _pluralize(diff.hours, 'Hora', 'Horas'),
                                        tint: tint,
                                      ),
                                      const SizedBox(width: 4),
                                      _CounterBox(
                                        value: diff.minutes,
                                        label: _pluralize(diff.minutes, 'Minuto', 'Minutos'),
                                        tint: tint,
                                      ),
                                      const SizedBox(width: 4),
                                      _CounterBox(
                                        value: diff.seconds,
                                        label: _pluralize(diff.seconds, 'Segundo', 'Segundos'),
                                        tint: tint,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if ((c.category ?? '').trim().isNotEmpty)
                                      Chip(
                                        avatar: Text('🏷️', style: TextStyle(fontSize: 14, color: cs.onSecondaryContainer)),
                                        label: Text(c.category!),
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: cs.secondaryContainer,
                                        labelStyle: TextStyle(color: cs.onSecondaryContainer),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    if (recurrenceVal != Recurrence.none)
                                      Chip(
                                        avatar: Text('🔁', style: TextStyle(fontSize: 16, color: cs.onTertiaryContainer)),
                                        label: Text(_labelForRecurrence(recurrenceVal)),
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: cs.tertiaryContainer,
                                        labelStyle: TextStyle(color: cs.onTertiaryContainer),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(eff),
                                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CounterBox extends StatelessWidget {
  final int value;
  final String label;
  final Color tint;
  const _CounterBox({required this.value, required this.label, required this.tint});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.85), tint.withValues(alpha: 0.5)],
        ),
        boxShadow: [
          BoxShadow(color: tint.withValues(alpha: 0.28), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}