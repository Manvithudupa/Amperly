import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_sheet.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/policy.dart';
import '../../consumer/application/vehicle_providers.dart';
import '../application/app_role.dart';
import '../application/profile_providers.dart';
import '../application/role_providers.dart';
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

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    AppUser profile,
  ) async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) =>
          _EditNameDialog(initial: (profile.name ?? '').trim()),
    );
    if (name == null || !context.mounted) {
      return;
    }

    final repository = ref.read(profileRepositoryProvider);
    if (repository == null) {
      AmpSnackbar.show(
        context,
        AmpStrings.accountEditNameFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }

    final RepositoryResult<AppUser> result = await repository.updateDisplayName(
      userId: profile.id,
      name: name,
    );
    if (!context.mounted) {
      return;
    }
    final RepositoryFailure<AppUser>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(
        context,
        failure.message.isEmpty
            ? AmpStrings.accountEditNameFailed
            : failure.message,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(currentProfileProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.accountEditNameSaved,
      tone: AmpSnackbarTone.success,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (profile.name ?? '').trim();
    final String displayName = name.isEmpty ? AmpStrings.appName : name;
    final String? phone = (profile.phone ?? '').trim().isEmpty
        ? null
        : profile.phone!.trim();
    final AsyncValue<AppRole?> activeRole = ref.watch(activeRoleProvider);
    final AppRole actingRole =
        activeRole.asData?.value ?? preferredRoleFor(profile, null);
    final bool isAdmin = actingRole == AppRole.admin;
    final AsyncValue<RepositoryResult<Vehicle?>>? vehicle = isAdmin
        ? null
        : ref.watch(activeVehicleProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        const Eyebrow(AmpStrings.accountTitle),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.amp.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials(displayName),
                style: TextStyle(
                  fontFamily: AmpTheme.uiFont,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.amp.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: AmpTheme.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(displayName, style: text.displaySmall),
                  if ((profile.email ?? '').trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(profile.email!.trim(), style: text.bodySmall),
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
          spacing: AmpTheme.spaceL,
          runSpacing: AmpTheme.spaceS,
          children: <Widget>[
            StatusDotLabel(
              _roleLabel(profile.role),
              tone: StatusDotTone.neutral,
            ),
            StatusDotLabel(
              _verificationLabel(profile.verificationStatus),
              tone: _verificationTone(profile.verificationStatus),
            ),
            if (profile.isBlocked)
              const StatusDotLabel(
                AmpStrings.blockedTitle,
                tone: StatusDotTone.error,
              ),
          ],
        ),
        if (!profile.isBlocked) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceS),
          TextAction(
            AmpStrings.accountEditName,
            onPressed: () => _editName(context, ref, profile),
          ),
          const SizedBox(height: AmpTheme.spaceS),
          _RoleSwitcher(profile: profile, currentRole: actingRole),
        ],
        if (profile.isBlocked) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          const _BlockedNotice(),
        ],
        if (!isAdmin) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceL),
          const Hairline(),
          const SizedBox(height: AmpTheme.spaceL),
          const Eyebrow(AmpStrings.accountVehicleTitle),
          const SizedBox(height: AmpTheme.spaceS),
          vehicle!.when(
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
              return _ActiveVehicle(vehicle: active);
            },
          ),
          const SizedBox(height: AmpTheme.spaceS),
          TextAction(
            AmpStrings.vehicleManage,
            onPressed: () => context.push('/vehicles'),
          ),
        ],
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.accountToolsTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (!profile.isBlocked) ...<Widget>[
          if (!isAdmin) ...<Widget>[
            TextAction(
              AmpStrings.hostTitle,
              onPressed: () => context.push('/host'),
            ),
            TextAction(
              AmpStrings.notificationsTitle,
              onPressed: () => context.push('/notifications'),
            ),
            TextAction(
              AmpStrings.accountChargingHistory,
              onPressed: () => context.push('/sessions'),
            ),
            TextAction(
              AmpStrings.safetyTitle,
              onPressed: () => context.push('/safety'),
            ),
          ] else
            TextAction(
              AmpStrings.notificationsTitle,
              onPressed: () => context.push('/notifications'),
            ),
        ],
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceS),
        const SignOutButton(),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.accountDetailsTitle),
        const SizedBox(height: AmpTheme.spaceS),
        _DetailRow(
          label: AmpStrings.accountRole,
          value: _authorityLabel(profile),
        ),
        _DetailRow(
          label: AmpStrings.accountOrganization,
          value: _valueOrDash(profile.organizationName),
        ),
        _DetailRow(label: AmpStrings.accountIdLabel, value: profile.id),
      ],
    );
  }

  static String _authorityLabel(AppUser profile) {
    if (profile.isPlatformAdmin) {
      return AmpStrings.accountAdmin;
    }
    return '${AmpStrings.accountConsumer} + ${AmpStrings.accountHost}';
  }

  static String _valueOrDash(String? value) {
    final String trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? '—' : trimmed;
  }

  static String _initials(String name) {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return '•';
    }
    final StringBuffer initials = StringBuffer();
    for (final String word in words) {
      initials.write(word[0].toUpperCase());
      if (initials.length == 2) {
        break;
      }
    }
    return initials.toString();
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

  static StatusDotTone _verificationTone(String? stored) {
    return switch ((stored ?? '').toUpperCase()) {
      'VERIFIED' => StatusDotTone.available,
      'PENDING' => StatusDotTone.busy,
      _ => StatusDotTone.neutral,
    };
  }
}

class _RoleSwitcher extends ConsumerWidget {
  const _RoleSwitcher({required this.profile, required this.currentRole});

  final AppUser profile;
  final AppRole currentRole;

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final List<AppRole> roles = entitledRolesFor(profile);
    if (roles.length < 2) {
      return;
    }
    final AppRole? selected = await showAmpSheet<AppRole>(
      context: context,
      title: AmpStrings.accountSwitchRoleTitle,
      builder: (BuildContext sheetContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              AmpStrings.accountSwitchRoleBody,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AmpTheme.spaceM),
            for (final AppRole role in roles)
              Padding(
                padding: const EdgeInsets.only(bottom: AmpTheme.spaceXs),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextAction(
                        role.label,
                        underline: role != currentRole,
                        onPressed: () => Navigator.of(sheetContext).pop(role),
                      ),
                    ),
                    if (role == currentRole)
                      Text(
                        AmpStrings.accountCurrentRole,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
    if (selected == null || !context.mounted || selected == currentRole) {
      return;
    }

    await ref.read(activeRoleProvider.notifier).select(selected);
    if (context.mounted) {
      context.go(selected.homePath);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<AppRole> roles = entitledRolesFor(profile);
    if (roles.length < 2) {
      return const SizedBox.shrink();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Eyebrow(AmpStrings.accountActingAs),
              const SizedBox(height: 3),
              StatusDotLabel(currentRole.label, tone: StatusDotTone.neutral),
            ],
          ),
        ),
        TextAction(
          AmpStrings.accountSwitchRole,
          onPressed: () => _choose(context, ref),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: text.bodySmall),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initial});

  final String initial;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final String name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AmpStrings.accountEditNameEmpty);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text(AmpStrings.accountEditNameTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AmpStrings.accountEditNameBody,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          AmpField(
            controller: _controller,
            label: AmpStrings.accountEditNameHint,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            errorText: _error,
            onChanged: (String value) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            onSubmitted: (String value) => _save(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AmpStrings.cancel),
        ),
        TextButton(onPressed: _save, child: const Text(AmpStrings.confirm)),
      ],
    );
  }
}

class _ActiveVehicle extends StatelessWidget {
  const _ActiveVehicle({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String connector = vehicle.connectorType == null
        ? AmpStrings.connectorNotPublished
        : AmpFormat.connectorLabel(vehicle.connectorType);
    final String plate = (vehicle.licensePlate ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(vehicle.displayName, style: text.titleMedium),
        const SizedBox(height: 2),
        Text(
          '$connector · '
          '${vehicle.effectiveCapacityKwh.toStringAsFixed(1)} kWh usable',
          style: text.bodySmall,
        ),
        if (plate.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(plate, style: text.bodySmall),
        ],
      ],
    );
  }
}

class _VehicleNotice extends StatelessWidget {
  const _VehicleNotice({required this.message, this.title});

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null) ...<Widget>[
          Text(title!, style: text.titleSmall),
          const SizedBox(height: 2),
        ],
        Text(message, style: text.bodySmall),
      ],
    );
  }
}

class _BlockedNotice extends StatelessWidget {
  const _BlockedNotice();

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.errorTint,
        borderRadius: BorderRadius.circular(AmpTheme.radiusField),
      ),
      child: Text(
        AmpStrings.blockedBody,
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
        SkeletonLine(widthFactor: 0.2, height: 9),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.5, height: 30),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.68),
        SizedBox(height: AmpTheme.spaceL),
        Hairline(),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.28, height: 9),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.55, height: 22),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.4),
      ],
    );
  }
}

class _VehicleLoading extends StatelessWidget {
  const _VehicleLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SkeletonLine(widthFactor: 0.48, height: 20),
        SizedBox(height: 6),
        SkeletonLine(widthFactor: 0.66),
      ],
    );
  }
}
