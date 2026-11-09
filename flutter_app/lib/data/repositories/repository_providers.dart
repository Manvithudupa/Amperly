import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_bootstrap.dart';
import 'admin_repository.dart';
import 'chat_repository.dart';
import 'host_repository.dart';
import 'notification_repository.dart';
import 'profile_repository.dart';
import 'report_repository.dart';
import 'reservation_repository.dart';
import 'rpc_repository.dart';
import 'safety_repository.dart';
import 'session_repository.dart';
import 'station_repository.dart';
import 'vehicle_repository.dart';

/// The initialized client, or null in a build with no backend settings.
final Provider<SupabaseClient?> supabaseClientProvider =
    Provider<SupabaseClient?>((Ref ref) => SupabaseBootstrap.clientOrNull);

final Provider<ProfileRepository?> profileRepositoryProvider =
    Provider<ProfileRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : ProfileRepository(client);
    });

final Provider<StationRepository?> stationRepositoryProvider =
    Provider<StationRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : StationRepository(client);
    });

final Provider<VehicleRepository?> vehicleRepositoryProvider =
    Provider<VehicleRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : VehicleRepository(client);
    });

final Provider<ReservationRepository?> reservationRepositoryProvider =
    Provider<ReservationRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : ReservationRepository(client);
    });

final Provider<SessionRepository?> sessionRepositoryProvider =
    Provider<SessionRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : SessionRepository(client);
    });

final Provider<ChatRepository?> chatRepositoryProvider =
    Provider<ChatRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : ChatRepository(client);
    });

final Provider<NotificationRepository?> notificationRepositoryProvider =
    Provider<NotificationRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : NotificationRepository(client);
    });

final Provider<ReportRepository?> reportRepositoryProvider =
    Provider<ReportRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : ReportRepository(client);
    });

final Provider<SafetyRepository?> safetyRepositoryProvider =
    Provider<SafetyRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : SafetyRepository(client);
    });

final Provider<HostRepository?> hostRepositoryProvider =
    Provider<HostRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : HostRepository(client);
    });

final Provider<RpcRepository?> rpcRepositoryProvider = Provider<RpcRepository?>(
  (Ref ref) {
    final SupabaseClient? client = ref.watch(supabaseClientProvider);
    return client == null ? null : RpcRepository(client);
  },
);

final Provider<AdminRepository?> adminRepositoryProvider =
    Provider<AdminRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      final RpcRepository? rpc = ref.watch(rpcRepositoryProvider);
      return client == null || rpc == null
          ? null
          : AdminRepository(client, rpc);
    });
