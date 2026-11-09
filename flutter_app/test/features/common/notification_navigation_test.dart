import 'package:amperly/data/models/models.dart';
import 'package:amperly/features/common/application/notification_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a notification opens the section its written update names', () {
    expect(_target(title: 'Booking confirmed'), '/bookings');
    expect(_target(title: 'Your charging session ended'), '/sessions');
    expect(_target(title: 'New message', message: 'Asha replied'), '/messages');
    expect(_target(title: 'Saved trip updated'), '/trips');
    expect(_target(title: 'Your vehicle was removed'), '/vehicles');
    expect(_target(title: 'Charger approved'), '/home');
  });

  test('an update with no known section stays on the ledger', () {
    expect(_target(title: 'Account updated'), isNull);
  });
}

String? _target({required String title, String message = ''}) {
  return notificationSectionTarget(
    AppNotification(
      id: 'notification-1',
      title: title,
      message: message,
      createdAtMs: 1000,
    ),
  );
}
