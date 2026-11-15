import 'package:donut/features/auth/domain/registration_draft.dart';
import 'package:donut/features/auth/presentation/auth_flow_provider.dart';
import 'package:donut/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth.dart';

void main() {
  late FakeAuthEnv env;

  setUp(() {
    env = FakeAuthEnv();
  });

  tearDown(() async {
    await env.dispose();
  });

  Future<void> pumpOtp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...env.overrides(),
          registrationDraftProvider.overrideWith(
            (ref) => const RegistrationDraft(phoneE164: '9254135592'),
          ),
        ],
        child: const MaterialApp(home: OtpScreen(isLogin: false)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> typeCode(WidgetTester tester, String code) async {
    for (var i = 0; i < code.length; i++) {
      await tester.enterText(find.byType(TextField).at(i), code[i]);
      await tester.pump();
    }
  }

  testWidgets('wrong codes shake, clear and lock after three tries', (tester) async {
    await pumpOtp(tester);

    await typeCode(tester, '111111');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('That code'), findsOneWidget);
    expect(find.text('111111'), findsNothing);

    await typeCode(tester, '222222');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('That code'), findsOneWidget);

    await typeCode(tester, '333333');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap Resend'), findsOneWidget);

    await typeCode(tester, '444444');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap Resend'), findsOneWidget);
  });

  testWidgets('resend counts down and unlocks entry', (tester) async {
    await pumpOtp(tester);

    expect(find.textContaining('Resend in 05:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.textContaining('Resend in 04:57'), findsOneWidget);

    await tester.pump(const Duration(seconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Resend'), findsOneWidget);
  });
}

class RegistrationDraftState extends RegistrationDraft {
  const RegistrationDraftState({super.phoneE164});
}
