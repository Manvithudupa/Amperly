import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/features/consumer/presentation/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('back with report details asks before discarding them', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/report'),
              child: const Text('Open report'),
            ),
          ),
        ),
        GoRoute(
          path: '/report',
          builder: (BuildContext context, GoRouterState state) =>
              const ReportScreen(
                stationId: 'station-1',
                stationName: 'Nitte Community Charger',
              ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AmpTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('Open report'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'The cable was damaged.',
    );
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.unsavedChangesTitle), findsOneWidget);
    expect(find.text(AmpStrings.unsavedChangesBody), findsOneWidget);

    await tester.tap(find.text(AmpStrings.unsavedKeepEditing));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.reportTitle), findsOneWidget);
    expect(find.text('The cable was damaged.'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text(AmpStrings.unsavedDiscard));
    await tester.pumpAndSettle();

    expect(find.text('Open report'), findsOneWidget);
    expect(find.text(AmpStrings.reportTitle), findsNothing);
  });
}
