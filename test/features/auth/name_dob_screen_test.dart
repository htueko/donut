import 'package:donut/core/widgets/primary_button.dart';
import 'package:donut/features/auth/domain/name_validator.dart';
import 'package:donut/features/auth/domain/registration_draft.dart';
import 'package:donut/features/auth/presentation/auth_flow_provider.dart';
import 'package:donut/features/auth/presentation/screens/dob_screen.dart';
import 'package:donut/features/auth/presentation/screens/name_screen.dart';
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

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...env.overrides(),
          registrationDraftProvider.overrideWith(
            (ref) => const RegistrationDraft(phoneE164: '9254135592'),
          ),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool continueEnabled(WidgetTester tester) {
    return tester
        .widget<PrimaryButton>(find.byType(PrimaryButton))
        .enabled;
  }

  testWidgets('name step rejects empty input and digits', (tester) async {
    await pump(tester, const NameScreen());

    expect(continueEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField).first, 'Su2');
    await tester.pump();
    expect(continueEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField).first, 'Su Su');
    await tester.pump();
    expect(continueEnabled(tester), isTrue);

    // The Continue button stays disabled for invalid names, so the form can
    // never be submitted with bad data.
    expect(continueEnabled(tester), isTrue);
  });

  testWidgets('myanmar script names validate', (tester) async {
    expect(NameValidator.validate('စုစု', required: true).isValid, isTrue);
  });

  testWidgets('date of birth blocks continue until a date is picked', (
    tester,
  ) async {
    await pump(tester, const DobScreen());

    expect(continueEnabled(tester), isFalse);

    await tester.tap(find.text('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(continueEnabled(tester), isTrue);
  });
}
