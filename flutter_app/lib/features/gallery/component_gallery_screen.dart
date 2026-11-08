import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../../core/formatting/amp_format.dart';
import '../../core/ui/connector_kind.dart';
import '../../core/ui/strings.dart';
import '../../core/widgets/amp_badge.dart';
import '../../core/widgets/amp_button.dart';
import '../../core/widgets/amp_chip.dart';
import '../../core/widgets/amp_field.dart';
import '../../core/widgets/amp_icon.dart';
import '../../core/widgets/amp_scaffold.dart';
import '../../core/widgets/amp_sheet.dart';
import '../../core/widgets/amp_snackbar.dart';
import '../../core/widgets/battery_ring.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/connector_glyph.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/freshness_label.dart';
import '../../core/widgets/offline_banner.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/receipt_row.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/ticket_card.dart';
import '../../core/widgets/timeline_node.dart';

final ThemeData _galleryLight = AmpTheme.light();
final ThemeData _galleryDark = AmpTheme.dark();

enum _GalleryPreviewMode { both, light, dark }

/// Debug-only catalogue of every shared component, always in both themes.
///
/// This screen is not in a release build. It exists so a design change can be
/// reviewed once, across light and dark, instead of being discovered screen by
/// screen after it has already drifted.
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key});

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  _GalleryPreviewMode _mode = _GalleryPreviewMode.both;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final DateTime now = DateTime(2026, 11, 7, 12);

    return AmpScaffold(
      title: AmpStrings.galleryTitle,
      showBack: false,
      actions: <Widget>[
        IconButton(
          tooltip: AmpStrings.close,
          onPressed: () => context.go('/sign-in'),
          icon: AmpIcon(AmpIconName.close, color: c.ink, size: 22),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceS,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        children: <Widget>[
          Text(
            AmpStrings.galleryIntro,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: c.inkSecondary),
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.gallerySampleNotice,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          Wrap(
            spacing: AmpTheme.spaceS,
            runSpacing: AmpTheme.spaceS,
            children: <Widget>[
              AmpChip(
                label: AmpStrings.galleryPreviewBoth,
                selected: _mode == _GalleryPreviewMode.both,
                onTap: () => _setMode(_GalleryPreviewMode.both),
              ),
              AmpChip(
                label: AmpStrings.galleryPreviewLight,
                selected: _mode == _GalleryPreviewMode.light,
                onTap: () => _setMode(_GalleryPreviewMode.light),
              ),
              AmpChip(
                label: AmpStrings.galleryPreviewDark,
                selected: _mode == _GalleryPreviewMode.dark,
                onTap: () => _setMode(_GalleryPreviewMode.dark),
              ),
            ],
          ),
          const SizedBox(height: AmpTheme.spaceXl),
          _section(
            AmpStrings.galleryButtons,
            (BuildContext context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  child: AmpButton(
                    label: AmpStrings.galleryButtonPrimary,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: AmpTheme.spaceS),
                SizedBox(
                  width: 220,
                  child: AmpButton(
                    label: AmpStrings.galleryButtonTonal,
                    variant: AmpButtonVariant.tonal,
                    icon: AmpIconName.battery,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: AmpTheme.spaceS),
                AmpButton(
                  label: AmpStrings.galleryButtonQuiet,
                  variant: AmpButtonVariant.quiet,
                  onPressed: () {},
                  expand: false,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                SizedBox(
                  width: 220,
                  child: AmpButton(
                    label: AmpStrings.galleryButtonDanger,
                    variant: AmpButtonVariant.danger,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: AmpTheme.spaceS),
                const SizedBox(
                  width: 220,
                  child: AmpButton(
                    label: AmpStrings.galleryButtonLoading,
                    loading: true,
                    onPressed: _noop,
                  ),
                ),
                const SizedBox(height: AmpTheme.spaceS),
                const SizedBox(
                  width: 220,
                  child: AmpButton(
                    label: AmpStrings.galleryButtonDisabled,
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryBadges,
            (BuildContext context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AmpTheme.spaceS,
                  runSpacing: AmpTheme.spaceS,
                  children: const <Widget>[
                    AmpBadge(
                      AmpStrings.meterMetered,
                      tone: AmpBadgeTone.success,
                    ),
                    AmpBadge(AmpStrings.meterDiscoveryOnly),
                    AmpBadge(AmpStrings.pending, tone: AmpBadgeTone.warning),
                    AmpBadge(
                      AmpStrings.verified,
                      tone: AmpBadgeTone.success,
                      icon: AmpIconName.check,
                    ),
                    AmpBadge(AmpStrings.demoMeter, tone: AmpBadgeTone.info),
                  ],
                ),
                const SizedBox(height: AmpTheme.spaceM),
                Wrap(
                  spacing: AmpTheme.spaceS,
                  runSpacing: AmpTheme.spaceS,
                  children: <Widget>[
                    const AmpChip(
                      label: AmpStrings.galleryChipAll,
                      selected: true,
                    ),
                    const AmpChip(
                      label: AmpStrings.galleryChipAvailable,
                      icon: AmpIconName.bolt,
                    ),
                    const AmpChip(label: AmpStrings.galleryChipFast),
                    AmpChip(
                      label: AmpFormat.connectorLabel('CCS2'),
                      leading: const ConnectorGlyph(
                        ConnectorKind.ccs2,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryFields,
            (BuildContext context) => Column(
              children: <Widget>[
                const AmpField(
                  label: AmpStrings.galleryFieldEmail,
                  hint: AmpStrings.galleryFieldEmailHint,
                  prefixIcon: AmpIconName.search,
                ),
                const SizedBox(height: AmpTheme.spaceM),
                const AmpField(
                  label: AmpStrings.galleryFieldPassword,
                  hint: AmpStrings.galleryFieldPasswordHint,
                  obscure: true,
                  initialValue: 'charger123',
                ),
                const SizedBox(height: AmpTheme.spaceM),
                const AmpField(
                  label: AmpStrings.galleryFieldEmail,
                  initialValue: 'not-an-email',
                  errorText: AmpStrings.galleryFieldError,
                  helper: AmpStrings.galleryFieldHelper,
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryBattery,
            (BuildContext context) => Wrap(
              spacing: AmpTheme.spaceM,
              runSpacing: AmpTheme.spaceM,
              children: const <Widget>[
                BatteryRing(
                  percent: 52,
                  estimatePercent: 61,
                  caption: AmpStrings.galleryBatteryCaption,
                ),
                BatteryRing(
                  percent: 12,
                  caption: AmpStrings.galleryBatteryLowCaption,
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryConnectors,
            (BuildContext context) => Wrap(
              spacing: AmpTheme.spaceM,
              runSpacing: AmpTheme.spaceM,
              children: <Widget>[
                _ConnectorSample(
                  kind: ConnectorKind.ccs2,
                  label: AmpFormat.connectorLabel('CCS2'),
                ),
                _ConnectorSample(
                  kind: ConnectorKind.type2,
                  label: AmpFormat.connectorLabel('TYPE_2_AC'),
                ),
                _ConnectorSample(
                  kind: ConnectorKind.chademo,
                  label: AmpFormat.connectorLabel('CHADEMO'),
                ),
                _ConnectorSample(
                  kind: ConnectorKind.plug,
                  label: AmpFormat.connectorLabel('PLUG'),
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryPrice,
            (BuildContext context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PriceText(
                  18,
                  perUnit: AmpStrings.perKwh,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                PriceText(1240.5, showPaise: true),
                const SizedBox(height: AmpTheme.spaceS),
                Text(
                  '${AmpFormat.kWh(42.6)} · ${AmpFormat.duration(const Duration(minutes: 95))} · ${AmpFormat.percent(80)}',
                  style: AmpType.tabular(
                    Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
                  ),
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryFreshness,
            (BuildContext context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FreshnessLabel(
                  updatedAt: now.subtract(const Duration(minutes: 3)),
                  now: now,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                FreshnessLabel(
                  updatedAt: now.subtract(const Duration(hours: 1)),
                  now: now,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                FreshnessLabel(
                  updatedAt: now.subtract(const Duration(hours: 5)),
                  now: now,
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryTimeline,
            (BuildContext context) => Column(
              children: const <Widget>[
                TimelineNode(
                  title: AmpStrings.journeyStart,
                  subtitle: AmpStrings.galleryTimelineStartDetail,
                  kind: TimelineNodeKind.start,
                  isFirst: true,
                ),
                TimelineNode(
                  title: AmpStrings.journeyChargingStop,
                  subtitle: AmpStrings.gallerySampleStation,
                  detail: AmpStrings.galleryTimelineStopDetail,
                  kind: TimelineNodeKind.chargingStop,
                ),
                TimelineNode(
                  title: AmpStrings.journeyBackup,
                  subtitle: AmpStrings.gallerySampleStation,
                  detail: AmpStrings.galleryTimelineBackupDetail,
                  kind: TimelineNodeKind.backupStop,
                ),
                TimelineNode(
                  title: AmpStrings.journeyArrival,
                  subtitle: AmpStrings.galleryTimelineArrivalDetail,
                  detail: AmpStrings.gallerySampleSlot,
                  kind: TimelineNodeKind.arrival,
                  isLast: true,
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryTicket,
            (BuildContext context) => TicketCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AmpStrings.galleryTicketBooked,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AmpTheme.spaceS),
                            Text(
                              AmpStrings.gallerySampleCode,
                              style: AmpType.metric(context, size: 27),
                            ),
                          ],
                        ),
                      ),
                      AmpIcon(AmpIconName.qr, size: 48, color: context.amp.ink),
                    ],
                  ),
                  const SizedBox(height: AmpTheme.spaceM),
                  Text(
                    AmpStrings.gallerySampleStation,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AmpStrings.gallerySamplePort,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AmpTheme.spaceS),
                  Text(
                    AmpStrings.gallerySampleSlot,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          _section(
            AmpStrings.galleryReceipt,
            (BuildContext context) => Container(
              padding: const EdgeInsets.all(AmpTheme.spaceM),
              decoration: BoxDecoration(
                color: context.amp.surface,
                borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
                border: Border.all(color: context.amp.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          AmpStrings.galleryReceiptTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const AmpBadge(
                        AmpStrings.receiptIssued,
                        tone: AmpBadgeTone.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AmpTheme.spaceS),
                  ReceiptRow(
                    label: AmpStrings.receiptStartReading,
                    value: AmpFormat.kWh(1204),
                  ),
                  ReceiptRow(
                    label: AmpStrings.receiptEndReading,
                    value: AmpFormat.kWh(1238.6),
                  ),
                  ReceiptRow(
                    label: AmpStrings.receiptVerifiedKwh,
                    value: AmpFormat.kWh(34.6),
                  ),
                  Divider(color: context.amp.divider),
                  ReceiptRow(
                    label: AmpStrings.receiptEnergy,
                    value: AmpFormat.rupees(622.8, showPaise: true),
                  ),
                  ReceiptRow(
                    label: AmpStrings.receiptServiceFee,
                    value: AmpFormat.rupees(5),
                  ),
                  ReceiptRow(
                    label: AmpStrings.receiptGatewayFee,
                    value: AmpFormat.rupees(4),
                  ),
                  ReceiptRow(
                    label: AmpStrings.receiptAdjustment,
                    value: AmpFormat.rupees(0),
                  ),
                  ReceiptRow(
                    label: AmpStrings.receiptTotal,
                    value: AmpFormat.rupees(631.8, showPaise: true),
                    emphasis: true,
                  ),
                  const SizedBox(height: AmpTheme.spaceS),
                  Text(
                    AmpStrings.notPaidNotice,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          _section(
            AmpStrings.galleryStates,
            (BuildContext context) => Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: context.amp.surface,
                    borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
                    border: Border.all(color: context.amp.divider),
                  ),
                  child: const ChargerRowSkeleton(),
                ),
                const SizedBox(height: AmpTheme.spaceM),
                SizedBox(
                  height: 280,
                  child: EmptyState(
                    title: AmpStrings.galleryEmptyTitle,
                    message: AmpStrings.galleryEmptyBody,
                    action: AmpButton(
                      label: AmpStrings.galleryButtonPrimary,
                      variant: AmpButtonVariant.tonal,
                      onPressed: () {},
                      expand: false,
                    ),
                  ),
                ),
                const SizedBox(height: AmpTheme.spaceM),
                SizedBox(
                  height: 320,
                  child: ErrorState(
                    message: AmpStrings.gallerySampleError,
                    onRetry: () {},
                  ),
                ),
                OfflineBanner(visible: true, onRetry: () {}),
              ],
            ),
          ),
          _section(
            AmpStrings.gallerySheets,
            (BuildContext context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AmpButton(
                  label: AmpStrings.gallerySheetTitle,
                  variant: AmpButtonVariant.tonal,
                  onPressed: () => _openSheet(context),
                ),
                const SizedBox(height: AmpTheme.spaceS),
                AmpButton(
                  label: AmpStrings.galleryDialogAction,
                  variant: AmpButtonVariant.danger,
                  onPressed: () => _openConfirm(context),
                ),
              ],
            ),
          ),
          _section(
            AmpStrings.galleryFeedback,
            (BuildContext context) => Wrap(
              spacing: AmpTheme.spaceS,
              runSpacing: AmpTheme.spaceS,
              children: <Widget>[
                AmpButton(
                  label: AmpStrings.gallerySnackbarSuccess,
                  variant: AmpButtonVariant.tonal,
                  expand: false,
                  onPressed: () => AmpSnackbar.show(
                    context,
                    AmpStrings.gallerySnackbarSuccess,
                    tone: AmpSnackbarTone.success,
                  ),
                ),
                AmpButton(
                  label: AmpStrings.gallerySnackbarError,
                  variant: AmpButtonVariant.tonal,
                  expand: false,
                  onPressed: () => AmpSnackbar.show(
                    context,
                    AmpStrings.gallerySnackbarError,
                    tone: AmpSnackbarTone.error,
                    actionLabel: AmpStrings.undo,
                    onAction: () {},
                  ),
                ),
                AmpButton(
                  label: AmpStrings.gallerySnackbarInfo,
                  variant: AmpButtonVariant.tonal,
                  expand: false,
                  onPressed: () => AmpSnackbar.show(
                    context,
                    AmpStrings.gallerySnackbarInfo,
                    actionLabel: AmpStrings.undo,
                    onAction: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setMode(_GalleryPreviewMode mode) {
    setState(() => _mode = mode);
  }

  Widget _section(String title, WidgetBuilder builder) {
    return _GallerySection(
      title: title,
      preview: _PreviewPair(mode: _mode, builder: builder),
    );
  }

  Future<void> _openSheet(BuildContext context) {
    return showAmpSheet<void>(
      context: context,
      title: AmpStrings.gallerySheetTitle,
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AmpStrings.gallerySheetBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          const AmpField(label: AmpStrings.galleryFieldEmail),
          const SizedBox(height: AmpTheme.spaceM),
          AmpButton(
            label: AmpStrings.galleryButtonPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _openConfirm(BuildContext context) async {
    await showAmpConfirmDialog(
      context,
      title: AmpStrings.galleryConfirmTitle,
      message: AmpStrings.galleryConfirmBody,
      confirmLabel: AmpStrings.galleryConfirmAction,
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.title, required this.preview});

  final String title;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AmpType.eyebrow(context)),
          const SizedBox(height: AmpTheme.spaceM),
          preview,
        ],
      ),
    );
  }
}

class _PreviewPair extends StatelessWidget {
  const _PreviewPair({required this.mode, required this.builder});

  final _GalleryPreviewMode mode;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool oneTheme = mode != _GalleryPreviewMode.both;
        final bool sideBySide = constraints.maxWidth >= 680;

        final Widget light = _PreviewPane(
          theme: _galleryLight,
          label: AmpStrings.galleryPreviewLight,
          builder: builder,
        );
        final Widget dark = _PreviewPane(
          theme: _galleryDark,
          label: AmpStrings.galleryPreviewDark,
          builder: builder,
        );

        if (mode == _GalleryPreviewMode.light) {
          return light;
        }
        if (mode == _GalleryPreviewMode.dark) {
          return dark;
        }
        if (oneTheme) {
          return light;
        }
        if (sideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: light),
              const SizedBox(width: AmpTheme.spaceM),
              Expanded(child: dark),
            ],
          );
        }
        return Column(
          children: <Widget>[
            light,
            const SizedBox(height: AmpTheme.spaceM),
            dark,
          ],
        );
      },
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({
    required this.theme,
    required this.label,
    required this.builder,
  });

  final ThemeData theme;
  final String label;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = theme.extension<AmpColors>()!;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Theme(
        data: theme,
        child: Builder(
          builder: (BuildContext context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: colors.surfaceVariant,
                padding: const EdgeInsets.symmetric(
                  horizontal: AmpTheme.spaceM,
                  vertical: AmpTheme.spaceS,
                ),
                child: Text(
                  label,
                  style: AmpType.eyebrow(context, color: colors.inkSecondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AmpTheme.spaceM),
                child: builder(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectorSample extends StatelessWidget {
  const _ConnectorSample({required this.kind, required this.label});

  final ConnectorKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: c.primaryTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: ConnectorGlyph(kind, size: 28, color: c.onPrimaryTint),
          ),
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

void _noop() {}
