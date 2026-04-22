import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/audit_response.dart';
import '../../domain/entities/question.dart';
import '../state/audit_detail_cubit.dart';
import 'attachment_section.dart';
import 'rating_toggle.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final AuditResponse? response;
  final String auditId;
  final bool isEditable;
  final bool canViewInternalHints;

  const QuestionCard({
    required this.question,
    required this.response,
    required this.auditId,
    required this.canViewInternalHints,
    this.isEditable = true,
    super.key,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late final TextEditingController _findingController;
  late final TextEditingController _measureController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _findingController = TextEditingController(
      text: widget.response?.finding ?? '',
    );
    _measureController = TextEditingController(
      text: widget.response?.measure ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response?.finding != widget.response?.finding) {
      _findingController.text = widget.response?.finding ?? '';
    }
    if (oldWidget.response?.measure != widget.response?.measure) {
      _measureController.text = widget.response?.measure ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _findingController.dispose();
    _measureController.dispose();
    super.dispose();
  }

  void _autoSave({Rating? rating, String? finding, String? measure}) {
    final current = widget.response ??
        AuditResponse(questionId: widget.question.id);

    final updated = current.copyWith(
      rating: rating ?? current.rating,
      finding: finding ?? current.finding,
      measure: measure ?? current.measure,
      updatedAt: DateTime.now(),
    );

    context.read<AuditDetailCubit>().saveResponse(widget.auditId, updated);
  }

  void _debouncedAutoSave({String? finding, String? measure}) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _autoSave(finding: finding, measure: measure);
    });
  }

  void _onRatingChanged(Rating? rating) {
    if (!widget.isEditable) return;

    String? measure;
    // If "no" is selected, pre-fill default measure if empty
    if (rating == Rating.no && (widget.response?.measure.isEmpty ?? true)) {
      final lang = Localizations.localeOf(context).languageCode;
      measure = widget.question.defaultMeasure(lang) ?? '';
      _measureController.text = measure;
    }

    _autoSave(rating: rating, measure: measure);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final internalHint = widget.question.internalNote(lang);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number & text
            Text(
              '${widget.question.order}. ${widget.question.text(lang)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            // Explanation text
            if (widget.question.explanationText(lang) != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.question.explanationText(lang)!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            if (widget.canViewInternalHints &&
                internalHint != null &&
                internalHint.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _InternalHintCard(hint: internalHint.trim(), label: l10n.internalAuditHint),
            ],

            const SizedBox(height: 12),

            // Rating toggle: Ja / Nein / Entfällt
            RatingToggle(
              value: widget.response?.rating,
              onChanged: widget.isEditable ? _onRatingChanged : null,
            ),

            const SizedBox(height: 12),

            // Feststellung (Finding) - free text, auto-expanding
            TextField(
              controller: _findingController,
              enabled: widget.isEditable,
              decoration: InputDecoration(
                labelText: l10n.finding,
                hintText: widget.question.defaultFinding(lang),
                alignLabelWithHint: true,
              ),
              maxLines: null, // Auto-expanding
              minLines: 2,
              onChanged: (value) => _debouncedAutoSave(finding: value),
            ),

            const SizedBox(height: 8),

            // Maßnahme (Measure) - free text, auto-expanding
            TextField(
              controller: _measureController,
              enabled: widget.isEditable,
              decoration: InputDecoration(
                labelText: l10n.measure,
                hintText: widget.question.defaultMeasure(lang),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              minLines: 2,
              onChanged: (value) => _debouncedAutoSave(measure: value),
            ),

            // Attachments (Anhänge)
            const SizedBox(height: 12),
            AttachmentSection(
              auditId: widget.auditId,
              questionId: widget.question.id,
              attachments: widget.response?.attachments ?? [],
              isEditable: widget.isEditable,
            ),

            // Nachrevision comparison info
            if (widget.response?.previousRating != null) ...[
              const SizedBox(height: 8),
              _PreviousRatingInfo(
                previousRating: widget.response!.previousRating!,
                previousFinding: widget.response!.previousFinding,
                comparisonResult: widget.response!.comparisonResult,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InternalHintCard extends StatelessWidget {
  final String hint;
  final String label;

  const _InternalHintCard({required this.hint, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviousRatingInfo extends StatelessWidget {
  final Rating previousRating;
  final String? previousFinding;
  final ComparisonResult? comparisonResult;

  const _PreviousRatingInfo({
    required this.previousRating,
    this.previousFinding,
    this.comparisonResult,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.previousAudit,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('${l10n.rating}: ${_ratingLabel(l10n, previousRating)}'),
          if (previousFinding != null && previousFinding!.isNotEmpty)
            Text('${l10n.finding}: $previousFinding'),
          if (comparisonResult != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  comparisonResult == ComparisonResult.improved
                      ? Icons.check_circle
                      : comparisonResult == ComparisonResult.worsened
                          ? Icons.cancel
                          : Icons.circle_outlined,
                  color: comparisonResult == ComparisonResult.improved
                      ? Colors.green
                      : comparisonResult == ComparisonResult.worsened
                          ? Colors.red
                          : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(_comparisonLabel(l10n, comparisonResult!)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _comparisonLabel(AppLocalizations l10n, ComparisonResult result) {
    switch (result) {
      case ComparisonResult.improved:
        return l10n.improved;
      case ComparisonResult.worsened:
        return l10n.worsened;
      case ComparisonResult.unchanged:
        return l10n.unchanged;
    }
  }

  String _ratingLabel(AppLocalizations l10n, Rating rating) {
    switch (rating) {
      case Rating.yes:
        return l10n.yes;
      case Rating.no:
        return l10n.no;
      case Rating.na:
        return l10n.notApplicable;
    }
  }
}
