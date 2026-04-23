import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../audit/domain/entities/audit_catalog.dart';
import '../../data/admin_remote_data_source.dart';

/// Sentinel value used in the country dropdown to represent "create new country".
const _kNewCountry = '__new__';

class CreateCatalogScreen extends StatefulWidget {
  const CreateCatalogScreen({super.key});

  @override
  State<CreateCatalogScreen> createState() => _CreateCatalogScreenState();
}

class _CreateCatalogScreenState extends State<CreateCatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newCountryCtrl = TextEditingController();
  final _versionCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(
    text: DateTime.now().year.toString(),
  );

  final _dataSource = AdminRemoteDataSource();

  String _selectedLanguage = 'de';

  /// The selected item in the country dropdown: an existing country code,
  /// [_kNewCountry], or null when nothing is chosen yet.
  String? _selectedCountryOption;

  /// The catalog id chosen as the base for cloning.
  String? _selectedBaseId;

  bool _saving = false;
  bool _loadingCatalogs = true;
  List<AuditCatalog> _catalogs = [];

  static const _languages = ['de', 'en', 'hr'];

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Unique country codes present in [_catalogs], sorted A-Z.
  List<String> get _existingCountries {
    final seen = <String>{};
    final result = <String>[];
    for (final c in _catalogs) {
      if (seen.add(c.countryCode)) result.add(c.countryCode);
    }
    result.sort();
    return result;
  }

  /// All catalogs that belong to the currently selected country, newest first.
  List<AuditCatalog> get _catalogsForCountry {
    if (_selectedCountryOption == null ||
        _selectedCountryOption == _kNewCountry) {
      return [];
    }
    return _catalogs
        .where((c) => c.countryCode == _selectedCountryOption)
        .toList()
      ..sort((a, b) => b.year.compareTo(a.year));
  }

  /// True when we are creating a brand-new country (no existing catalogs for it).
  bool get _isNewCountry =>
      _existingCountries.isEmpty || _selectedCountryOption == _kNewCountry;

  String get _resolvedCountryCode => _isNewCountry
      ? _newCountryCtrl.text.trim().toUpperCase()
      : (_selectedCountryOption ?? '');

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  @override
  void dispose() {
    _newCountryCtrl.dispose();
    _versionCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadCatalogs() async {
    try {
      final catalogs = await _dataSource.getCatalogs();
      if (mounted) {
        setState(() {
          _catalogs = catalogs
            ..sort((a, b) {
              final cc = a.countryCode.compareTo(b.countryCode);
              return cc != 0 ? cc : b.year.compareTo(a.year);
            });
          // Auto-enter new-country mode when no catalogs exist yet (first run).
          if (_catalogs.isEmpty && _selectedCountryOption == null) {
            _selectedCountryOption = _kNewCountry;
          }
          _loadingCatalogs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_selectedCountryOption == null) {
            _selectedCountryOption = _kNewCountry;
          }
          _loadingCatalogs = false;
        });
      }
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Capture before any async gap.
    final isNew = _isNewCountry;
    final countryCode = _resolvedCountryCode;

    setState(() => _saving = true);
    try {
      if (isNew) {
        await _dataSource.createCatalog(
          countryCode: countryCode,
          version: _versionCtrl.text.trim(),
          year: int.parse(_yearCtrl.text.trim()),
          language: _selectedLanguage,
        );
      } else {
        await _dataSource.cloneCatalog(
          sourceCatalogId: _selectedBaseId!,
          version: _versionCtrl.text.trim(),
          year: int.parse(_yearCtrl.text.trim()),
          language: _selectedLanguage,
        );
      }

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogCreated)),
      );

      // Reset version/year; reload list.
      _versionCtrl.clear();
      _yearCtrl.text = DateTime.now().year.toString();
      await _loadCatalogs();

      // After creating a brand-new country, switch it to the existing-country
      // picker so the user can immediately add another version on top.
      if (mounted && isNew && _existingCountries.contains(countryCode)) {
        setState(() {
          _selectedCountryOption = countryCode;
          _newCountryCtrl.clear();
          _selectedBaseId = null;
        });
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final countries = _existingCountries;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createCatalog)),
      body: Column(
        children: [
          // ── Form ────────────────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Country selector ────────────────────────────────────
                  if (_loadingCatalogs)
                    const LinearProgressIndicator()
                  else if (countries.isEmpty)
                    // No existing catalogs: plain text field.
                    TextFormField(
                      controller: _newCountryCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.catalogCountryCode,
                        hintText: 'DE',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                        LengthLimitingTextInputFormatter(3),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.fieldRequired
                          : null,
                    )
                  else
                    // Existing catalogs: dropdown with existing countries +
                    // "New Country..." sentinel.
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedCountryOption),
                      value: _selectedCountryOption,
                      decoration:
                          InputDecoration(labelText: l10n.catalogCountryCode),
                      items: [
                        ...countries.map(
                          (cc) => DropdownMenuItem(value: cc, child: Text(cc)),
                        ),
                        DropdownMenuItem(
                          value: _kNewCountry,
                          child: Text(
                            l10n.catalogNewCountry,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _selectedCountryOption = v;
                        _selectedBaseId = null;
                      }),
                      validator: (v) =>
                          v == null ? l10n.fieldRequired : null,
                    ),

                  // ── New country code field (shown below dropdown) ────────
                  if (!_loadingCatalogs &&
                      countries.isNotEmpty &&
                      _selectedCountryOption == _kNewCountry) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newCountryCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.catalogCountryCode,
                        hintText: 'AT',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                        LengthLimitingTextInputFormatter(3),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (_selectedCountryOption == _kNewCountry &&
                                  (v == null || v.trim().isEmpty))
                              ? l10n.fieldRequired
                              : null,
                    ),
                  ],

                  // ── Base version picker (existing country only) ──────────
                  if (!_loadingCatalogs && !_isNewCountry) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('base_$_selectedCountryOption'),
                      value: _selectedBaseId,
                      decoration: InputDecoration(
                        labelText: l10n.catalogBaseVersion,
                      ),
                      items: _catalogsForCountry
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                '${c.version} (${c.year})'
                                ' · ${c.questionCount} Q',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBaseId = v),
                      validator: (v) =>
                          (!_isNewCountry && v == null)
                              ? l10n.fieldRequired
                              : null,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Version + Year ───────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _versionCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.catalogVersion,
                            hintText: 'v2',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _yearCtrl,
                          decoration:
                              InputDecoration(labelText: l10n.catalogYear),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.fieldRequired;
                            }
                            final y = int.tryParse(v.trim());
                            if (y == null || y < 2000 || y > 2100) {
                              return l10n.catalogYearInvalid;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Default language ─────────────────────────────────────
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration:
                        InputDecoration(labelText: l10n.catalogLanguage),
                    items: _languages
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedLanguage = v);
                    },
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: (_saving || _loadingCatalogs) ? null : _submit,
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

          // ── Existing catalog list ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.catalogListTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loadingCatalogs
                ? const Center(child: CircularProgressIndicator())
                : _catalogs.isEmpty
                    ? Center(
                        child: Text(
                          'No catalogs yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _catalogs.length,
                        itemBuilder: (context, index) {
                          final cat = _catalogs[index];
                          return _CatalogTile(catalog: cat);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Catalog list tile ─────────────────────────────────────────────────────────

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.catalog});

  final AuditCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Text(
            catalog.countryCode,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('${catalog.countryCode} – ${catalog.version}'),
        subtitle: Text('${catalog.year}'),
        trailing: Chip(
          label: Text('${catalog.questionCount}'),
          avatar: const Icon(Icons.quiz_outlined, size: 14),
          visualDensity: VisualDensity.compact,
          side: BorderSide.none,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}
