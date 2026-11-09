import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../domain/policy.dart';

/// The capacity an account is acting in.
///
/// Consumer and Host are the dual-role pair every active account has. Admin is
/// only added when the server marks the account as a platform administrator,
/// matching the native `AuthManager` entitlement rules.
enum AppRole {
  consumer(
    storageValue: AmpPolicy.roleConsumer,
    homePath: '/home',
    accountPath: '/account',
  ),
  host(
    storageValue: AmpPolicy.roleHost,
    homePath: '/host/dashboard',
    accountPath: '/host/account',
  ),
  admin(
    storageValue: AmpPolicy.roleAdmin,
    homePath: '/admin/queue',
    accountPath: '/admin/account',
  );

  const AppRole({
    required this.storageValue,
    required this.homePath,
    required this.accountPath,
  });

  final String storageValue;
  final String homePath;
  final String accountPath;

  String get label => switch (this) {
    AppRole.consumer => AmpStrings.accountConsumer,
    AppRole.host => AmpStrings.accountHost,
    AppRole.admin => AmpStrings.accountAdmin,
  };

  bool isEntitledBy(AppUser user) => switch (this) {
    AppRole.consumer => user.canActAsConsumer,
    AppRole.host => user.canActAsHost,
    AppRole.admin => user.canActAsAdmin,
  };

  static AppRole? fromStorage(String? stored) {
    final String value = (stored ?? '').trim().toUpperCase();
    for (final AppRole role in AppRole.values) {
      if (role.storageValue == value) {
        return role;
      }
    }
    return null;
  }
}

/// Every role this account may act in, in the native order.
List<AppRole> entitledRolesFor(AppUser user) {
  return <AppRole>[
    if (user.canActAsConsumer) AppRole.consumer,
    if (user.canActAsHost) AppRole.host,
    if (user.canActAsAdmin) AppRole.admin,
  ];
}

/// The role to open after sign-in.
///
/// A remembered role wins while the account is still entitled to it. A new
/// administrator starts at the admin desk; every other new account starts as a
/// consumer, which is the native sign-in default.
AppRole preferredRoleFor(AppUser user, AppRole? remembered) {
  if (remembered != null && remembered.isEntitledBy(user)) {
    return remembered;
  }
  return user.canActAsAdmin ? AppRole.admin : AppRole.consumer;
}
