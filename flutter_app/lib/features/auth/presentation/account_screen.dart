import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_badge.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/policy.dart';
import '../../consumer/application/vehicle_providers.dart';
import '../application/profile_providers.dart';
import 'sign_out_button.dart';

/// The signed-in identity, its capacities, the active vehicle and sign-out.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<AppUser>> profile = ref.watch(
      currentProfileProvider,
    );

    return AmpScaffold(
      title: AmpStrings.accountTitle,
      body: profile.when(
        loading: () => const _ProfileLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
        data: (RepositoryResult<AppUser> result) {
          final RepositoryFailure<AppUser>? failure = result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(currentProfileProvider),
            );
          }
          return _AccountBody(profile: result.valueOrNull!);
        },
      ),
    );
  }
}

class _AccountBody extends ConsumerWidget {
  const _AccountBody({required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (profile.name ?? '').trim();
    final String displayName = name.isEmpty ? AmpStrings.appName : name;
    final String initial = displayName.characters.first.toUpperCase();
    final String? phone = (profile.phone ?? '').trim().isEmpty
        ? null
        : profile.phone!.trim();
    final AsyncValue<RepositoryResult<Vehicle?>> vehicle = ref.watch(
      activeVehicleProvider,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: colors.onPrimaryTint),
              ),
            ),
            const SizedBox(width: AmpTheme.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(displayName, style: text.headlineSmall),
                  if ((profile.email ?? '').trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(profile.email!, style: text.bodySmall),
                  ],
                  if (phone != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(phone, style: text.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceM),
        Wrap(
          spacing: AmpTheme.spaceS,
          runSpacing: AmpTheme.spaceS,
          children: <Widget>[
            AmpBadge(
              _roleLabel(profile.role),
              tone: profile.isPlatformAdmin
                  ? AmpBadgeTone.info
                  : AmpBadgeTone.neutral,
              icon: profile.isPlatformAdmin
                  ? AmpIconName.shield
                  : AmpIconName.check,
            ),
            _verificationBadge(profile.verificationStatus),
            if (profile.isBlocked)
              const AmpBadge(
                AmpStrings.blockedTitle,
                tone: AmpBadgeTone.danger,
                icon: AmpIconName.alert,
              ),
          ],
        ),
        if (profile.isBlocked) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          _Notice(message: AmpStrings.blockedBody, tone: AmpBadgeTone.danger),
        ],
        const SizedBox(height: AmpTheme.spaceL),
        Container(
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            children: <Widget>[
              _InfoRow(
                label: AmpStrings.accountRole,
                value: _roleLabel(profile.role),
              ),
              const SizedBox(height: AmpTheme.spaceS),
              _InfoRow(
                label: AmpStrings.accountVerification,
                value: _verificationLabel(profile.verificationStatus),
              ),
            ],
          ),
        ),
        const SizedBox(height: AmpTheme.spaceL),
        Text(AmpStrings.accountVehicleTitle, style: text.titleMedium),
        const SizedBox(height: AmpTheme.spaceS),
        vehicle.when(
          loading: () => const _VehicleLoading(),
          error: (Object error, StackTrace stack) =>
              _VehicleNotice(message: UserMessages.from(error)),
          data: (RepositoryResult<Vehicle?> result) {
            final RepositoryFailure<Vehicle?>? failure = result.failureOrNull;
            if (failure != null) {
              return _VehicleNotice(message: failure.message);
            }
            final Vehicle? active = result.valueOrNull;
            if (active == null) {
              return const _VehicleNotice(
                title: AmpStrings.accountNoVehicle,
                message: AmpStrings.accountNoVehicleBody,
              );
            }
            return _VehicleCard(vehicle: active);
          },
        ),
        const SizedBox(height: AmpTheme.spaceS),
        AmpButton(
          label: AmpStrings.vehicleManage,
          variant: AmpButtonVariant.tonal,
          icon: AmpIconName.bolt,
          onPressed: () => context.push('/vehicles'),
        ),
        const SizedBox(height: AmpTheme.spaceL),
        const SignOutButton(),
      ],
    );
  }

  static String _roleLabel(String? stored) {
    return switch ((stored ?? '').toUpperCase()) {
      AmpPolicy.roleAdmin => AmpStrings.accountAdmin,
      AmpPolicy.roleHost => AmpStrings.accountHost,
      _ => AmpStrings.accountConsumer,
    };
  }

  static String _verificationLabel(String? stored) {
    return switch ((stored ?? '').toUpperCase()) {
      'VERIFIED' => AmpStrings.verified,
      'PENDING' => AmpStrings.accountPending,
      _ => AmpStrings.accountUnverified,
    };
  }

  static AmpBadge _verificationBadge(String? stored) {
    return switch ((stored ?? '').toUpperCase()) {
      'VERIFIED' => const AmpBadge(
        AmpStrings.verified,
        tone: AmpBadgeTone.success,
        icon: AmpIconName.check,
      ),
      'PENDING' => const AmpBadge(
        AmpStrings.accountPending,
        tone: AmpBadgeTone.warning,
        icon: AmpIconName.clock,
      ),
      _ => const AmpBadge(
        AmpStrings.accountUnverified,
        tone: AmpBadgeTone.neutral,
        icon: AmpIconName.info,
      ),
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: text.bodySmall)),
        const SizedBox(width: AmpTheme.spaceM),
        Text(value, style: text.titleSmall),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String connector = vehicle.connectorType == null
        ? AmpStrings.connectorNotPublished
        : AmpFormat.connectorLabel(vehicle.connectorType);
    return Container(
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(AmpTheme.radiusField),
            ),
            child: Center(
              child: AmpIcon(
                AmpIconName.bolt,
                size: 21,
                color: colors.onPrimaryTint,
              ),
            ),
          ),
          const SizedBox(width: AmpTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(vehicle.displayName, style: text.titleMedium),
                    ),
                    const AmpBadge(
                      'In use',
                      tone: AmpBadgeTone.success,
                      icon: AmpIconName.check,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$connector · '
                  '${vehicle.effectiveCapacityKwh.toStringAsFixed(1)} kWh '
                  'usable',
                  style: text.bodySmall,
                ),
                if ((vehicle.licensePlate ?? '').trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(vehicle.licensePlate!, style: text.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleNotice extends StatelessWidget {
  const _VehicleNotice({required this.message, this.title});

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title!, style: text.titleSmall),
            const SizedBox(height: 2),
          ],
          Text(message, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.tone});

  final String message;
  final AmpBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color foreground = tone == AmpBadgeTone.danger
        ? colors.error
        : colors.info;
    final Color background = tone == AmpBadgeTone.danger
        ? colors.errorTint
        : colors.infoTint;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: foreground.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.ink),
      ),
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        Row(
          children: <Widget>[
            Skeleton(width: 60, height: 60, radius: 16),
            SizedBox(width: AmpTheme.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonLine(widthFactor: 0.5, height: 20),
                  SizedBox(height: AmpTheme.spaceS),
                  SkeletonLine(widthFactor: 0.7),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 90, radius: 16),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 90, radius: 16),
      ],
    );
  }
}

class _VehicleLoading extends StatelessWidget {
  const _VehicleLoading();

  @override
  Widget build(BuildContext context) {
    return const Skeleton(height: 82, radius: AmpTheme.radiusCard);
  }
}
