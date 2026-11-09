import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/widgets/amp_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('caps typed text at the declared maximum length', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        home: Scaffold(
          body: AmpField(controller: controller, label: 'Name', maxLength: 5),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '123456789');
    await tester.pump();

    expect(controller.text, '12345');
  });

  testWidgets('shows the inline error when focus leaves the field', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        home: Scaffold(
          body: AmpField(
            controller: controller,
            focusNode: focusNode,
            label: 'Name',
            autovalidateMode: AutovalidateMode.disabled,
            validator: (String? value) =>
                (value ?? '').trim().isEmpty ? 'Enter a name.' : null,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    expect(find.text('Enter a name.'), findsNothing);

    focusNode.unfocus();
    await tester.pump();

    expect(find.text('Enter a name.'), findsOneWidget);
  });
}
