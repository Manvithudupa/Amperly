import 'package:amperly/app/theme/amp_colors.dart';
import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/widgets/amp_bottom_bar.dart';
import 'package:amperly/core/widgets/amp_icon.dart';
import 'package:amperly/core/widgets/departure_row.dart';
import 'package:amperly/core/widgets/fuel_gauge.dart';
import 'package:amperly/core/widgets/milestone_line.dart';
import 'package:amperly/core/widgets/receipt_rows.dart';
import 'package:amperly/core/widgets/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _goldenRoot = Key('golden-root');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final FontLoader display = FontLoader('Fraunces')
      ..addFont(rootBundle.load('assets/fonts/fraunces.ttf'));
    await display.load();

    final FontLoader ui = FontLoader('PlusJakartaSans')
      ..addFont(rootBundle.load('assets/fonts/pjs_regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/pjs_medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/pjs_bold.ttf'));
    await ui.load();
  });

  for (final (String mode, ThemeData theme) in <(String, ThemeData)>[
    ('light', AmpTheme.light()),
    ('dark', AmpTheme.dark()),
  ]) {
    group('$mode paper components', () {
      testWidgets('departure row', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'departure_row',
          mode: mode,
          theme: theme,
          height: 124,
          child: DepartureRow(
            title: 'Padubidri Service Road Charger',
            metric: '60',
            metricUnit: 'kW',
            detail: 'CCS2 · 2 connectors',
            availablePorts: 2,
            totalPorts: 4,
            statusLabel: 'Available',
            statusDetail: '3 min ago',
            price: '₹20',
            onTap: () {},
          ),
        );
      });

      testWidgets('ticket card', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'ticket_card',
          mode: mode,
          theme: theme,
          height: 260,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TicketCard(
              notchOffset: 0.58,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'BOOKED',
                    style: TextStyle(
                      fontFamily: AmpTheme.uiFont,
                      fontSize: 11,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: theme.extension<AmpColors>()!.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hampankatta Charger Hub',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CCS2 · Port 2 · Today, 6:30 pm – 8:00 pm',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'AMP-D6NAUU',
                          style: const TextStyle(
                            fontFamily: AmpTheme.displayFont,
                            fontSize: 27,
                            height: 1.08,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.8,
                            fontFeatures: <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      AmpIcon(
                        AmpIconName.qr,
                        size: 48,
                        color: theme.extension<AmpColors>()!.ink,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });

      testWidgets('fuel gauge', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'fuel_gauge',
          mode: mode,
          theme: theme,
          height: 128,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FuelGauge(percent: 38, estimatePercent: 52),
          ),
        );
      });

      testWidgets('milestone line', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'milestone_line',
          mode: mode,
          theme: theme,
          height: 300,
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: MilestoneLine(
              stops: <MilestoneStop>[
                MilestoneStop(
                  distanceKm: 0,
                  title: 'Mangaluru',
                  detail: 'Start · 38%',
                  batteryPercent: 38,
                ),
                MilestoneStop(
                  distanceKm: 28.4,
                  title: 'Padubidri Service Road Charger',
                  detail: 'Arrive 24% · charge to 80%',
                  batteryPercent: 24,
                ),
                MilestoneStop(
                  distanceKm: 54.1,
                  title: 'Udupi City Charger',
                  detail: 'Backup stop',
                  batteryPercent: 16,
                  backup: true,
                ),
              ],
            ),
          ),
        );
      });

      testWidgets('receipt rows', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'receipt_rows',
          mode: mode,
          theme: theme,
          height: 296,
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: ReceiptRows(
              lines: <ReceiptLine>[
                ReceiptLine(label: 'Start reading', value: '1204 kWh'),
                ReceiptLine(label: 'End reading', value: '1238.6 kWh'),
                ReceiptLine(label: 'Verified energy', value: '34.6 kWh'),
                ReceiptLine(label: 'Energy', value: '₹622.80'),
                ReceiptLine(label: 'Service fee', value: '₹5'),
                ReceiptLine(label: 'Gateway fee', value: '₹4'),
                ReceiptLine(label: 'Total', value: '₹631.80', emphasis: true),
              ],
            ),
          ),
        );
      });

      testWidgets('bottom bar', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'bottom_bar',
          mode: mode,
          theme: theme,
          height: 88,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AmpBottomBar(
              destinations: const <AmpBottomDestination>[
                AmpBottomDestination(
                  label: 'Discover',
                  icon: AmpIconName.compass,
                ),
                AmpBottomDestination(label: 'Trips', icon: AmpIconName.route),
                AmpBottomDestination(
                  label: 'Bookings',
                  icon: AmpIconName.ticket,
                ),
                AmpBottomDestination(label: 'Messages', icon: AmpIconName.chat),
                AmpBottomDestination(label: 'Profile', icon: AmpIconName.user),
              ],
              currentIndex: 0,
              onSelected: (_) {},
            ),
          ),
        );
      });
    });
  }

  for (final (String mode, ThemeData theme) in <(String, ThemeData)>[
    ('light', AmpTheme.light()),
    ('dark', AmpTheme.dark()),
  ]) {
    group('$mode paper components at 2.0 text scale', () {
      testWidgets('departure row', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'departure_row_2x',
          mode: mode,
          theme: theme,
          height: 400,
          textScale: 2,
          child: DepartureRow(
            title: 'Padubidri Service Road Charger',
            metric: '60',
            metricUnit: 'kW',
            detail: 'CCS2 · 2 connectors',
            availablePorts: 2,
            totalPorts: 4,
            statusLabel: 'Available',
            statusDetail: '3 min ago',
            price: '₹20',
            onTap: () {},
          ),
        );
      });

      testWidgets('ticket card', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'ticket_card_2x',
          mode: mode,
          theme: theme,
          height: 440,
          textScale: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TicketCard(
              notchOffset: 0.58,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'BOOKED',
                    style: TextStyle(
                      fontFamily: AmpTheme.uiFont,
                      fontSize: 11,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: theme.extension<AmpColors>()!.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hampankatta Charger Hub',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CCS2 · Port 2 · Today, 6:30 pm – 8:00 pm',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'AMP-D6NAUU',
                          style: const TextStyle(
                            fontFamily: AmpTheme.displayFont,
                            fontSize: 27,
                            height: 1.08,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.8,
                            fontFeatures: <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      AmpIcon(
                        AmpIconName.qr,
                        size: 48,
                        color: theme.extension<AmpColors>()!.ink,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });

      testWidgets('fuel gauge', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'fuel_gauge_2x',
          mode: mode,
          theme: theme,
          height: 190,
          textScale: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FuelGauge(percent: 38, estimatePercent: 52),
          ),
        );
      });

      testWidgets('bottom bar', (WidgetTester tester) async {
        await _expectGolden(
          tester,
          name: 'bottom_bar_2x',
          mode: mode,
          theme: theme,
          height: 88,
          textScale: 2,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AmpBottomBar(
              destinations: const <AmpBottomDestination>[
                AmpBottomDestination(
                  label: 'Discover',
                  icon: AmpIconName.compass,
                ),
                AmpBottomDestination(label: 'Trips', icon: AmpIconName.route),
                AmpBottomDestination(
                  label: 'Bookings',
                  icon: AmpIconName.ticket,
                ),
                AmpBottomDestination(label: 'Messages', icon: AmpIconName.chat),
                AmpBottomDestination(label: 'Profile', icon: AmpIconName.user),
              ],
              currentIndex: 0,
              onSelected: (_) {},
            ),
          ),
        );
      });
    });
  }
}

Future<void> _expectGolden(
  WidgetTester tester, {
  required String name,
  required String mode,
  required ThemeData theme,
  required double height,
  required Widget child,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(420, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final AmpColors colors = theme.extension<AmpColors>()!;
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      builder: (BuildContext context, Widget? app) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(textScale),
          ),
          child: app!,
        );
      },
      home: Scaffold(
        key: _goldenRoot,
        backgroundColor: colors.background,
        body: child,
      ),
    ),
  );
  await tester.pumpAndSettle();

  await expectLater(
    find.byKey(_goldenRoot),
    matchesGoldenFile('goldens/$mode/$name.png'),
  );
}
