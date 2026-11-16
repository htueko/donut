import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
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
        await context.push('/login/otp');
      }
    } else {
      ref
          .read(registrationDraftProvider.notifier)
          .update((draft) => draft.copyWith(phoneE164: normalized));
      if (mounted) {
        await context.push('/register/otp');
      }
    }
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
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
                'Enter your phone number',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: AppTypography.h2Weight,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: errorText != null
                        ? palette.danger
                        : (_focus.hasFocus ? palette.primary : palette.border),
                    width: _focus.hasFocus ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Text(
                      '+95',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: palette.textSecondary,
                            fontWeight: AppTypography.subtitleWeight,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9\- ]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          filled: false,
                          hintText: '09254135592',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                  ],
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  errorText,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: palette.danger),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: l10n?.continueLabel ?? 'Continue',
                onPressed: _submit,
                enabled: _valid,
                loading: _submitting,
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

class _DisclaimerFooter extends StatelessWidget {
  const _DisclaimerFooter({required this.onTerms, required this.onPrivacy});

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.textMuted,
              fontSize: 11,
            ),
        children: [
          const TextSpan(
            text:
                'By continuing, you acknowledge that you have read and agree to our ',
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

final loginPhoneProvider = StateProvider<String?>((ref) => null);
