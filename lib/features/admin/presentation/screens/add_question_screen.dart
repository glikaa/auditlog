import 'package:flutter/material.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../audit/domain/entities/audit_catalog.dart';
import '../../../audit/domain/entities/question.dart';
import '../../data/admin_remote_data_source.dart';

/// Sentinel value used in the category dropdown to represent "create new".
const _kNewCategory = '__new__';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newCategoryCtrl = TextEditingController();
  final _textDeCtrl = TextEditingController();
  final _textEnCtrl = TextEditingController();
  final _textHrCtrl = TextEditingController();

  final _dataSource = AdminRemoteDataSource();

  List<AuditCatalog> _catalogs = [];
  String? _selectedCatalogId;

  /// All questions for the selected catalog, kept sorted by [Question.order].
  List<Question> _questions = [];

  /// Unique ordered category names derived from [_questions].
  List<String> _existingCategories = [];

  String? _selectedCategory; // either a real category or _kNewCategory
  bool _loadingCatalogs = true;
  bool _loadingQuestions = false;
  bool _saving = false;
  bool _reordering = false;
  String? _catalogError;

  // ── Computed properties ──────────────────────────────────────────────────

  String get _resolvedCategory {
    if (_selectedCategory == _kNewCategory) {
      return _newCategoryCtrl.text.trim();
    }
    return _selectedCategory ?? '';
  }

  /// Returns the 0-based index in [_questions] where the new question will be
  /// inserted: right after the last existing question in the same category, or
  /// at the end of the list when the category is new.
  int get _insertIndex {
    final category = _resolvedCategory;
    if (category.isEmpty) return _questions.length;
    int lastIdx = -1;
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i].category == category) lastIdx = i;
    }
    return lastIdx >= 0 ? lastIdx + 1 : _questions.length;
  }

  /// 1-based display position for the new question.
  int get _previewOrder => _insertIndex + 1;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  @override
  void dispose() {
    _newCategoryCtrl.dispose();
    _textDeCtrl.dispose();
    _textEnCtrl.dispose();
    _textHrCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  Future<void> _loadCatalogs() async {
    try {
      final catalogs = await _dataSource.getCatalogs();
      if (mounted) {
        setState(() {
          _catalogs = catalogs;
          _loadingCatalogs = false;
        });
        if (catalogs.isNotEmpty) {
          await _onCatalogSelected(catalogs.first.id);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingCatalogs = false;
          _catalogError = 'Kataloge konnten nicht geladen werden.';
        });
      }
    }
  }

  Future<void> _onCatalogSelected(String catalogId) async {
    setState(() {
      _selectedCatalogId = catalogId;
      _loadingQuestions = true;
      _questions = [];
      _existingCategories = [];
      _selectedCategory = null;
    });
    try {
      final questions = await _dataSource.getQuestionsForCatalog(catalogId);
      if (!mounted) return;
      final sorted = List<Question>.from(questions)
        ..sort((a, b) => a.order.compareTo(b.order));
      final categories = _extractCategories(sorted);
      setState(() {
        _questions = sorted;
        _existingCategories = categories;
        _selectedCategory =
            categories.isNotEmpty ? categories.first : _kNewCategory;
        _loadingQuestions = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingQuestions = false;
        });
      }
    }
  }

  List<String> _extractCategories(List<Question> questions) {
    final seen = <String>{};
    final result = <String>[];
    for (final q in questions) {
      if (seen.add(q.category)) result.add(q.category);
    }
    return result;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCatalogId == null) return;

    final insertIdx = _insertIndex;
    final newOrder = insertIdx + 1;
    final category = _resolvedCategory;

    setState(() => _saving = true);
    try {
      // 1. Persist the new question at its computed position.
      final created = await _dataSource.createQuestion(
        catalogId: _selectedCatalogId!,
        order: newOrder,
        category: category,
        textDe: _textDeCtrl.text.trim(),
        textEn: _textEnCtrl.text.trim(),
        textHr: _textHrCtrl.text.trim(),
      );

      // 2. Insert locally and re-number all questions sequentially.
      final updated = List<Question>.from(_questions)
        ..insert(insertIdx, created);
      final renumbered = [
        for (int i = 0; i < updated.length; i++)
          _withOrder(updated[i], i + 1),
      ];

      // 3. Build the shifted list (all questions except the newly created one
      //    whose orders changed due to insertion).
      final shifted = <({String id, int order})>[];
      for (int i = 0; i < renumbered.length; i++) {
        final q = renumbered[i];
        if (q.id != created.id && q.order != _questions[i < insertIdx ? i : i - 1].order) {
          shifted.add((id: q.id, order: q.order));
        }
      }

      if (shifted.isNotEmpty) {
        await _dataSource.reorderQuestions(_selectedCatalogId!, shifted);
      }

      if (!mounted) return;

      // 4. Refresh categories in case a new one was added.
      final categories = _extractCategories(renumbered);
      setState(() {
        _questions = renumbered;
        _existingCategories = categories;
        // Keep the category selected so the user can add more in the same spot.
        if (_selectedCategory == _kNewCategory && categories.contains(category)) {
          _selectedCategory = category;
        }
        // Clear text fields ready for next question.
        _textDeCtrl.clear();
        _textEnCtrl.clear();
        _textHrCtrl.clear();
        _newCategoryCtrl.clear();
      });

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.questionAdded)),
      );
    } on ServerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUnknown),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Drag-and-drop reorder ─────────────────────────────────────────────────

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    // ReorderableListView passes newIndex after removal, adjust downward.
    if (newIndex > oldIndex) newIndex--;
    final updated = List<Question>.from(_questions);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);

    final renumbered = [
      for (int i = 0; i < updated.length; i++) _withOrder(updated[i], i + 1),
    ];

    setState(() {
      _questions = renumbered;
      _existingCategories = _extractCategories(renumbered);
      _reordering = true;
    });

    try {
      await _dataSource.reorderQuestions(
        _selectedCatalogId!,
        renumbered.map((q) => (id: q.id, order: q.order)).toList(),
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.reorderSaved)));
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reorderError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reordering = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns a copy of [q] with a new [order] value.
  Question _withOrder(Question q, int order) {
    return Question(
      id: q.id,
      catalogId: q.catalogId,
      masterQuestionId: q.masterQuestionId,
      order: order,
      category: q.category,
      categoryEn: q.categoryEn,
      categoryHr: q.categoryHr,
      textDe: q.textDe,
      textEn: q.textEn,
      textHr: q.textHr,
      explanationTextDe: q.explanationTextDe,
      explanationTextEn: q.explanationTextEn,
      explanationTextHr: q.explanationTextHr,
      internalNoteDe: q.internalNoteDe,
      internalNoteEn: q.internalNoteEn,
      internalNoteHr: q.internalNoteHr,
      defaultFindingDe: q.defaultFindingDe,
      defaultFindingEn: q.defaultFindingEn,
      defaultFindingHr: q.defaultFindingHr,
      defaultMeasureDe: q.defaultMeasureDe,
      defaultMeasureEn: q.defaultMeasureEn,
      defaultMeasureHr: q.defaultMeasureHr,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loadingCatalogs) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addQuestion)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_catalogError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addQuestion)),
        body: Center(child: Text(_catalogError!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addQuestion)),
      body: Column(
        children: [
          // ── Form (fixed height, scrollable) ─────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Catalog + preview position row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_selectedCatalogId),
                          initialValue: _selectedCatalogId,
                          decoration:
                              InputDecoration(labelText: l10n.selectCatalog),
                          items: _catalogs
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.displayLabel),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) _onCatalogSelected(v);
                          },
                          validator: (v) =>
                              v == null ? l10n.fieldRequired : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _loadingQuestions
                            ? const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: LinearProgressIndicator(),
                              )
                            : InputDecorator(
                                decoration: InputDecoration(
                                  labelText: l10n.orderLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                child: Text(
                                  '$_previewOrder',
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedCategory),
                    initialValue: _selectedCategory,
                    decoration:
                        InputDecoration(labelText: l10n.categoryLabel),
                    items: [
                      ..._existingCategories.map(
                        (cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)),
                      ),
                      DropdownMenuItem(
                        value: _kNewCategory,
                        child: Text(
                          l10n.newCategory,
                          style:
                              const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator: (v) =>
                        v == null ? l10n.fieldRequired : null,
                  ),
                  if (_selectedCategory == _kNewCategory) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newCategoryCtrl,
                      decoration:
                          InputDecoration(labelText: l10n.newCategoryLabel),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}), // refresh preview
                      validator: (v) =>
                          (_selectedCategory == _kNewCategory &&
                                  (v == null || v.trim().isEmpty))
                              ? l10n.fieldRequired
                              : null,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Question texts
                  TextFormField(
                    controller: _textDeCtrl,
                    decoration:
                        InputDecoration(labelText: l10n.questionTextDe),
                    textInputAction: TextInputAction.next,
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _textEnCtrl,
                          decoration: InputDecoration(
                              labelText: l10n.questionTextEn),
                          textInputAction: TextInputAction.next,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _textHrCtrl,
                          decoration: InputDecoration(
                              labelText: l10n.questionTextHr),
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  FilledButton(
                    onPressed:
                        (_saving || _loadingQuestions) ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Question list ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Row(
              children: [
                Text(
                  l10n.questionListTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_reordering) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loadingQuestions
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                    ? Center(
                        child: Text(
                          'Noch keine Fragen.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        onReorder: _onReorder,
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final q = _questions[index];
                          return _QuestionTile(
                            key: ValueKey(q.id),
                            question: q,
                            index: index,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Question list tile ────────────────────────────────────────────────────────

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    super.key,
    required this.question,
    required this.index,
  });

  final Question question;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            '${question.order}',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          question.textDe ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          question.category,
          style: TextStyle(
            color: colorScheme.secondary,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
        trailing: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
      ),
    );
  }
}
