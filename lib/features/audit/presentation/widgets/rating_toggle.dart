import 'package:flutter/material.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/audit_response.dart';

class RatingToggle extends StatelessWidget {
  final Rating? value;
  final ValueChanged<Rating?>? onChanged;

  const RatingToggle({
    this.value,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedButton<Rating>(
      segments: [
        ButtonSegment(
          value: Rating.yes,
          label: Text(l10n.yes),
          icon: const Icon(Icons.check, size: 18),
        ),
        ButtonSegment(
          value: Rating.no,
          label: Text(l10n.no),
          icon: const Icon(Icons.close, size: 18),
        ),
        ButtonSegment(
          value: Rating.na,
          label: Text(l10n.notApplicable),
          icon: const Icon(Icons.remove, size: 18),
        ),
      ],
      selected: value != null ? {value!} : {},
      onSelectionChanged: onChanged != null
          ? (selected) => onChanged!(selected.firstOrNull)
          : null,
      emptySelectionAllowed: true,
    );
  }
}
