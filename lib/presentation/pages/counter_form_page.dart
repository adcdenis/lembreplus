import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lembreplus/data/models/counter.dart' as model;
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/data/models/category.dart' as cat;
import 'package:lembreplus/domain/category_utils.dart';

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
  // Holds a reference to the Autocomplete text field controller to keep UI in sync
  TextEditingController? _categoryFieldCtrl;
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final countersAsync = ref.watch(countersProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    return Padding(
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
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categoria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                // Autocomplete para listar e buscar categorias existentes
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue tv) {
                    final q = tv.text.trim().toLowerCase();
                    return categoriesAsync.maybeWhen(
                      data: (cats) {
                        if (q.isEmpty) return cats.map((c) => c.name);
                        final nq = normalizeCategory(q);
                        return cats
                            .where(
                              (c) =>
                                  c.name.toLowerCase().contains(q) ||
                                  c.normalized.contains(nq),
                            )
                            .map((c) => c.name);
                      },
                      orElse: () => const [],
                    );
                  },
                  fieldViewBuilder:
                      (context, textController, focusNode, onFieldSubmitted) {
                        // Guarda referência para sincronizar quando chips/botões atualizam a categoria
                        _categoryFieldCtrl = textController;
                        return TextFormField(
                          controller: textController,
                          focusNode: focusNode,
                          onChanged: (v) {
                            // Mantém _categoryCtrl como fonte de verdade para outros widgets
                            _categoryCtrl
                              ..text = v
                              ..selection = textController.selection;
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
                                    tooltip: 'Limpar',
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _categoryCtrl.clear();
                                      _categoryFieldCtrl?.clear();
                                      setState(() {});
                                    },
                                  ),
                                // Lista rápida de categorias já existentes
                                Builder(
                                  builder: (ctx) {
                                    final cats = categoriesAsync.maybeWhen(
                                      data: (list) => list,
                                      orElse: () => const <cat.Category>[],
                                    );
                                    if (cats.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return PopupMenuButton<String>(
                                      tooltip: 'Selecionar categoria existente',
                                      icon: const Icon(Icons.list),
                                      itemBuilder: (ctx) => cats
                                          .map(
                                            (c) => PopupMenuItem<String>(
                                              value: c.name,
                                              child: Text(c.name),
                                            ),
                                          )
                                          .toList(),
                                      onSelected: (value) {
                                        _categoryCtrl.text = value;
                                        _categoryFieldCtrl?.text = value;
                                        _categoryFieldCtrl?.selection =
                                            TextSelection.collapsed(
                                          offset: value.length,
                                        );
                                        setState(() {});
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Criar nova categoria',
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final name =
                                        (_categoryFieldCtrl?.text ??
                                                _categoryCtrl.text)
                                            .trim();
                                    if (name.isEmpty) return;
                                    final normalized = normalizeCategory(name);
                                    // Evita duplicação no client-side
                                    final exists = categoriesAsync.maybeWhen(
                                      data: (cats) => cats.any(
                                        (c) => c.normalized == normalized,
                                      ),
                                      orElse: () => false,
                                    );
                                    if (exists) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Categoria "$name" já existe',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    await categoryRepo.create(
                                      cat.Category(
                                        name: name,
                                        normalized: normalized,
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Categoria "$name" criada',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                  onSelected: (value) {
                    _categoryCtrl.text = value;
                    _categoryFieldCtrl?.text = value;
                    _categoryFieldCtrl?.selection = TextSelection.collapsed(
                      offset: value.length,
                    );
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                // Chips das categorias existentes para seleção rápida
                categoriesAsync.when(
                  data: (cats) {
                    if (cats.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final usedNames = countersAsync.maybeWhen(
                      data: (ctrs) => ctrs
                          .map((c) => c.category?.trim())
                          .whereType<String>()
                          .map((name) => normalizeCategory(name))
                          .toSet(),
                      orElse: () => <String>{},
                    );
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: cats.map((c) {
                          final selected = _categoryCtrl.text.trim() == c.name;
                          final isUsed = usedNames.contains(c.normalized);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InputChip(
                              label: Text(c.name),
                              selected: selected,
                              onPressed: () {
                                _categoryCtrl.text = c.name;
                                _categoryFieldCtrl?.text = c.name;
                                _categoryFieldCtrl?.selection =
                                    TextSelection.collapsed(
                                      offset: c.name.length,
                                    );
                                setState(() {});
                              },
                              onDeleted: isUsed
                                  ? null
                                  : () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                            'Excluir categoria',
                                          ),
                                          content: Text(
                                            'Excluir "${c.name}"? Esta ação não pode ser desfeita.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Excluir'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) return;
                                      final ok = await categoryRepo
                                          .deleteIfUnused(c);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? 'Categoria "${c.name}" excluída'
                                                : 'Não é possível excluir: em uso',
                                          ),
                                        ),
                                      );
                                    },
                              deleteIcon: isUsed
                                  ? const Icon(Icons.block)
                                  : const Icon(Icons.delete),
                              tooltip: isUsed ? 'Em uso' : 'Excluir',
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 4),
                // Botão de criação rápida quando texto não pertence a nenhuma categoria
                Builder(
                  builder: (context) {
                    final input = _categoryCtrl.text.trim();
                    final exists = categoriesAsync.maybeWhen(
                      data: (cats) => cats.any(
                        (c) => c.name.toLowerCase() == input.toLowerCase(),
                      ),
                      orElse: () => false,
                    );
                    if (input.isNotEmpty && !exists) {
                      return TextButton.icon(
                        onPressed: () async {
                          final normalized = normalizeCategory(input);
                          final exists = categoriesAsync.maybeWhen(
                            data: (cats) =>
                                cats.any((c) => c.normalized == normalized),
                            orElse: () => false,
                          );
                          if (exists) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Categoria "$input" já existe'),
                              ),
                            );
                            return;
                          }
                          await categoryRepo.create(
                            cat.Category(name: input, normalized: normalized),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Categoria "$input" criada'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text('Criar "$input"'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null)
                        setState(
                          () => _date = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            _date.hour,
                            _date.minute,
                          ),
                        );
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      'Data: ${_date.day}/${_date.month}/${_date.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (picked != null) setState(() => _time = picked);
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text('Hora: ${_time.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Recorrência',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _recurrence,
                  items: Recurrence.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r.name,
                          child: Text(_labelForRecurrence(r)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _recurrence = v ?? Recurrence.none.name),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onSubmit,
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? 'Salvar' : 'Criar'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => context.go('/counters'),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
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
    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    if (widget.counterId == null) {
      final now = DateTime.now();
      final c = model.Counter(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        eventDate: dt,
        category: _categoryCtrl.text.trim().isEmpty
            ? null
            : _categoryCtrl.text.trim(),
        recurrence: _recurrence,
        createdAt: now,
        updatedAt: now,
      );
      await repo.create(c);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contador criado com sucesso')),
      );
      context.go('/counters');
    } else {
      final now = DateTime.now();
      final c = model.Counter(
        id: widget.counterId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        eventDate: dt,
        category: _categoryCtrl.text.trim().isEmpty
            ? null
            : _categoryCtrl.text.trim(),
        recurrence: _recurrence,
        createdAt: _createdAt ?? now,
        updatedAt: now,
      );
      final ok = await repo.update(c);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Contador atualizado' : 'Falha ao atualizar'),
        ),
      );
      context.go('/counters');
    }
  }
}
