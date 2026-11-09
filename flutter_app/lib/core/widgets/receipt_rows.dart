import 'package:flutter/material.dart';

import 'receipt_row.dart';

/// One line in a printed receipt.
final class ReceiptLine {
  const ReceiptLine({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;
}

/// Receipt lines with dotted leaders and tabular right columns.
///
/// The total is still a line, not a filled summary card.
class ReceiptRows extends StatelessWidget {
  const ReceiptRows({required this.lines, super.key});

  final List<ReceiptLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final ReceiptLine line in lines)
          ReceiptRow(
            label: line.label,
            value: line.value,
            emphasis: line.emphasis,
          ),
      ],
    );
  }
}
