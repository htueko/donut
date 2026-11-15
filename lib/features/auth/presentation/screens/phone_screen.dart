import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/phone_validator.dart';
import '../auth_flow_provider.dart';
import '../widgets/registration_progress_ring.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({required this.isLogin, super.key});

  final bool isLogin;

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _touched = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    if (!widget.isLogin) {
      final draft = ref.read(registrationDraftProvider);
      if (draft.phoneE164 != null) {
        _controller.text = draft.phoneE164!;
      }
    } else {
      final loginPhone = ref.read(loginPhoneProvider);
      if (loginPhone != null) {
        _controller.text = loginPhone;
      }
    }
  }

  void _onFocusChange() {
    if (!_focus.hasFocus && _controller.text.isNotEmpty) {
      setState(() => _touched = true);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => PhoneValidator.normalize(_controller.text) != null;
  bool get _showError => _touched && !_valid && _controller.text.isNotEmpty;

  Future<void> _submit() async {
    if (_submitting || !_valid) {
      return;
    }
    setState(() => _submitting = true);
    final normalized = PhoneValidator.normalize(_controller.text)!;
    if (widget.isLogin) {
      ref.read(loginPhoneProvider.notifier).state = normalized;
      if (mounted) {
        context.go('/login/otp');
      }
    } else {
      ref
          .read(registrationDraftProvider.notifier)
          .update((draft) => draft.copyWith(phoneE164: normalized));
      if (mounted) {
        context.go('/register/otp');
      }
    }
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final errorText = _showError
        ? (l10n?.phoneInvalid ?? 'Enter 9 followed by 7 to 9 digits after +95')
        : null;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!widget.isLogin)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg),
              child: RegistrationProgressRing(step: 1, total: 4),
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
                l10n?.phoneTitle ?? 'What is your phone number?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
                ],
                decoration: InputDecoration(
                  hintText: l10n?.phoneHint ?? 'Phone number',
                  prefixText: '+95 ',
                  errorText: errorText,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n?.continueLabel ?? 'Continue',
                onPressed: _submit,
                enabled: _valid,
                loading: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final loginPhoneProvider = StateProvider<String?>((ref) => null);
