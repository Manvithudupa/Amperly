import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_bottom_bar.dart';
import 'package:amperly/core/widgets/amp_icon.dart';
import 'package:amperly/core/widgets/amp_scaffold.dart';
import 'package:amperly/core/widgets/battery_ring.dart';
import 'package:amperly/core/widgets/fuel_gauge.dart';
import 'package:amperly/core/widgets/port_dots.dart';
import 'package:amperly/core/widgets/receipt_row.dart';
import 'package:amperly/core/widgets/status_dot_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chart, port and status components expose labels and tooltips', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    const int percent = 38;
    const int estimate = 52;
    const int reserve = 15;
    final String gauge = AmpStrings.fuelGaugeSemantics(
      percent,
      reserve,
      estimate,
    );
    final String ports = AmpStrings.portsFree(2, 4);
    const String status = 'Available, 3 min ago';
    final String ring =
        '${AmpStrings.batteryRingSemantics} '
        '${AmpStrings.batteryEstimateSemantics(percent, estimate)}';

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FuelGauge(percent: percent, estimatePercent: estimate),
                SizedBox(height: 20),
                PortDots(available: 2, total: 4),
                SizedBox(height: 20),
                StatusDotLabel('Available', detail: '3 min ago'),
                SizedBox(height: 20),
                BatteryRing(
                  percent: percent,
                  estimatePercent: estimate,
                  caption: 'Battery',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(gauge), findsOneWidget);
    expect(find.bySemanticsLabel(ports), findsOneWidget);
    expect(find.bySemanticsLabel(status), findsOneWidget);
    expect(find.bySemanticsLabel(ring), findsOneWidget);
    for (final String message in <String>[gauge, ports, status, ring]) {
      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Tooltip && widget.message == message,
        ),
        findsOneWidget,
        reason: 'missing tooltip for $message',
      );
    }
    handle.dispose();
  });

  for (final double scale in <double>[1.3, 2]) {
    testWidgets('receipt rows stack at $scale instead of overflowing', (
      WidgetTester tester,
    ) async {
      await _pumpScaled(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: ReceiptRow(label: 'Verified energy', value: '34.6 kWh'),
          ),
        ),
        scale: scale,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Verified energy'), findsOneWidget);
      expect(find.text('34.6 kWh'), findsOneWidget);
    });
  }

  testWidgets('scaffold title area grows for a subtitle at 2.0', (
    WidgetTester tester,
  ) async {
    await _pumpScaled(
      tester,
      const AmpScaffold(
        title: 'A long charger name that needs room',
        subtitle: 'A long supporting line that also needs room',
        body: SizedBox.shrink(),
      ),
    );

    expect(tester.takeException(), isNull);
    final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
    expect(bar.toolbarHeight, greaterThan(78));
  });

  testWidgets('bottom bar clamps text and stops motion when disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        builder: (BuildContext context, Widget? app) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: true,
              textScaler: const TextScaler.linear(2),
            ),
            child: app!,
          );
        },
        home: Scaffold(
          bottomNavigationBar: AmpBottomBar(
            destinations: const <AmpBottomDestination>[
              AmpBottomDestination(
                label: 'Discover',
                icon: AmpIconName.compass,
              ),
              AmpBottomDestination(label: 'Trips', icon: AmpIconName.route),
            ],
            currentIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    final BuildContext labelContext = tester.element(find.text('Discover'));
    expect(MediaQuery.textScalerOf(labelContext).scale(10), closeTo(13, 0.001));
    for (final AnimatedContainer item in tester.widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byType(AmpBottomBar),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is AnimatedContainer && widget.constraints?.maxHeight == 2,
        ),
      ),
    )) {
      expect(item.duration, Duration.zero);
    }
    for (final AnimatedDefaultTextStyle item
        in tester.widgetList<AnimatedDefaultTextStyle>(
          find.descendant(
            of: find.byType(AmpBottomBar),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is AnimatedDefaultTextStyle &&
                  widget.style.fontSize == 11.5,
            ),
          ),
        )) {
      expect(item.duration, Duration.zero);
    }
  });
}

Future<void> _pumpScaled(WidgetTester tester, Widget home, {double scale = 2}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AmpTheme.light(),
      builder: (BuildContext context, Widget? app) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: app!,
        );
      },
      home: home,
    ),
  );
}
