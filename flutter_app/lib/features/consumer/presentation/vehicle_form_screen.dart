import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ids.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_chip.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../auth/application/profile_providers.dart';
import '../application/discovery_providers.dart';
import '../application/vehicle_draft.dart';
import '../application/vehicle_providers.dart';

/// Resolves the vehicle and account before opening the editor.
class VehicleFormScreen extends ConsumerWidget {
  const VehicleFormScreen({super.key, this.vehicleId});

  final String? vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<AppUser>> profile = ref.watch(
      currentProfileProvider,
    );
    final AsyncValue<RepositoryResult<List<Vehicle>>> garage = ref.watch(
      vehicleGarageProvider,
    );
    final String title = vehicleId == null
        ? AmpStrings.vehicleAddTitle
        : AmpStrings.vehicleEditTitle;

    if (profile.isLoading || garage.isLoading) {
      return _FormShell(title: title, body: const _FormLoading());
    }
    if (profile.hasError) {
      return _FormShell(
        title: title,
        body: ErrorState(
          message: UserMessages.from(profile.error!),
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
      );
    }
    if (garage.hasError) {
      return _FormShell(
        title: title,
        body: ErrorState(
          message: UserMessages.from(garage.error!),
          onRetry: () => ref.invalidate(vehicleGarageProvider),
        ),
      );
    }

    final RepositoryFailure<AppUser>? profileFailure =
        profile.asData?.value.failureOrNull;
    if (profileFailure != null) {
      return _FormShell(
        title: title,
        body: ErrorState(
          message: profileFailure.message,
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
      );
    }
    final RepositoryFailure<List<Vehicle>>? garageFailure =
        garage.asData?.value.failureOrNull;
    if (garageFailure != null) {
      return _FormShell(
        title: title,
        body: ErrorState(
          message: garageFailure.message,
          onRetry: () => ref.invalidate(vehicleGarageProvider),
        ),
      );
    }

    final AppUser user = profile.asData!.value.valueOrNull!;
    Vehicle? initial;
    if (vehicleId != null) {
      for (final Vehicle vehicle in garage.asData!.value.valueOrNull!) {
        if (vehicle.id == vehicleId) {
          initial = vehicle;
          break;
        }
      }
      if (initial == null) {
        return _FormShell(
          title: title,
          body: ErrorState(
            title: AmpStrings.vehicleNotFoundTitle,
            message: AmpStrings.vehicleNotFoundBody,
            onRetry: () => ref.invalidate(vehicleGarageProvider),
          ),
        );
      }
    }

    return _VehicleForm(
      key: ValueKey<String>(vehicleId ?? 'new'),
      userId: user.id,
      vehicle: initial,
    );
  }
}

class _VehicleForm extends ConsumerStatefulWidget {
  const _VehicleForm({required this.userId, this.vehicle, super.key});

  final String userId;
  final Vehicle? vehicle;

  @override
  ConsumerState<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<_VehicleForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _make;
  late final TextEditingController _model;
  late final TextEditingController _variant;
  late final TextEditingController _year;
  late final TextEditingController _capacity;
  late final TextEditingController _maxAc;
  late final TextEditingController _maxDc;
  late final TextEditingController _efficiency;
  late final TextEditingController _health;
  late final TextEditingController _minArrival;
  late final TextEditingController _maxCharge;
  late final TextEditingController _plate;

  late String _connector;
  late double _efficiencyCorrection;
  bool _saving = false;
  bool _deleting = false;

  bool get _busy => _saving || _deleting;

  @override
  void initState() {
    super.initState();
    final VehicleDraft draft = widget.vehicle == null
        ? VehicleDraft.blank()
        : VehicleDraft.fromVehicle(widget.vehicle!);
    _make = TextEditingController(text: draft.make);
    _model = TextEditingController(text: draft.model);
    _variant = TextEditingController(text: draft.variant);
    _year = TextEditingController(text: draft.year);
    _capacity = TextEditingController(text: draft.capacityKwh);
    _maxAc = TextEditingController(text: draft.maxAcKw);
    _maxDc = TextEditingController(text: draft.maxDcKw);
    _efficiency = TextEditingController(text: draft.efficiencyKmPerKwh);
    _health = TextEditingController(text: draft.healthPercent);
    _minArrival = TextEditingController(text: draft.minArrivalPercent);
    _maxCharge = TextEditingController(text: draft.maxChargePercent);
    _plate = TextEditingController(text: draft.licensePlate);
    _connector = draft.connectorType;
    _efficiencyCorrection = draft.efficiencyCorrectionPercent;

    for (final TextEditingController controller in <TextEditingController>[
      _capacity,
      _efficiency,
      _health,
    ]) {
      controller.addListener(_refreshPreview);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _make,
      _model,
      _variant,
      _year,
      _capacity,
      _maxAc,
      _maxDc,
      _efficiency,
      _health,
      _minArrival,
      _maxCharge,
      _plate,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  VehicleDraft _draft() {
    return VehicleDraft(
      make: _make.text,
      model: _model.text,
      variant: _variant.text,
      year: _year.text,
      capacityKwh: _capacity.text,
      connectorType: _connector,
      maxAcKw: _maxAc.text,
      maxDcKw: _maxDc.text,
      efficiencyKmPerKwh: _efficiency.text,
      healthPercent: _health.text,
      minArrivalPercent: _minArrival.text,
      maxChargePercent: _maxCharge.text,
      licensePlate: _plate.text,
      efficiencyCorrectionPercent: _efficiencyCorrection,
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _saving = true);
    final VehicleRepository? repository = ref.read(vehicleRepositoryProvider);
    if (repository == null) {
      setState(() => _saving = false);
      AmpSnackbar.show(
        context,
        AmpStrings.vehicleSaveFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }

    final Vehicle vehicle = _draft().toVehicle(
      id: widget.vehicle?.id ?? newId('vehicle_'),
      userId: widget.userId,
    );
    final RepositoryResult<List<Vehicle>> result = await repository
        .saveAndActivate(vehicle);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);

    final RepositoryFailure<List<Vehicle>>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
      return;
    }

    _refreshVehicleViews();
    AmpSnackbar.show(
      context,
      AmpStrings.vehicleSaved,
      tone: AmpSnackbarTone.success,
    );
    context.pop();
  }

  Future<void> _confirmDelete() async {
    final Vehicle? vehicle = widget.vehicle;
    if (vehicle == null || _busy) {
      return;
    }
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.vehicleDeleteTitle(vehicle.displayName),
      message: AmpStrings.vehicleDeleteBody,
      confirmLabel: AmpStrings.vehicleDelete,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _deleting = true);
    final VehicleRepository? repository = ref.read(vehicleRepositoryProvider);
    if (repository == null) {
      setState(() => _deleting = false);
      AmpSnackbar.show(
        context,
        AmpStrings.vehicleDeleteFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }

    final RepositoryResult<List<Vehicle>> result = await repository
        .deleteAndPromote(vehicle);
    if (!mounted) {
      return;
    }
    setState(() => _deleting = false);

    final RepositoryFailure<List<Vehicle>>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
      return;
    }

    _refreshVehicleViews();
    AmpSnackbar.show(
      context,
      AmpStrings.vehicleDeleted,
      tone: AmpSnackbarTone.success,
    );
    context.pop();
  }

  void _refreshVehicleViews() {
    ref.invalidate(vehicleGarageProvider);
    ref.invalidate(activeVehicleProvider);
    ref.invalidate(discoveryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final VehicleDraft draft = _draft();
    final bool editing = widget.vehicle != null;

    return AmpScaffold(
      title: editing ? AmpStrings.vehicleEditTitle : AmpStrings.vehicleAddTitle,
      bottomBar: AmpButton(
        label: _saving ? AmpStrings.vehicleSaving : AmpStrings.vehicleSave,
        icon: AmpIconName.check,
        loading: _saving,
        onPressed: _busy ? null : _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AmpTheme.screenPadding,
            AmpTheme.spaceM,
            AmpTheme.screenPadding,
            AmpTheme.spaceXxl,
          ),
          children: <Widget>[
            Text(
              AmpStrings.vehicleFormIntro,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AmpTheme.spaceM),
            _SectionCard(
              title: AmpStrings.vehicleSectionIdentity,
              children: <Widget>[
                AmpField(
                  controller: _make,
                  label: AmpStrings.vehicleMake,
                  textCapitalization: TextCapitalization.words,
                  validator: (String? value) => (value ?? '').trim().isEmpty
                      ? AmpStrings.vehicleMakeRequired
                      : null,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                AmpField(
                  controller: _model,
                  label: AmpStrings.vehicleModel,
                  textCapitalization: TextCapitalization.words,
                  validator: (String? value) => (value ?? '').trim().isEmpty
                      ? AmpStrings.vehicleModelRequired
                      : null,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: AmpField(
                        controller: _variant,
                        label: AmpStrings.vehicleVariant,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: AmpTheme.spaceS),
                    Expanded(
                      child: AmpField(
                        controller: _year,
                        label: AmpStrings.vehicleYear,
                        keyboardType: TextInputType.number,
                        validator: VehicleDraft.validateYear,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AmpTheme.spaceS),
                AmpField(
                  controller: _plate,
                  label: AmpStrings.vehiclePlate,
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            const SizedBox(height: AmpTheme.spaceM),
            _SectionCard(
              title: AmpStrings.vehicleSectionBattery,
              children: <Widget>[
                AmpField(
                  controller: _capacity,
                  label: AmpStrings.vehicleCapacity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: VehicleDraft.validateCapacity,
                  onChanged: (_) => _refreshPreview(),
                ),
                const SizedBox(height: AmpTheme.spaceM),
                Text(
                  AmpStrings.vehicleConnector,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                Wrap(
                  spacing: AmpTheme.spaceS,
                  runSpacing: AmpTheme.spaceS,
                  children: <Widget>[
                    for (final String connector in VehicleDraft.connectors)
                      AmpChip(
                        label: AmpFormat.connectorLabel(connector),
                        selected: _connector == connector,
                        onTap: () => setState(() => _connector = connector),
                      ),
                  ],
                ),
                const SizedBox(height: AmpTheme.spaceM),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: AmpField(
                        controller: _maxAc,
                        label: AmpStrings.vehicleMaxAc,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: VehicleDraft.validateMaxAc,
                      ),
                    ),
                    const SizedBox(width: AmpTheme.spaceS),
                    Expanded(
                      child: AmpField(
                        controller: _maxDc,
                        label: AmpStrings.vehicleMaxDc,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: VehicleDraft.validateMaxDc,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AmpTheme.spaceS),
                AmpField(
                  controller: _efficiency,
                  label: AmpStrings.vehicleEfficiency,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: VehicleDraft.validateEfficiency,
                  onChanged: (_) => _refreshPreview(),
                ),
                const SizedBox(height: AmpTheme.spaceS),
                AmpField(
                  controller: _health,
                  label: AmpStrings.vehicleHealth,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: VehicleDraft.validateHealth,
                  onChanged: (_) => _refreshPreview(),
                ),
              ],
            ),
            const SizedBox(height: AmpTheme.spaceM),
            _SectionCard(
              title: AmpStrings.vehicleSectionPreferences,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: AmpField(
                        controller: _minArrival,
                        label: AmpStrings.vehicleMinArrival,
                        keyboardType: TextInputType.number,
                        validator: VehicleDraft.validateMinArrival,
                      ),
                    ),
                    const SizedBox(width: AmpTheme.spaceS),
                    Expanded(
                      child: AmpField(
                        controller: _maxCharge,
                        label: AmpStrings.vehicleMaxCharge,
                        keyboardType: TextInputType.number,
                        validator: (String? value) {
                          final String? basic = VehicleDraft.validateMaxCharge(
                            value,
                          );
                          if (basic != null) {
                            return basic;
                          }
                          return VehicleDraft.validateSocOrder(
                            _minArrival.text,
                            value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AmpTheme.spaceM),
            Container(
              padding: const EdgeInsets.all(AmpTheme.spaceM),
              decoration: BoxDecoration(
                color: context.amp.surfaceVariant,
                borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AmpIcon(AmpIconName.info, size: 19, color: context.amp.info),
                  const SizedBox(width: AmpTheme.spaceS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AmpStrings.vehiclePlanningPreview(
                            draft.usableCapacityKwh,
                            draft.rangeKm.round(),
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.amp.ink),
                        ),
                        const SizedBox(height: AmpTheme.spaceXs),
                        Text(
                          AmpStrings.vehiclePlanningNote,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (editing) ...<Widget>[
              const SizedBox(height: AmpTheme.spaceL),
              AmpButton(
                label: AmpStrings.vehicleDelete,
                variant: AmpButtonVariant.danger,
                icon: AmpIconName.close,
                loading: _deleting,
                onPressed: _busy ? null : _confirmDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: context.amp.surface,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: context.amp.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AmpTheme.spaceM),
          ...children,
        ],
      ),
    );
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return AmpScaffold(title: title, body: body);
  }
}

class _FormLoading extends StatelessWidget {
  const _FormLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        Skeleton(height: 220, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 280, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
