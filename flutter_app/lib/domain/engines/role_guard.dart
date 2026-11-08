import '../../data/models/models.dart';

abstract final class RoleGuard {
  static bool canPerformAdminAction(AppUser? user) {
    return user != null && user.isPlatformAdmin && !user.isBlocked;
  }

  static bool canManageStation(AppUser? user, String? stationHostId) {
    if (user == null) {
      return false;
    }
    if (user.isPlatformAdmin) {
      return !user.isBlocked;
    }
    return !user.isBlocked &&
        user.id.isNotEmpty &&
        stationHostId != null &&
        user.id == stationHostId;
  }

  static bool canReservePort(AppUser? user) {
    return user != null && user.canActAsConsumer;
  }

  static bool canRegisterStation(AppUser? user) {
    return user != null && user.canActAsHost;
  }

  static bool isRestricted(AppUser? user, int suspendedUntilMs, int nowMs) {
    if (user == null) {
      return true;
    }
    return user.isBlocked || suspendedUntilMs > nowMs;
  }
}
