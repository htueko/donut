import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
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
                l10n?.nameTitle ?? 'What should we call you?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _firstController,
                focusNode: _firstFocus,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n?.firstNameLabel ?? 'First name',
                  errorText: firstError == null
                      ? null
                      : _messageFor(firstError, l10n),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _lastFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _lastController,
                focusNode: _lastFocus,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n?.lastNameLabel ?? 'Last name',
                  errorText: lastError == null
                      ? null
                      : _messageFor(lastError, l10n),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n?.continueLabel ?? 'Continue',
                onPressed: _submit,
                enabled: firstResult.isValid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
