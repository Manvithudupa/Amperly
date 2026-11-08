import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_button.dart';
import 'package:amperly/features/gallery/component_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery renders its sections with light and dark panes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        darkTheme: AmpTheme.dark(),
        home: const ComponentGalleryScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(AmpStrings.galleryTitle), findsOneWidget);
    expect(find.text(AmpStrings.galleryButtons), findsOneWidget);
    expect(find.text(AmpStrings.galleryPreviewLight), findsWidgets);
    expect(find.text(AmpStrings.galleryPreviewDark), findsWidgets);
    expect(find.byType(AmpButton), findsWidgets);

    // Dispose the tree so no repeating skeleton animation survives the test.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
