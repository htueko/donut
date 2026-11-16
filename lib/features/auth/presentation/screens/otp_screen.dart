import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/result.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/app_user.dart';
import '../../domain/otp_validator.dart';
import '../auth_flow_provider.dart';
import '../widgets/otp_boxes.dart';
import '../widgets/registration_progress_ring.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.isLogin, super.key});

  final bool isLogin;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxAttempts = 3;
  static const int _resendSeconds = 300;

  final _controllers = List.generate(
    OtpValidator.length,
    (_) => TextEditingController(),
  );
  final _nodes = List.generate(OtpValidator.length, (_) => FocusNode());
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: AppMotion.base,
  );
  Timer? _countdown;
  int _secondsLeft = _resendSeconds;
  int _wrongAttempts = 0;
  bool _locked = false;
  bool _submitting = false;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
    _startCountdown();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _shake.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdown?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _codeComplete => OtpValidator.isComplete(_code);

  void _onChanged(String value, int index) {
    if (_errorKey != null) {
      setState(() => _errorKey = null);
    }
    if (value.length > 1) {
      _fillFromPaste(value);
      return;
    }
    if (value.isNotEmpty && index < _nodes.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _fillFromPaste(String value) {
    final digits = value.replaceAll(RegExp('[^0-9]'), '');
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    _nodes[_controllers.length - 1].requestFocus();
    setState(() {});
  }

  /// Backspace on an empty box moves focus back. EditableText consumes the key
  /// before it reaches any ancestor, so listen on the hardware keyboard.
  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return false;
    }
    for (var i = 0; i < _nodes.length; i++) {
      if (_nodes[i].hasFocus && _controllers[i].text.isEmpty && i > 0) {
        _nodes[i - 1].requestFocus();
        return true;
      }
    }
    return false;
  }

  Future<void> _submit() async {
    if (_submitting || _locked || !_codeComplete) {
      return;
    }
    setState(() => _submitting = true);
    Result<AppUser> result;
    if (widget.isLogin) {
      final phone = ref.read(loginPhoneProvider);
      if (phone == null) {
        context.go('/login/phone');
        return;
      }
      result = await ref
          .read(authFlowProvider)
          .login(phoneE164: phone, otp: _code);
    } else {
      final draft = ref.read(registrationDraftProvider);
      if (draft.phoneE164 == null) {
        context.go('/register/phone');
        return;
      }
      final verify = await ref.read(authFlowProvider).verifyOtp(_code);
      if (!mounted) {
        return;
      }
      verify.when(
        onSuccess: (_) {
          ref
              .read(registrationDraftProvider.notifier)
              .update((draft) => draft.copyWith(otp: _code));
          setState(() => _submitting = false);
          context.push('/register/name');
        },
        onFailure: (failure) => _onFailure(failure),
      );
      return;
    }
    if (!mounted) {
      return;
    }
    result.when(
      onSuccess: (user) => _onSuccess(user),
      onFailure: (failure) => _onFailure(failure),
    );
  }

  void _onSuccess(AppUser user) {
    context.go('/home');
  }

  void _onFailure(Failure failure) {
    setState(() {
      _submitting = false;
      if (failure is ValidationFailure) {
        _wrongAttempts++;
        if (_wrongAttempts >= _maxAttempts) {
          _locked = true;
          _errorKey = 'otpLocked';
        } else {
          _errorKey = 'otpInvalid';
        }
      } else if (failure is NotFoundFailure) {
        _errorKey = 'phone_not_registered';
      } else {
        _errorKey = 'otpInvalid';
      }
    });
    for (final controller in _controllers) {
      controller.clear();
    }
    _nodes.first.requestFocus();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  void _resend() {
    _wrongAttempts = 0;
    _locked = false;
    _errorKey = null;
    _startCountdown();
    for (final controller in _controllers) {
      controller.clear();
    }
    _nodes.first.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = widget.isLogin
        ? ref.watch(loginPhoneProvider)
        : ref.watch(registrationDraftProvider).phoneE164;
    final errorText = _errorKey == null
        ? null
        : (_errorKey == 'otpLocked'
              ? (l10n?.otpLocked ?? 'Too many wrong tries. Tap Resend.')
              : _errorKey == 'phone_not_registered'
              ? (l10n?.phoneNotRegistered ?? 'Phone number not registered')
              : (l10n?.otpInvalid ?? 'That code doesn\'t look right.'));
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!widget.isLogin)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg),
              child: RegistrationProgressRing(step: 2, total: 4),
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
                l10n?.verifyTitle ?? 'Verify your number',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: AppTypography.h2Weight),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We\'ve sent 6 digit OTP to +95${phone ?? ''}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.palette.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  final offset = MediaQuery.disableAnimationsOf(context)
                      ? Offset.zero
                      : Offset(
                          math.sin(_shake.value * math.pi * 4) *
                              8 *
                              (1 - _shake.value),
                          0,
                        );
                  return Transform.translate(offset: offset, child: child);
                },
                child: OtpBoxes(
                  controllers: _controllers,
                  nodes: _nodes,
                  enabled: !_locked,
                  onChanged: _onChanged,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 20,
                child: errorText == null
                    ? null
                    : Text(
                        errorText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: context.palette.danger),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        l10n?.resendIn(_formatClock()) ??
                            'Resend in ${_formatClock()}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: context.palette.textSecondary),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: Text(l10n?.resend ?? 'Resend'),
                      ),
              ),
              if (_errorKey == 'phone_not_registered') ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(loginPhoneProvider.notifier).state = null;
                      context.go('/register/phone');
                    },
                    child: Text(l10n?.register ?? 'Register'),
                  ),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: l10n?.continueLabel ?? 'Continue',
                onPressed: _codeComplete && !_locked && !_submitting
                    ? _submit
                    : null,
                enabled: _codeComplete && !_locked,
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

  String _formatClock() {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
