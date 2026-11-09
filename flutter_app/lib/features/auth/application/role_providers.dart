import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import 'app_role.dart';
import 'profile_providers.dart';

/// Local, non-secret memory of the role an account last used.
abstract interface class RoleStore {
  Future<AppRole?> read(String userId);

  Future<void> write(String userId, AppRole role);
}

class SharedPreferencesRoleStore implements RoleStore {
  static const String _prefix = 'amperly.active_role.';

  @override
  Future<AppRole?> read(String userId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return AppRole.fromStorage(preferences.getString('$_prefix$userId'));
  }

  @override
  Future<void> write(String userId, AppRole role) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('$_prefix$userId', role.storageValue);
  }
}

final Provider<RoleStore> roleStoreProvider = Provider<RoleStore>(
  (Ref ref) => SharedPreferencesRoleStore(),
);

/// The account's remembered role, scoped to the resolved profile.
///
/// It rebuilds when the signed-in profile changes, so one account's choice
/// never leaks into the next account on the same device.
class ActiveRoleController extends AsyncNotifier<AppRole?> {
  @override
  Future<AppRole?> build() async {
    final RoleStore store = ref.watch(roleStoreProvider);
    final RepositoryResult<AppUser> profile = await ref.watch(
      currentProfileProvider.future,
    );
    final AppUser? user = profile.valueOrNull;
    if (user == null || user.isBlocked) {
      return null;
    }
    try {
      return await store.read(user.id);
    } on Object {
      // A local preference failure must not keep an entitled account out.
      return null;
    }
  }

  Future<void> select(AppRole role) async {
    final RepositoryResult<AppUser> profile = await ref.read(
      currentProfileProvider.future,
    );
    final AppUser? user = profile.valueOrNull;
    if (user == null || user.isBlocked || !role.isEntitledBy(user)) {
      return;
    }

    state = AsyncData<AppRole?>(role);
    try {
      await ref.read(roleStoreProvider).write(user.id, role);
    } on Object {
      // The acting role still changes for this session.
    }
  }
}

final AsyncNotifierProvider<ActiveRoleController, AppRole?> activeRoleProvider =
    AsyncNotifierProvider<ActiveRoleController, AppRole?>(
      ActiveRoleController.new,
    );
