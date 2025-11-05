import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lembreplus/data/models/counter.dart' as model;
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/domain/recurrence.dart';

class CounterFormPage extends ConsumerStatefulWidget {
  final int? counterId;
  const CounterFormPage({super.key, this.counterId});

  @override
  ConsumerState<CounterFormPage> createState() => _CounterFormPageState();
}

class _CounterFormPageState extends ConsumerState<CounterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _recurrence = Recurrence.none.name;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _loadForEditIfNeeded();
  }

  Future<void> _loadForEditIfNeeded() async {
    final id = widget.counterId;
    if (id != null) {
      final repo = ref.read(counterRepositoryProvider);
      final c = await repo.byId(id);
      if (c != null) {
        setState(() {
          _nameCtrl.text = c.name;
          _descCtrl.text = c.description ?? '';
          _categoryCtrl.text = c.category ?? '';
          _date = c.eventDate;
          _time = TimeOfDay(hour: c.eventDate.hour, minute: c.eventDate.minute);
          _recurrence = c.recurrence ?? Recurrence.none.name;
          _createdAt = c.createdAt;
        });
      }
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(isEdit ? 'Editar Contador' : 'Novo Contador', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text('Data: ${_date.day}/${_date.month}/${_date.year}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text('Hora: ${_time.format(context)}'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Recorrência', border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _recurrence,
                  items: Recurrence.values
                      .map((r) => DropdownMenuItem(value: r.name, child: Text(_labelForRecurrence(r))))
                      .toList(),
                  onChanged: (v) => setState(() => _recurrence = v ?? Recurrence.none.name),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _onSubmit,
                  icon: const Icon(Icons.save),
                  label: Text(isEdit ? 'Salvar' : 'Criar'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
            ]),
          ],
        ),
      ),
    );
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

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(counterRepositoryProvider);
    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

    if (widget.counterId == null) {
      final now = DateTime.now();
      final c = model.Counter(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        eventDate: dt,
        category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        recurrence: _recurrence,
        createdAt: now,
        updatedAt: now,
      );
      final id = await repo.create(c);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contador criado com sucesso')));
      context.go('/counter/$id');
    } else {
      final now = DateTime.now();
      final c = model.Counter(
        id: widget.counterId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        eventDate: dt,
        category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        recurrence: _recurrence,
        createdAt: _createdAt ?? now,
        updatedAt: now,
      );
      final ok = await repo.update(c);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Contador atualizado' : 'Falha ao atualizar')));
      context.go('/counter/${widget.counterId}');
    }
  }
}