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

  // Derived from questions in the selected catalog
  List<String> _existingCategories = [];
  int _nextOrder = 1;

  String? _selectedCategory; // either a real category or _kNewCategory
  bool _loadingCatalogs = true;
  bool _loadingQuestions = false;
  bool _saving = false;
  String? _catalogError;

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
      _existingCategories = [];
      _selectedCategory = null;
      _nextOrder = 1;
    });
    try {
      final questions = await _dataSource.getQuestionsForCatalog(catalogId);
      if (!mounted) return;
      final categories = _extractCategories(questions);
      final maxOrder = questions.isEmpty
          ? 0
          : questions.map((q) => q.order).reduce((a, b) => a > b ? a : b);
      setState(() {
        _existingCategories = categories;
        _nextOrder = maxOrder + 1;
        _selectedCategory =
            categories.isNotEmpty ? categories.first : _kNewCategory;
        _loadingQuestions = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingQuestions = false;
          _nextOrder = 1;
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

  String get _resolvedCategory {
    if (_selectedCategory == _kNewCategory) {
      return _newCategoryCtrl.text.trim();
    }
    return _selectedCategory ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCatalogId == null) return;

    setState(() => _saving = true);
    try {
      await _dataSource.createQuestion(
        catalogId: _selectedCatalogId!,
        order: _nextOrder,
        category: _resolvedCategory,
        textDe: _textDeCtrl.text.trim(),
        textEn: _textEnCtrl.text.trim(),
        textHr: _textHrCtrl.text.trim(),
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.questionAdded)),
        );
        Navigator.pop(context);
      }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_selectedCatalogId),
                      initialValue: _selectedCatalogId,
                      decoration: InputDecoration(labelText: l10n.selectCatalog),
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
                      validator: (v) => v == null ? l10n.fieldRequired : null,
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
                              '$_nextOrder',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedCategory),
                initialValue: _selectedCategory,
                decoration: InputDecoration(labelText: l10n.categoryLabel),
                items: [
                  ..._existingCategories.map(
                    (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                  ),
                  DropdownMenuItem(
                    value: _kNewCategory,
                    child: Text(
                      l10n.newCategory,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? l10n.fieldRequired : null,
              ),
              if (_selectedCategory == _kNewCategory) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newCategoryCtrl,
                  decoration: InputDecoration(labelText: l10n.newCategoryLabel),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (_selectedCategory == _kNewCategory &&
                              (v == null || v.trim().isEmpty))
                          ? l10n.fieldRequired
                          : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _textDeCtrl,
                decoration: InputDecoration(labelText: l10n.questionTextDe),
                textInputAction: TextInputAction.next,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _textEnCtrl,
                      decoration:
                          InputDecoration(labelText: l10n.questionTextEn),
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _textHrCtrl,
                      decoration:
                          InputDecoration(labelText: l10n.questionTextHr),
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: (_saving || _loadingQuestions) ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
