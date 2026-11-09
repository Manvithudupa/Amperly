import '../../../data/models/models.dart';

/// The closest safe section for a notification.
///
/// The notifications table carries only a title, body and read flag, so there
/// is no row id to open directly. Rather than invent a target or change the
/// schema, this maps the written update to the section that holds its detail.
String? notificationSectionTarget(AppNotification item) {
  final String text = '${item.title ?? ''} ${item.message ?? ''}'.toLowerCase();
  if (text.contains('session') ||
      text.contains('receipt') ||
      text.contains('charging')) {
    return '/sessions';
  }
  if (text.contains('message') || text.contains('chat')) {
    return '/messages';
  }
  if (text.contains('booking') || text.contains('reservation')) {
    return '/bookings';
  }
  if (text.contains('trip') || text.contains('route')) {
    return '/trips';
  }
  if (text.contains('vehicle') || text.contains('car ')) {
    return '/vehicles';
  }
  if (text.contains('charger') || text.contains('station')) {
    return '/home';
  }
  return null;
}
