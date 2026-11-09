import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';
import 'hairline.dart';
import 'port_dots.dart';
import 'status_dot_label.dart';

/// A charger, booking or session as a departure-board row.
///
/// The left column is the fact that helps a driver choose; the right column is
/// the price. A hairline is the only separator. There is no card, no shadow and
/// no filled status badge.
class DepartureRow extends StatelessWidget {
  const DepartureRow({
    required this.title,
    required this.metric,
    required this.metricUnit,
    super.key,
    this.detail,
    this.statusLabel,
    this.statusDetail,
    this.statusTone = StatusDotTone.available,
    this.availablePorts = 0,
    this.totalPorts = 0,
    this.price,
    this.priceUnit = AmpStrings.perKwh,
    this.discoveryOnly = false,
    this.onTap,
    this.showHairline = true,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AmpTheme.screenPadding,
      vertical: 14,
    ),
  });

  final String title;
  final String metric;
  final String metricUnit;
  final String? detail;
  final String? statusLabel;
  final String? statusDetail;
  final StatusDotTone statusTone;
  final int availablePorts;
  final int totalPorts;
  final String? price;
  final String priceUnit;
  final bool discoveryOnly;
  final VoidCallback? onTap;
  final bool showHairline;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final double textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 2.0);
    final double metricWidth = 48 + (textScale - 1) * 36;
    final double priceWidth = 64 + (textScale - 1) * 36;
    final bool largeText = textScale >= 1.5;
    final Widget? portDots = totalPorts > 0
        ? PortDots(available: availablePorts, total: totalPorts)
        : null;
    final TextStyle detailStyle =
        Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.inkSecondary) ??
        const TextStyle();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Padding(
              padding: contentPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: metricWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          metric,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: AmpType.metric(context, size: 26),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          metricUnit,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: AmpType.eyebrow(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.ink,
                              ),
                        ),
                        if (detail != null) ...<Widget>[
                          const SizedBox(height: 5),
                          if (largeText)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(detail!, style: detailStyle),
                                if (portDots != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: portDots,
                                  ),
                              ],
                            )
                          else
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(detail!, style: detailStyle),
                                ),
                                if (portDots != null) ...<Widget>[
                                  const SizedBox(width: AmpTheme.spaceS),
                                  portDots,
                                ],
                              ],
                            ),
                        ],
                        if (statusLabel != null) ...<Widget>[
                          const SizedBox(height: 7),
                          StatusDotLabel(
                            statusLabel!,
                            detail: statusDetail,
                            tone: statusTone,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: priceWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        if (discoveryOnly)
                          Text(
                            AmpStrings.meterDiscoveryOnly,
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 10.5,
                                  height: 1.25,
                                  letterSpacing: 0,
                                ),
                          )
                        else if (price != null) ...<Widget>[
                          Text(
                            price!,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            textAlign: TextAlign.right,
                            style: AmpType.metric(context, size: 19),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            priceUnit,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            style: AmpType.eyebrow(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showHairline) const Hairline(),
          ],
        ),
      ),
    );
  }
}
