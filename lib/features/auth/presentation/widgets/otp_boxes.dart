import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';

class OtpBoxes extends StatelessWidget {
  const OtpBoxes({
    required this.controllers,
    required this.nodes,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> nodes;
  final bool enabled;
  final void Function(String value, int index) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < controllers.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == controllers.length - 1 ? 0 : AppSpacing.sm,
              ),
              child: OtpBox(
                controller: controllers[i],
                node: nodes[i],
                enabled: enabled,
                onChanged: (String value) => onChanged(value, i),
              ),
            ),
          ),
      ],
    );
  }
}

class OtpBox extends StatefulWidget {
  const OtpBox({
    required this.controller,
    required this.node,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode node;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.node.addListener(_onFocus);
  }

  void _onFocus() {
    if (mounted) {
      setState(() => _focused = widget.node.hasFocus);
    }
  }

  @override
  void dispose() {
    widget.node.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: AppSpacing.otpBoxHeight,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.node,
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: AppSpacing.otpFontSize,
          color: palette.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: palette.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(
              color: _focused ? palette.primary : palette.border,
              width: _focused
                  ? AppSpacing.focusWidth
                  : AppSpacing.hairlineWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(color: palette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(
              color: palette.primary,
              width: AppSpacing.focusWidth,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(color: palette.border),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
