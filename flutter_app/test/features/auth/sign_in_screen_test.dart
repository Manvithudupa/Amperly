import 'package:amperly/app/app.dart';
import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/env/app_env.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/features/auth/presentation/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const AppEnv _configured = AppEnv(
  supabaseUrl: 'https://example.supabase.co',
  supabasePublishableKey: 'sb_publishable_test_value',
  geoapifyApiKey: '',
  mapStyleUrl: '',
);

void main() {
  testWidgets('switches from sign-in to account creation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appEnvProvider.overrideWithValue(_configured)],
        child: MaterialApp(theme: AmpTheme.light(), home: const SignInScreen()),
      ),
    );

    expect(find.text(AmpStrings.authTitle), findsOneWidget);
    expect(find.text(AmpStrings.authName), findsNothing);
    expect(find.text(AmpStrings.authSignIn), findsWidgets);

    await tester.tap(find.text(AmpStrings.authCreatePrompt));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.authCreateTitle), findsOneWidget);
    expect(find.text(AmpStrings.authName), findsOneWidget);
    expect(find.text(AmpStrings.authCreateAccount), findsWidgets);
  });

  testWidgets('does not offer a form without backend settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              supabaseUrl: '',
              supabasePublishableKey: '',
              geoapifyApiKey: '',
              mapStyleUrl: '',
            ),
          ),
        ],
        child: MaterialApp(theme: AmpTheme.light(), home: const SignInScreen()),
      ),
    );

    expect(find.text(AmpStrings.configNotConfigured), findsOneWidget);
    expect(find.text(AmpStrings.authSignIn), findsNothing);
    expect(find.text(AmpStrings.authTitle), findsOneWidget);
  });
}
