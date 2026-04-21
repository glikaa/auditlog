import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/audit_response.dart';
import '../state/audit_detail_cubit.dart';

/// Displays existing attachments and provides upload/delete functionality.
class AttachmentSection extends StatelessWidget {
  final String auditId;
  final String questionId;
  final List<Attachment> attachments;
  final bool isEditable;

  const AttachmentSection({
    required this.auditId,
    required this.questionId,
    required this.attachments,
    this.isEditable = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '${l10n.attachments} (${attachments.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (isEditable)
              _UploadButton(auditId: auditId, questionId: questionId),
          ],
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attachments.map((a) {
              return _AttachmentChip(
                attachment: a,
                auditId: auditId,
                questionId: questionId,
                isEditable: isEditable,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  final String auditId;
  final String questionId;

  const _UploadButton({required this.auditId, required this.questionId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
      tooltip: 'Anhang hinzufuegen',
      onSelected: (value) async {
        if (value == 'camera') {
          await _pickImage(context, ImageSource.camera);
        } else if (value == 'gallery') {
          await _pickImage(context, ImageSource.gallery);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'gallery',
          child: ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Galerie'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'camera',
          child: ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Kamera'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    if (!context.mounted) return;

    final success = await context.read<AuditDetailCubit>().uploadAttachment(
          auditId: auditId,
          questionId: questionId,
          fileBytes: bytes,
          fileName: xFile.name,
        );
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Anhang "${xFile.name}" hochgeladen'
              : 'Fehler beim Hochladen von "${xFile.name}"',
        ),
        backgroundColor: success ? null : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final Attachment attachment;
  final String auditId;
  final String questionId;
  final bool isEditable;

  const _AttachmentChip({
    required this.attachment,
    required this.auditId,
    required this.questionId,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImage = attachment.type == 'image';

    return Chip(
      avatar: Icon(
        isImage ? Icons.image : Icons.picture_as_pdf,
        size: 18,
        color: isImage ? Colors.blue : Colors.red,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            attachment.id.substring(0, 8),
            style: theme.textTheme.bodySmall,
          ),
          if (attachment.isReportRelevant) ...[
            const SizedBox(width: 4),
            Icon(Icons.visibility, size: 14, color: theme.colorScheme.primary),
          ],
        ],
      ),
      deleteIcon: isEditable ? const Icon(Icons.close, size: 16) : null,
      onDeleted: isEditable
          ? () {
              context.read<AuditDetailCubit>().deleteAttachment(
                    auditId: auditId,
                    questionId: questionId,
                    attachmentId: attachment.id,
                  );
            }
          : null,
      visualDensity: VisualDensity.compact,
    );
  }
}
