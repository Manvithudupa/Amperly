import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/network/connectivity.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the global banner appears while the probe is offline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onlineStatusProvider.overrideWith(_OfflineStatus.new)],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const GlobalOfflineBanner(
            child: Scaffold(body: Text('Catalogue')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.offlineBannerText), findsOneWidget);
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text(AmpStrings.retry), findsOneWidget);
  });

  testWidgets('the banner stays out of the way when online', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onlineStatusProvider.overrideWith(_OnlineStatus.new)],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const GlobalOfflineBanner(
            child: Scaffold(body: Text('Catalogue')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.offlineBannerText), findsNothing);
    expect(find.text('Catalogue'), findsOneWidget);
  });
}

class _OfflineStatus extends OnlineStatusNotifier {
  @override
  bool build() => false;
}

class _OnlineStatus extends OnlineStatusNotifier {
  @override
  bool build() => true;
}
