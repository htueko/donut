import 'package:donut/features/auth/domain/registration_draft.dart';
import 'package:donut/features/auth/presentation/auth_flow_provider.dart';
import 'package:donut/features/auth/presentation/screens/phone_screen.dart';
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

  /// Back navigation re-mounts the phone step from the shared draft, so the
  /// field must be pre-filled from it rather than starting empty.
  testWidgets('phone step pre-fills from the registration draft', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...env.overrides(),
          registrationDraftProvider.overrideWith(
            (ref) => const RegistrationDraft(phoneE164: '9254135592'),
          ),
        ],
        child: const MaterialApp(home: PhoneScreen(isLogin: false)),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, '9254135592');
  });

  testWidgets('phone step starts empty for a fresh registration', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...env.overrides(),
          registrationDraftProvider.overrideWith(
            (ref) => const RegistrationDraft(),
          ),
        ],
        child: const MaterialApp(home: PhoneScreen(isLogin: false)),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isEmpty);
  });
}
