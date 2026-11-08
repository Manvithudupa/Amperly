import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/auth/application/profile_providers.dart';
import 'package:amperly/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a blocked profile sees the restriction screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<AppUser>(
              AppUser(
                id: 'account',
                name: 'Blocked account',
                email: 'blocked@example.com',
                isBlocked: true,
              ),
            ),
          ),
        ],
        child: MaterialApp(theme: AmpTheme.light(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.blockedTitle), findsWidgets);
    expect(find.text(AmpStrings.blockedBody), findsOneWidget);
    expect(find.text(AmpStrings.blockedSignOut), findsOneWidget);
    expect(find.text(AmpStrings.discoverTitle), findsNothing);
  });
}
