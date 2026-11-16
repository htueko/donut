import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/result.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dob_validator.dart';
import '../auth_flow_provider.dart';
import '../widgets/registration_progress_ring.dart';

class DobScreen extends ConsumerStatefulWidget {
  const DobScreen({super.key});

  @override
  ConsumerState<DobScreen> createState() => _DobScreenState();
}

class _DobScreenState extends ConsumerState<DobScreen> {
  DateTime? _date;
  bool _submitting = false;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _firstDate => DateTime(_today.year - 120);

  DateTime get _lastDate =>
      DateTime(_today.year - DobValidator.minimumAge, _today.month, _today.day);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? _lastDate,
      firstDate: _firstDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (_submitting || _date == null) {
      return;
    }
    final errorKey = DobValidator.validate(_date).messageKey;
    if (errorKey != null) {
      return;
    }
    setState(() => _submitting = true);
    ref
        .read(registrationDraftProvider.notifier)
        .update((draft) => draft.copyWith(dateOfBirth: _date));
    final draft = ref.read(registrationDraftProvider);
    final otp = draft.otp;
    if (otp == null) {
      context.go('/register/otp');
      return;
    }
    final result = await ref.read(authFlowProvider).register(draft, otp);
    if (!mounted) {
      return;
    }
    result.when(
      onSuccess: (_) {
        ref.invalidate(registrationDraftProvider);
        context.push('/welcome');
      },
      onFailure: (failure) {
        setState(() => _submitting = false);
        final message = failure is ValidationFailure
            ? (failure.message ?? 'Something went wrong')
            : 'Something went wrong';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final error = _date == null ? null : DobValidator.validate(_date).messageKey;
    final monthStr = _date != null ? DateFormat('MMMM').format(_date!) : '';
    final dayStr = _date != null ? _date!.day.toString() : '';
    final yearStr = _date != null ? _date!.year.toString() : '';

    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: RegistrationProgressRing(step: 4, total: 4),
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
                'What\'s your date of birth?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: AppTypography.h2Weight,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                onTap: _pickDate,
                child: Column(
                  children: [
                    _DobCardField(
                      label: 'Month',
                      hintText: 'Select date',
                      valueText: monthStr,
                      isFilled: monthStr.isNotEmpty,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DobCardField(
                      label: 'Day',
                      hintText: 'Day',
                      valueText: dayStr,
                      isFilled: dayStr.isNotEmpty,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DobCardField(
                      label: 'Year',
                      hintText: 'Year',
                      valueText: yearStr,
                      isFilled: yearStr.isNotEmpty,
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _dobErrorMessage(error, l10n),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: palette.danger),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: l10n?.continueLabel ?? 'Continue',
                onPressed: _submit,
                enabled: _date != null && error == null,
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

  String _dobErrorMessage(String key, AppLocalizations? l10n) {
    return switch (key) {
      'dobInvalid' => l10n?.dobInvalid ?? 'Enter a real date',
      'dobFuture' => l10n?.dobFuture ?? 'Date can\'t be in the future',
      'dobTooYoung' =>
        l10n?.dobTooYoung('13') ?? 'You must be at least 13 years old',
      _ => '',
    };
  }
}

class _DobCardField extends StatelessWidget {
  const _DobCardField({
    required this.label,
    required this.hintText,
    required this.valueText,
    required this.isFilled,
  });

  final String label;
  final String hintText;
  final String valueText;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isFilled ? palette.primary : palette.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Text(
        isFilled ? valueText : hintText,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isFilled ? palette.textPrimary : palette.textMuted,
              fontWeight: isFilled ? AppTypography.subtitleWeight : AppTypography.bodyWeight,
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
