import 'package:amperly/features/auth/application/app_role.dart';
import 'package:amperly/features/auth/application/role_providers.dart';

class FakeRoleStore implements RoleStore {
  FakeRoleStore([Map<String, AppRole>? initial])
    : roles = <String, AppRole>{...?initial};

  final Map<String, AppRole> roles;

  @override
  Future<AppRole?> read(String userId) async => roles[userId];

  @override
  Future<void> write(String userId, AppRole role) async {
    roles[userId] = role;
  }
}
