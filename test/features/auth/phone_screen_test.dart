import 'package:donut/features/auth/domain/registration_draft.dart';
import 'package:donut/features/auth/presentation/auth_flow_provider.dart';
import 'package:donut/features/auth/presentation/screens/phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPhone(
    WidgetTester tester, {
    bool isLogin = false,
    String? draftPhone,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          registrationDraftProvider.overrideWith(
            (ref) => RegistrationDraft(phoneE164: draftPhone),
          ),
        ],
        child: MaterialApp(home: PhoneScreen(isLogin: isLogin)),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool continueEnabled(WidgetTester tester) {
    return tester.widget<FilledButton>(find.byType(FilledButton)).enabled ==
        true;
  }

  testWidgets('continue stays disabled until the number is valid', (
    tester,
  ) async {
    await pumpPhone(tester);
    expect(continueEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField), '095');
    await tester.pump();
    expect(continueEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField), '095241');
    await tester.pump();
    expect(continueEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField), '09254135592');
    await tester.pump();
    expect(continueEnabled(tester), isTrue);
  });

  testWidgets('shows the inline error after the field loses focus', (
    tester,
  ) async {
    await pumpPhone(tester);

    await tester.enterText(find.byType(TextField), '0123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.textContaining('9 followed by'), findsOneWidget);
  });

  testWidgets('accepts spaces and dashes', (tester) async {
    await pumpPhone(tester);

    await tester.enterText(find.byType(TextField), '09 254-135592');
    await tester.pump();

    expect(continueEnabled(tester), isTrue);
  });
}
