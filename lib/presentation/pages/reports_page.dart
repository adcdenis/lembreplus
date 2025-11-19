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
    final diff = durationDiff(_now, target);
    final parts = <String>[];
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

  @override
  Widget build(BuildContext context) {
    final countersAsync = ref.watch(countersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd/MM/yyyy');
    final tf = DateFormat('HH:mm');

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
                              value: _type,
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
                              value: _recurrence,
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
                                  value: _category,
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
                          final diffStr = _formatDiff(eff);
                          final label = past ? 'Passaram $diffStr' : 'Faltam $diffStr';
                              final timeColor = past ? Colors.red : Colors.blue;
                              final recurrenceVal = Recurrence.fromString(c.recurrence);
                              return Container(
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    c.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${df.format(c.eventDate)} • ${tf.format(c.eventDate)}',
                                        style: TextStyle(color: cs.onSurfaceVariant),
                                      ),
                                      if ((c.category ?? '').isNotEmpty)
                                        Text(
                                          c.category!,
                                          style: TextStyle(color: cs.onSurfaceVariant),
                                        ),
                                      if (recurrenceVal != Recurrence.none)
                                        Text(
                                          _labelForRecurrence(recurrenceVal),
                                          style: TextStyle(color: cs.onSurfaceVariant),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: timeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: null,
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