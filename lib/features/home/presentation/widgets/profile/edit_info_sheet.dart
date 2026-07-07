import 'package:flutter/material.dart';

class EditFieldConfig {
  final String label;
  final String? hint;
  final String initialValue;
  final bool isPassword;
  final TextInputType keyboardType;

  const EditFieldConfig({
    required this.label,
    this.hint,
    this.initialValue = '',
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });
}

class EditInfoSheet extends StatefulWidget {
  final String title;
  final List<EditFieldConfig> fields;
  final void Function(List<String> values) onSave;

  const EditInfoSheet({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        required List<EditFieldConfig> fields,
        required void Function(List<String> values) onSave,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => EditInfoSheet(title: title, fields: fields, onSave: onSave),
    );
  }

  @override
  State<EditInfoSheet> createState() => _EditInfoSheetState();
}

class _EditInfoSheetState extends State<EditInfoSheet> {
  late final List<TextEditingController> _controllers;
  late final List<bool> _obscured;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields
        .map((f) => TextEditingController(text: f.initialValue))
        .toList();
    _obscured = widget.fields.map((f) => f.isPassword).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      widget.onSave(_controllers.map((c) => c.text.trim()).toList());
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validator(int index, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Campo requerido';

    final field = widget.fields[index];

    if (field.keyboardType == TextInputType.emailAddress) {
      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
        return 'Correo no válido';
      }
    }

    if (field.isPassword && trimmed.length < 6) {
      return 'Mínimo 6 caracteres';
    }

    if (index > 0 &&
        widget.fields[index - 1].isPassword &&
        field.isPassword) {
      if (trimmed != _controllers[index - 1].text.trim()) {
        return 'Las contraseñas no coinciden';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // Fields
              ...List.generate(widget.fields.length, (i) {
                final field = widget.fields[i];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < widget.fields.length - 1 ? 16 : 0,
                  ),
                  child: _SheetField(
                    label: field.label,
                    hint: field.hint,
                    controller: _controllers[i],
                    isPassword: field.isPassword,
                    isObscured: _obscured[i],
                    keyboardType: field.keyboardType,
                    onToggleObscure: field.isPassword
                        ? () =>
                        setState(() => _obscured[i] = !_obscured[i])
                        : null,
                    validator: (v) => _validator(i, v),
                  ),
                );
              }),
              const SizedBox(height: 28),

              // Guardar button
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF04364A),
                    disabledBackgroundColor:
                    const Color(0xFF04364A).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'Guardar',
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool isObscured;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  const _SheetField({
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.isObscured = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
      const BorderSide(color: Color(0xFF04364A), width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: TextInputAction.next,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.55),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            suffixIcon: isPassword && onToggleObscure != null
                ? IconButton(
              icon: Icon(
                isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: onToggleObscure,
            )
                : null,
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: colorScheme.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}