import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ids.dart';
import '../../../core/ui/input_formatters.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/big_number.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/text_filter_row.dart';
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
  bool _allowPop = false;

  bool get _busy => _saving || _deleting;

  bool get _hasUnsavedChanges {
    final VehicleDraft initial = widget.vehicle == null
        ? VehicleDraft.blank()
        : VehicleDraft.fromVehicle(widget.vehicle!);
    final VehicleDraft current = _draft();
    return current.make != initial.make ||
        current.model != initial.model ||
        current.variant != initial.variant ||
        current.year != initial.year ||
        current.capacityKwh != initial.capacityKwh ||
        current.connectorType != initial.connectorType ||
        current.maxAcKw != initial.maxAcKw ||
        current.maxDcKw != initial.maxDcKw ||
        current.efficiencyKmPerKwh != initial.efficiencyKmPerKwh ||
        current.healthPercent != initial.healthPercent ||
        current.minArrivalPercent != initial.minArrivalPercent ||
        current.maxChargePercent != initial.maxChargePercent ||
        current.licensePlate != initial.licensePlate;
  }

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

    // Every field feeds the discard guard, not only the battery preview. The
    // listener must rebuild so PopScope sees the dirty state before Back.
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
    _closeForm();
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
    _closeForm();
  }

  void _refreshVehicleViews() {
    ref.invalidate(vehicleGarageProvider);
    ref.invalidate(activeVehicleProvider);
    ref.invalidate(discoveryProvider);
  }

  void _closeForm() {
    if (!mounted) {
      return;
    }
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.pop();
      }
    });
  }

  Future<void> _confirmDiscard() async {
    if (!_hasUnsavedChanges) {
      return;
    }
    final bool discard = await showAmpConfirmDialog(
      context,
      title: AmpStrings.vehicleUnsavedTitle,
      message: AmpStrings.vehicleUnsavedBody,
      confirmLabel: AmpStrings.vehicleDiscard,
      cancelLabel: AmpStrings.vehicleKeepEditing,
    );
    if (!discard || !mounted) {
      return;
    }
    _closeForm();
  }

  @override
  Widget build(BuildContext context) {
    final VehicleDraft draft = _draft();
    final bool editing = widget.vehicle != null;

    final Widget scaffold = AmpScaffold(
      title: editing ? AmpStrings.vehicleEditTitle : AmpStrings.vehicleAddTitle,
      bottomBar: AmpButton(
        label: _saving ? AmpStrings.vehicleSaving : AmpStrings.vehicleSave,
        loading: _saving,
        onPressed: _busy ? null : _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  textInputAction: TextInputAction.next,
                  maxLength: 40,
                  validator: (String? value) => (value ?? '').trim().isEmpty
                      ? AmpStrings.vehicleMakeRequired
                      : null,
                ),
                const SizedBox(height: AmpTheme.spaceS),
                AmpField(
                  controller: _model,
                  label: AmpStrings.vehicleModel,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 40,
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
                        textInputAction: TextInputAction.next,
                        maxLength: 40,
                      ),
                    ),
                    const SizedBox(width: AmpTheme.spaceS),
                    Expanded(
                      child: AmpField(
                        controller: _year,
                        label: AmpStrings.vehicleYear,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: <TextInputFormatter>[
                          AmpInputFormatters.digits,
                        ],
                        maxLength: 4,
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
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    AmpInputFormatters.registration,
                  ],
                  maxLength: 15,
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
                  textInputAction: TextInputAction.next,
                  inputFormatters: AmpInputFormatters.decimal,
                  maxLength: 7,
                  validator: VehicleDraft.validateCapacity,
                  onChanged: (_) => _refreshPreview(),
                ),
                const SizedBox(height: AmpTheme.spaceM),
                Eyebrow(AmpStrings.vehicleConnector),
                const SizedBox(height: 2),
                TextFilterRow<String>(
                  options: <TextFilterOption<String>>[
                    for (final String connector in VehicleDraft.connectors)
                      TextFilterOption<String>(
                        value: connector,
                        label: AmpFormat.connectorLabel(connector),
                      ),
                  ],
                  selected: _connector,
                  onSelected: (String value) =>
                      setState(() => _connector = value),
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
                        textInputAction: TextInputAction.next,
                        inputFormatters: AmpInputFormatters.decimal,
                        maxLength: 7,
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
                        textInputAction: TextInputAction.next,
                        inputFormatters: AmpInputFormatters.decimal,
                        maxLength: 7,
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
                  textInputAction: TextInputAction.next,
                  inputFormatters: AmpInputFormatters.decimal,
                  maxLength: 6,
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
                  textInputAction: TextInputAction.next,
                  inputFormatters: AmpInputFormatters.decimal,
                  maxLength: 5,
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
                        textInputAction: TextInputAction.next,
                        inputFormatters: <TextInputFormatter>[
                          AmpInputFormatters.digits,
                        ],
                        maxLength: 3,
                        validator: VehicleDraft.validateMinArrival,
                      ),
                    ),
                    const SizedBox(width: AmpTheme.spaceS),
                    Expanded(
                      child: AmpField(
                        controller: _maxCharge,
                        label: AmpStrings.vehicleMaxCharge,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: <TextInputFormatter>[
                          AmpInputFormatters.digits,
                        ],
                        maxLength: 3,
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
            const Hairline(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AmpTheme.spaceM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BigNumber(
                    value: draft.usableCapacityKwh.toStringAsFixed(1),
                    unit: AmpStrings.kwh,
                    label: AmpStrings.vehicleUsableLabel,
                    size: 48,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AmpStrings.vehicleRangeNote(draft.rangeKm.round()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AmpStrings.vehiclePlanningNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Hairline(),
            if (editing) ...<Widget>[
              const SizedBox(height: AmpTheme.spaceL),
              AmpButton(
                label: AmpStrings.vehicleDelete,
                variant: AmpButtonVariant.danger,
                loading: _deleting,
                onPressed: _busy ? null : _confirmDelete,
              ),
            ],
          ],
        ),
      ),
    );

    return PopScope<Object?>(
      canPop: !_hasUnsavedChanges || _allowPop,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        unawaited(_confirmDiscard());
      },
      child: scaffold,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Hairline(),
        Padding(
          padding: const EdgeInsets.only(
            top: AmpTheme.spaceM,
            bottom: AmpTheme.spaceS,
          ),
          child: Eyebrow(title),
        ),
        ...children,
        const SizedBox(height: AmpTheme.spaceM),
        const Hairline(),
      ],
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
        SkeletonLine(widthFactor: 0.3, height: 9),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.6, height: 28),
        SizedBox(height: AmpTheme.spaceL),
        Hairline(),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.45),
        SizedBox(height: 14),
        SkeletonLine(widthFactor: 0.8),
        SizedBox(height: 14),
        SkeletonLine(widthFactor: 0.72),
        SizedBox(height: AmpTheme.spaceM),
        Hairline(),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.42),
        SizedBox(height: 14),
        SkeletonLine(widthFactor: 0.76),
      ],
    );
  }
}
