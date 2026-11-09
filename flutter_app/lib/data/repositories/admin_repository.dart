import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/user_messages.dart';
import '../../core/formatting/amp_format.dart';
import '../../core/ids.dart';
import '../../core/ui/strings.dart';
import '../../domain/engines/enforcement_policy_engine.dart';
import '../../domain/engines/host_analytics_engine.dart';
import '../../domain/policy.dart';
import '../models/models.dart';
import 'repository_result.dart';
import 'rpc_repository.dart';

final class AdminDisputeRow {
  const AdminDisputeRow({
    required this.dispute,
    required this.evidence,
    required this.session,
  });

  final Dispute dispute;
  final List<MeterReading> evidence;
  final ChargingSession? session;
}

final class AdminReportRow {
  const AdminReportRow({
    required this.report,
    required this.reporterName,
    required this.targetName,
    required this.targetUserId,
    required this.isHostReport,
  });

  final Report report;
  final String reporterName;
  final String targetName;
  final String? targetUserId;
  final bool isHostReport;
}

final class AdminDeskData {
  const AdminDeskData({
    required this.pendingStations,
    required this.disputes,
    required this.consumerReports,
    required this.hostReports,
    required this.analytics,
  });

  final List<ChargerStation> pendingStations;
  final List<AdminDisputeRow> disputes;
  final List<AdminReportRow> consumerReports;
  final List<AdminReportRow> hostReports;
  final HostAnalytics analytics;

  int get reportCount => consumerReports.length + hostReports.length;
}

/// Platform operations: listing approval, disputes and user reports.
///
/// The server functions re-check the administrator role. This repository only
/// prepares the same payloads the native desk used and reads names the admin is
/// allowed to see.
final class AdminRepository {
  AdminRepository(this._client, this._rpc);

  final SupabaseClient _client;
  final RpcRepository _rpc;

  Future<RepositoryResult<AdminDeskData>> load() async {
    try {
      final List<ChargerStation> stations =
          (await _client.from('charger_stations').select())
              .whereType<Map<String, dynamic>>()
              .map(ChargerStation.fromJson)
              .toList(growable: false);
      final List<ChargerPort> ports =
          (await _client.from('charger_ports').select())
              .whereType<Map<String, dynamic>>()
              .map(ChargerPort.fromJson)
              .toList(growable: false);
      final List<ChargingSession> sessions =
          (await _client.from('charging_sessions').select())
              .whereType<Map<String, dynamic>>()
              .map(ChargingSession.fromJson)
              .toList(growable: false);
      final List<Reservation> reservations =
          (await _client.from('reservations').select())
              .whereType<Map<String, dynamic>>()
              .map(Reservation.fromJson)
              .toList(growable: false);
      final List<Invoice> invoices = (await _client.from('invoices').select())
          .whereType<Map<String, dynamic>>()
          .map(Invoice.fromJson)
          .toList(growable: false);
      final List<Dispute> disputes = (await _client.from('disputes').select())
          .whereType<Map<String, dynamic>>()
          .map(Dispute.fromJson)
          .toList(growable: false);
      final List<Report> reports = (await _client.from('reports').select())
          .whereType<Map<String, dynamic>>()
          .map(Report.fromJson)
          .toList(growable: false);
      final List<AppUser> users = (await _client.from('users').select())
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList(growable: false);

      final Set<String> disputeSessionIds = disputes
          .map((Dispute dispute) => dispute.sessionId)
          .whereType<String>()
          .where((String id) => id.isNotEmpty)
          .toSet();
      final List<MeterReading> readings = disputeSessionIds.isEmpty
          ? const <MeterReading>[]
          : (await _client
                    .from('meter_readings')
                    .select()
                    .inFilter('sessionId', disputeSessionIds.toList()))
                .whereType<Map<String, dynamic>>()
                .map(MeterReading.fromJson)
                .toList(growable: false);

      final Map<String, AppUser> usersById = <String, AppUser>{
        for (final AppUser user in users) user.id: user,
      };
      final Map<String, ChargingSession> sessionsById =
          <String, ChargingSession>{
            for (final ChargingSession session in sessions) session.id: session,
          };
      final Map<String, ChargerStation> stationsById = <String, ChargerStation>{
        for (final ChargerStation station in stations) station.id: station,
      };

      final List<AdminReportRow> consumerReports = <AdminReportRow>[];
      final List<AdminReportRow> hostReports = <AdminReportRow>[];
      for (final Report report in reports) {
        final ChargingSession? session = report.sessionId == null
            ? null
            : sessionsById[report.sessionId];
        final String? targetUserId = _targetUserId(report, session);
        final bool fromHost = report.sessionId != null
            ? session != null && report.reporterId == session.hostId
            : report.targetHostId == null && report.targetStationId == null
            ? usersById[report.reporterId]?.isPlatformAdmin == false &&
                  (usersById[report.reporterId]?.role ?? '').toUpperCase() ==
                      AmpPolicy.roleHost
            : false;
        final String reporterName =
            (report.reporterName ?? '').trim().isNotEmpty
            ? report.reporterName!.trim()
            : (usersById[report.reporterId]?.name ?? '').trim().isNotEmpty
            ? usersById[report.reporterId]!.name!.trim()
            : AmpStrings.adminUnknownAccount;
        final String targetName =
            (usersById[targetUserId]?.name ?? '').trim().isNotEmpty
            ? usersById[targetUserId]!.name!.trim()
            : (stationsById[report.targetStationId]?.name ?? '')
                  .trim()
                  .isNotEmpty
            ? stationsById[report.targetStationId]!.name!.trim()
            : AmpStrings.adminNoTarget;
        final AdminReportRow row = AdminReportRow(
          report: report,
          reporterName: reporterName,
          targetName: targetName,
          targetUserId: targetUserId,
          isHostReport: fromHost,
        );
        (fromHost ? hostReports : consumerReports).add(row);
      }

      final List<AdminDisputeRow> disputeRows = disputes
          .map(
            (Dispute dispute) => AdminDisputeRow(
              dispute: dispute,
              evidence: readings
                  .where(
                    (MeterReading reading) =>
                        reading.sessionId == dispute.sessionId,
                  )
                  .toList(growable: false),
              session: dispute.sessionId == null
                  ? null
                  : sessionsById[dispute.sessionId],
            ),
          )
          .toList(growable: false);

      return RepositorySuccess<AdminDeskData>(
        AdminDeskData(
          pendingStations: stations
              .where(
                (ChargerStation station) =>
                    (station.approvalStatus ?? '').toUpperCase() ==
                    AmpPolicy.approvalPending,
              )
              .toList(growable: false),
          disputes: disputeRows,
          consumerReports: consumerReports,
          hostReports: hostReports,
          analytics: HostAnalyticsEngine.compute(
            stations: stations,
            ports: ports,
            sessions: sessions,
            reservations: reservations,
            invoices: invoices,
            disputes: disputes,
          ),
        ),
      );
    } on Object catch (error) {
      return RepositoryFailure<AdminDeskData>.from(error);
    }
  }

  String? _targetUserId(Report report, ChargingSession? session) {
    final String hostId = (report.targetHostId ?? '').trim();
    if (hostId.isNotEmpty) {
      return hostId;
    }
    if (session != null) {
      return session.consumerId;
    }
    return null;
  }

  Future<RepositoryResult<String>> decideStation({
    required ChargerStation station,
    required bool approve,
  }) {
    return _rpc.decideStationApproval(stationId: station.id, approve: approve);
  }

  Future<RepositoryResult<String>> refundDispute(Dispute dispute) {
    return _rpc.resolveDisputeRefund(dispute.id);
  }

  Future<RepositoryResult<String>> freezeDisputePayout(Dispute dispute) {
    return _rpc.freezeDisputePayout(dispute.id);
  }

  Future<RepositoryResult<String>> applyDisputeEnforcement({
    required Dispute dispute,
    required String action,
    required double fineAmount,
  }) {
    final String reason = <String>[
      '${AmpStrings.adminEnforcementNotePrefix}: $action',
      if (fineAmount > 0)
        '${AmpStrings.adminFineLabel}: ${AmpFormat.rupees(fineAmount)}',
    ].join(' · ');
    return _rpc.applyHostEnforcement(
      disputeId: dispute.id,
      action: action,
      fineAmount: fineAmount,
      note: reason,
    );
  }

  Future<RepositoryResult<int>> enforcementCountFor(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return const RepositorySuccess<int>(0);
    }
    try {
      final List<dynamic> rows = await _client
          .from('host_enforcements')
          .select()
          .eq('hostId', userId);
      return RepositorySuccess<int>(rows.length);
    } on Object catch (error) {
      return RepositoryFailure<int>.from(error);
    }
  }

  int suggestedSuspensionDays(int priorActions) {
    return EnforcementPolicyEngine.suggestedSuspensionDays(priorActions + 1);
  }

  /// Records one report decision, notifies the target, blocks them on a ban,
  /// then closes the report. This matches `applyReportAction` in the native app.
  Future<RepositoryResult<bool>> applyReportAction({
    required AdminReportRow row,
    required String action,
    int expiresAtMs = 0,
  }) async {
    final String? targetId = row.targetUserId;
    if (targetId == null || targetId.isEmpty) {
      return RepositoryFailure<bool>(
        kind: UserMessageKind.validation,
        message: AmpStrings.adminNoTarget,
      );
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final bool ban = action == AmpPolicy.enforcementBan;
    final HostEnforcement enforcement = HostEnforcement(
      id: newId('enf_'),
      hostId: targetId,
      stationId: row.report.targetStationId,
      actionType: action,
      reason: AmpStrings.adminReportNote(
        action,
        row.report.reportType ?? AmpStrings.labelUnknown,
      ),
      fineAmount: 0,
      createdAtMs: now,
      expiresAtMs: expiresAtMs,
    );
    final AppNotification notice = AppNotification(
      id: newId('ntf_'),
      userId: targetId,
      title: _noticeTitle(action),
      message: _noticeBody(row.report, action, expiresAtMs),
      isRead: false,
      createdAtMs: now,
    );

    try {
      await _client
          .from('host_enforcements')
          .insert(enforcement.toJson()..remove('serverUpdatedAt'));
      await _client
          .from('notifications')
          .insert(notice.toJson()..remove('serverUpdatedAt'));
      if (ban) {
        await _client
            .from('users')
            .update(<String, Object?>{'isBlocked': true})
            .eq('id', targetId);
      }
      await _client
          .from('reports')
          .update(<String, Object?>{'status': 'RESOLVED'})
          .eq('id', row.report.id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  String _noticeTitle(String action) {
    return switch (action) {
      AmpPolicy.enforcementSuspension => AmpStrings.adminNoticeSuspendTitle,
      AmpPolicy.enforcementBan => AmpStrings.adminNoticeBanTitle,
      _ => AmpStrings.adminNoticeWarningTitle,
    };
  }

  String _noticeBody(Report report, String action, int expiresAtMs) {
    final String type = report.reportType ?? AmpStrings.labelUnknown;
    return switch (action) {
      AmpPolicy.enforcementSuspension => AmpStrings.adminNoticeSuspendBody(
        type,
        AmpFormat.messageTimestamp(expiresAtMs),
      ),
      AmpPolicy.enforcementBan => AmpStrings.adminNoticeBanBody(type),
      _ => AmpStrings.adminNoticeWarningBody(type),
    };
  }
}
