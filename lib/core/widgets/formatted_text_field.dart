import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

// ---------------------------------------------------------------------------
// Helper functions: QuillController ↔ String
// ---------------------------------------------------------------------------

/// Creates a [QuillController] from a stored string.
/// Tries Delta JSON first (new format), falls back to plain text (legacy).
QuillController quillControllerFromText(String text) {
  if (text.isEmpty) return QuillController.basic();

  try {
    final json = jsonDecode(text);
    if (json is List) {
      return QuillController(
        document: Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  } catch (_) {
    // Not JSON – treat as legacy plain text
  }

  final doc = Document()..insert(0, text);
  return QuillController(
    document: doc,
    selection: const TextSelection.collapsed(offset: 0),
  );
}

/// Serialises a [QuillController]'s content as Delta-JSON string for storage.
String quillToJson(QuillController controller) {
  return jsonEncode(controller.document.toDelta().toJson());
}

/// Extracts plain text from a [QuillController] (trimmed).
String quillToPlainText(QuillController controller) {
  return controller.document.toPlainText().trimRight();
}

/// Replaces the entire document content with plain [text].
void setQuillPlainText(QuillController controller, String text) {
  final length = controller.document.length;
  controller.replaceText(0, length - 1, text, null);
}

/// Checks whether a stored string (Delta JSON or plain) is effectively empty.
bool isQuillContentEmpty(String text) {
  if (text.isEmpty) return true;
  try {
    final json = jsonDecode(text);
    if (json is List) {
      return Document.fromJson(json).toPlainText().trim().isEmpty;
    }
  } catch (_) {}
  return text.trim().isEmpty;
}

// ---------------------------------------------------------------------------
// FormattedTextField widget – powered by flutter_quill
// ---------------------------------------------------------------------------

/// A rich text editor with formatting toolbar (Bold, Italic, Underline, etc.)
/// built on [flutter_quill]. Works on Flutter Web, Desktop, and Mobile.
///
/// Pass a [QuillController] (use [quillControllerFromText] to create one).
/// The [onChanged] callback provides a Delta-JSON string for persistence.
class FormattedTextField extends StatefulWidget {
  final QuillController controller;
  final bool enabled;
  final InputDecoration? decoration;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;

  const FormattedTextField({
    required this.controller,
    this.enabled = true,
    this.decoration,
    this.maxLines,
    this.minLines,
    this.onChanged,
    super.key,
  });

  @override
  State<FormattedTextField> createState() => _FormattedTextFieldState();
}

class _FormattedTextFieldState extends State<FormattedTextField> {
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    widget.controller.readOnly = !widget.enabled;
    widget.controller.addListener(_onDocumentChanged);
  }

  @override
  void didUpdateWidget(covariant FormattedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.readOnly = !widget.enabled;
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onDocumentChanged);
      widget.controller.addListener(_onDocumentChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onDocumentChanged);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDocumentChanged() {
    widget.onChanged?.call(quillToJson(widget.controller));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final labelText = widget.decoration?.labelText;
    final hintText = widget.decoration?.hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              labelText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

        // Toolbar – only shown when editable
        if (widget.enabled)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: QuillSimpleToolbar(
              controller: widget.controller,
              config: const QuillSimpleToolbarConfig(
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showListNumbers: true,
                showListBullets: true,
                showLink: true,
                showUndo: true,
                showRedo: true,
                showClearFormat: true,
                showAlignmentButtons: false,
                showHeaderStyle: false,
                showCodeBlock: false,
                showQuote: false,
                showIndent: false,
                showSuperscript: false,
                showSubscript: false,
                showSmallButton: false,
                showSearchButton: false,
                showFontFamily: false,
                showFontSize: false,
                showInlineCode: false,
                showDividers: true,
              ),
            ),
          ),

        // Editor
        Container(
          constraints: BoxConstraints(
            minHeight: ((widget.minLines ?? 2) * 24.0) + 16,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: QuillEditor(
            controller: widget.controller,
            focusNode: _focusNode,
            scrollController: _scrollController,
            config: QuillEditorConfig(
              placeholder: hintText ?? '',
              padding: const EdgeInsets.all(8),
              autoFocus: false,
            ),
          ),
        ),
      ],
    );
  }
}
