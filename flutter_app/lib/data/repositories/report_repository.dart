import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/ids.dart';
import '../models/models.dart';
import 'repository_result.dart';

final class ReportRepository {
  ReportRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<Report>> submit({
    required AppUser reporter,
    required String reportType,
    required String description,
    String? stationId,
    String? hostId,
    String? sessionId,
  }) async {
    final Report draft = Report(
      id: newId('rpt_'),
      reporterId: reporter.id,
      reporterName: reporter.name,
      targetStationId: stationId,
      targetHostId: hostId,
      sessionId: sessionId,
      reportType: reportType,
      description: description.trim().isEmpty
          ? 'No details provided.'
          : description.trim(),
      status: 'OPEN',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      final Map<String, dynamic> row = await _client
          .from('reports')
          .insert(draft.toJson()..remove('serverUpdatedAt'))
          .select()
          .single();
      return RepositorySuccess<Report>(
        Report.fromJson(Map<String, dynamic>.from(row)),
      );
    } on Object catch (error) {
      return RepositoryFailure<Report>.from(error);
    }
  }
}
