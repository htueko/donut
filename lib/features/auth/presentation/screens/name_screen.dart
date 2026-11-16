import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/validation/validation_result.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/name_validator.dart';
import '../auth_flow_provider.dart';
import '../widgets/registration_progress_ring.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _firstFocus = FocusNode();
  final _lastFocus = FocusNode();
  bool _firstTouched = false;
  bool _lastTouched = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(registrationDraftProvider);
    _firstController.text = draft.firstName ?? '';
    _lastController.text = draft.lastName ?? '';
    _firstFocus.addListener(_onFirstFocus);
    _lastFocus.addListener(_onLastFocus);
  }

  void _onFirstFocus() {
    if (!_firstFocus.hasFocus && _firstController.text.isNotEmpty) {
      setState(() => _firstTouched = true);
    }
  }

  void _onLastFocus() {
    if (!_lastFocus.hasFocus && _lastController.text.isNotEmpty) {
      setState(() => _lastTouched = true);
    }
  }

  @override
  void dispose() {
    _firstFocus.removeListener(_onFirstFocus);
    _lastFocus.removeListener(_onLastFocus);
    _firstFocus.dispose();
    _lastFocus.dispose();
    _firstController.dispose();
    _lastController.dispose();
    super.dispose();
  }

  String? _errorFor(ValidationResult result) {
    if (result.isValid) {
      return null;
    }
    return result.messageKey;
  }

  String _messageFor(String? key, AppLocalizations? l10n) {
    return switch (key) {
      'nameRequired' => l10n?.nameRequired ?? 'First name is required',
      'nameTooLong' => l10n?.nameTooLong ?? 'Use 50 characters or fewer',
      'nameInvalidChars' =>
        l10n?.nameInvalidChars ?? 'Letters and spaces only, no digits',
      _ => '',
    };
  }

  void _saveDraft() {
    ref
        .read(registrationDraftProvider.notifier)
        .update(
          (draft) => draft.copyWith(
            firstName: _firstController.text.trim(),
            lastName: _lastController.text.trim(),
          ),
        );
  }

  void _submit() {
    if (!NameValidator.validate(
      _firstController.text,
      required: true,
    ).isValid) {
      setState(() => _firstTouched = true);
      return;
    }
    _saveDraft();
    context.push('/register/dob');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstResult = NameValidator.validate(
      _firstController.text,
      required: true,
    );
    final lastResult = NameValidator.validate(
      _lastController.text,
      required: false,
    );
    final firstError = _firstTouched ? _errorFor(firstResult) : null;
    final lastError = _lastTouched ? _errorFor(lastResult) : null;
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: RegistrationProgressRing(step: 3, total: 4),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'What\'s your name?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: AppTypography.h2Weight),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _NameCardInput(
                controller: _firstController,
                focusNode: _firstFocus,
                hintText: l10n?.firstNameLabel ?? 'First Name',
                errorText: firstError == null
                    ? null
                    : _messageFor(firstError, l10n),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _lastFocus.requestFocus(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              _NameCardInput(
                controller: _lastController,
                focusNode: _lastFocus,
                hintText: l10n?.lastNameLabel ?? 'Last Name',
                errorText: lastError == null
                    ? null
                    : _messageFor(lastError, l10n),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(),
              PrimaryButton(
                label: l10n?.continueLabel ?? 'Continue',
                onPressed: _submit,
                enabled: firstResult.isValid,
              ),
              const SizedBox(height: AppSpacing.lg),
              _DisclaimerFooter(
                onTerms: () => context.push('/legal/terms'),
                onPrivacy: () => context.push('/legal/privacy'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameCardInput extends StatelessWidget {
  const _NameCardInput({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.textInputAction,
    required this.onSubmitted,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final String? errorText;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: errorText != null
                  ? palette.danger
                  : (focusNode.hasFocus ? palette.primary : palette.border),
              width: focusNode.hasFocus ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: false,
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: palette.textMuted),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: palette.danger),
          ),
        ],
      ],
    );
  }
}

class _DisclaimerFooter extends StatelessWidget {
  const _DisclaimerFooter({required this.onTerms, required this.onPrivacy});

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: palette.textMuted, fontSize: 11),
        children: [
          const TextSpan(
            text: 'By continuing, you acknowledge that you have read and agree to our ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onTerms,
              child: Text(
                'Terms of Use',
                style: TextStyle(
                  color: palette.primary,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onPrivacy,
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: palette.primary,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
