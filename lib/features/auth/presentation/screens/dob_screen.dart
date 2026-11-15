import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
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
      initialDate: _lastDate,
      firstDate: _firstDate,
      lastDate: _lastDate,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (_submitting || _date == null) {
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
        context.go('/welcome');
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
    final error = _date == null
        ? null
        : DobValidator.validate(_date).messageKey;
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
                l10n?.dobTitle ?? 'When were you born?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: _date == null
                          ? AppColors.hairline
                          : AppColors.seed,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined, color: AppColors.latte),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _date == null
                              ? (l10n?.selectDate ?? 'Select date')
                              : DateFormat.yMMMd().format(_date!),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.latte),
                    ],
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _dobErrorMessage(error, l10n),
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n?.continueLabel ?? 'Continue',
                onPressed: _submit,
                enabled: _date != null,
                loading: _submitting,
              ),
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
