import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/location/device_location.dart';
import '../../../core/location/location_flow.dart';
import '../../../core/ui/input_formatters.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../core/widgets/unsaved_changes_guard.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/host_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/policy.dart';
import '../../auth/application/profile_providers.dart';
import '../../consumer/application/trip_providers.dart';
import '../application/host_providers.dart';

/// Submits a new charger with its ports and seven-day availability windows.
/// The platform fees are fixed here, never read from the form.
class HostStationFormScreen extends ConsumerStatefulWidget {
  const HostStationFormScreen({super.key});

  @override
  ConsumerState<HostStationFormScreen> createState() =>
      _HostStationFormScreenState();
}

class _HostStationFormScreenState extends ConsumerState<HostStationFormScreen> {
  static const List<String> _locationCodes = <String>[
    'CAMPUS',
    'APARTMENT',
    'OFFICE',
    'CAFE',
    'HOTEL',
    'PARKING',
    'PETROL_PUMP',
    'COMMERCIAL',
  ];
  static const List<String> _locationLabels = <String>[
    'Campus',
    'Apartment',
    'Office',
    'Café',
    'Hotel',
    'Parking',
    'Petrol pump',
    'Commercial',
  ];
  static const List<String> _connectors = <String>[
    'TYPE_2_AC',
    'CCS_2_DC',
    'GB_T',
    'CHADEMO',
  ];

  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _longitude = TextEditingController();
  final TextEditingController _hours = TextEditingController(
    text: '08:00 - 20:00',
  );
  final TextEditingController _price = TextEditingController(
    text: AmpPolicy.fallbackTariffInrPerKwh.toStringAsFixed(0),
  );
  final TextEditingController _access = TextEditingController(
    text: AmpStrings.hostAccessHint,
  );
  final List<_PortFields> _ports = <_PortFields>[
    _PortFields(connector: _connectors.first),
  ];

  String _locationType = _locationCodes.first;
  String _meterLevel = AmpPolicy.level1VerifiedManual;
  bool _busy = false;
  bool _locating = false;
  bool _dirty = false;
  String? _locationMessage;
  bool _locationNeedsSettings = false;

  @override
  void initState() {
    super.initState();
    // Check silently on open. The system prompt only appears after the person
    // taps Use my current location and sees the explanation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useLocation(explainFirst: false);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _hours.dispose();
    _price.dispose();
    _access.dispose();
    for (final _PortFields port in _ports) {
      port.dispose();
    }
    super.dispose();
  }

  Future<void> _useLocation({bool explainFirst = true}) async {
    if (_locating) {
      return;
    }
    setState(() {
      _locating = true;
      _locationMessage = null;
      _locationNeedsSettings = false;
    });
    final DeviceLocationFix fix = await requestDeviceLocation(
      context,
      ref.read(deviceLocationServiceProvider),
      explainFirst: explainFirst,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _locating = false;
      if (fix.hasPosition) {
        _latitude.text = fix.latitude.toStringAsFixed(5);
        _longitude.text = fix.longitude.toStringAsFixed(5);
        if (explainFirst) {
          _dirty = true;
        }
        return;
      }
      _locationMessage = switch (fix.status) {
        DeviceLocationStatus.permissionDeniedForever =>
          AmpStrings.locationPermissionForever,
        DeviceLocationStatus.permissionDenied =>
          AmpStrings.locationPermissionOff,
        DeviceLocationStatus.servicesDisabled => AmpStrings.locationServicesOff,
        DeviceLocationStatus.unavailable ||
        DeviceLocationStatus.found => AmpStrings.hostLocationFailed,
      };
      _locationNeedsSettings =
          fix.status == DeviceLocationStatus.permissionDeniedForever;
    });
  }

  Future<void> _openLocationSettings() async {
    await ref.read(deviceLocationServiceProvider).openSettings();
  }

  void _addPort() {
    setState(() {
      _dirty = true;
      _ports.add(
        _PortFields(connector: _connectors[_ports.length % _connectors.length]),
      );
    });
  }

  void _removePort(_PortFields port) {
    if (_ports.length <= 1) {
      return;
    }
    setState(() {
      _dirty = true;
      _ports.remove(port);
      port.dispose();
    });
  }

  Future<void> _save() async {
    if (_busy) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }
    final List<HostPortDraft> ports = <HostPortDraft>[];
    for (final _PortFields row in _ports) {
      final int? count = int.tryParse(row.count.text.trim());
      final double? power = double.tryParse(row.power.text.trim());
      if (count == null || count < 1 || power == null || power <= 0) {
        return;
      }
      ports.add(
        HostPortDraft(
          connectorType: row.connector,
          count: count,
          powerKw: power,
          isDc: row.isDc,
        ),
      );
    }

    final double? price = double.tryParse(_price.text.trim());
    if (price == null || price <= 0) {
      return;
    }

    final HostRepository? repository = ref.read(hostRepositoryProvider);
    if (repository == null) {
      AmpSnackbar.show(
        context,
        AmpStrings.hostStationSaveFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    setState(() => _busy = true);
    final RepositoryResult<AppUser> profile = await ref.read(
      currentProfileProvider.future,
    );
    if (!mounted) {
      return;
    }
    final AppUser? host = profile.valueOrNull;
    if (host == null) {
      setState(() => _busy = false);
      AmpSnackbar.show(
        context,
        UserMessages.from(
          profile.failureOrNull?.cause ?? StateError('profile'),
        ),
        tone: AmpSnackbarTone.error,
      );
      return;
    }

    final RepositoryResult<String> result = await repository.saveStation(
      host: host,
      draft: HostStationDraft(
        name: _name.text.trim(),
        address: _address.text.trim(),
        latitude: double.parse(_latitude.text.trim()),
        longitude: double.parse(_longitude.text.trim()),
        locationType: _locationType,
        operatingHours: _hours.text.trim(),
        pricePerKwh: price,
        verificationLevel: _meterLevel,
        accessRules: _access.text.trim(),
        ports: ports,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    final RepositoryFailure<String>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
      return;
    }
    ref.invalidate(hostWorkspaceProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.hostStationSaved,
      tone: AmpSnackbarTone.success,
    );
    setState(() => _dirty = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.pop();
      }
    });
  }

  String? _priceValidator(String? value) {
    final double? price = double.tryParse((value ?? '').trim());
    return price == null || price <= 0 ? AmpStrings.hostPriceInvalid : null;
  }

  String? _coordinateValidator(String? value) {
    final double? coordinate = double.tryParse((value ?? '').trim());
    if (coordinate == null || coordinate == 0) {
      return AmpStrings.hostLocationRequired;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return AmpUnsavedChangesGuard(
      hasUnsavedChanges: _dirty,
      onDiscard: () {
        if (mounted) {
          context.pop();
        }
      },
      title: AmpStrings.hostUnsavedTitle,
      message: AmpStrings.hostUnsavedBody,
      keepLabel: AmpStrings.unsavedKeepEditing,
      discardLabel: AmpStrings.hostDiscard,
      child: AmpScaffold(
        title: AmpStrings.hostStationFormTitle,
        subtitle: AmpStrings.hostStationFormSubtitle,
        body: Form(
          key: _form,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AmpTheme.screenPadding,
              AmpTheme.spaceM,
              AmpTheme.screenPadding,
              AmpTheme.spaceXxl + 88,
            ),
            children: <Widget>[
              Text(AmpStrings.hostStationIntro, style: text.bodySmall),
              const SizedBox(height: AmpTheme.spaceL),
              AmpField(
                controller: _name,
                label: AmpStrings.hostStationName,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                validator: (String? value) => (value ?? '').trim().isEmpty
                    ? AmpStrings.hostNameRequired
                    : null,
                onChanged: (_) => setState(() => _dirty = true),
              ),
              const SizedBox(height: AmpTheme.spaceM),
              AmpField(
                controller: _address,
                label: AmpStrings.hostStationAddress,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLines: 2,
                maxLength: 200,
                validator: (String? value) => (value ?? '').trim().isEmpty
                    ? AmpStrings.hostAddressRequired
                    : null,
                onChanged: (_) => setState(() => _dirty = true),
              ),
              const SizedBox(height: AmpTheme.spaceM),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: AmpField(
                      controller: _latitude,
                      label: AmpStrings.hostStationLatitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.next,
                      inputFormatters: AmpInputFormatters.decimal,
                      maxLength: 12,
                      validator: _coordinateValidator,
                      onChanged: (_) => setState(() => _dirty = true),
                    ),
                  ),
                  const SizedBox(width: AmpTheme.spaceS),
                  Expanded(
                    child: AmpField(
                      controller: _longitude,
                      label: AmpStrings.hostStationLongitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.next,
                      inputFormatters: AmpInputFormatters.decimal,
                      maxLength: 12,
                      validator: _coordinateValidator,
                      onChanged: (_) => setState(() => _dirty = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AmpTheme.spaceS),
              AmpButton(
                label: _locating
                    ? AmpStrings.hostLocating
                    : AmpStrings.hostUseCurrentLocation,
                variant: AmpButtonVariant.tonal,
                loading: _locating,
                onPressed: _locating ? null : _useLocation,
              ),
              if (_locationMessage != null) ...<Widget>[
                const SizedBox(height: AmpTheme.spaceS),
                Text(_locationMessage!, style: text.bodySmall),
                if (_locationNeedsSettings)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextAction(
                      AmpStrings.locationPermissionOpenSettings,
                      onPressed: _openLocationSettings,
                    ),
                  ),
              ],
              const SizedBox(height: AmpTheme.spaceL),
              const Hairline(),
              const SizedBox(height: AmpTheme.spaceL),
              const Eyebrow(AmpStrings.hostLocationType),
              const SizedBox(height: AmpTheme.spaceS),
              TextFilterRow<String>(
                options: <TextFilterOption<String>>[
                  for (int index = 0; index < _locationCodes.length; index++)
                    TextFilterOption<String>(
                      value: _locationCodes[index],
                      label: _locationLabels[index],
                    ),
                ],
                selected: _locationType,
                onSelected: (String value) => setState(() {
                  _locationType = value;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: AmpTheme.spaceL),
              const Eyebrow(AmpStrings.hostMeterLevel),
              const SizedBox(height: AmpTheme.spaceS),
              TextFilterRow<String>(
                options: const <TextFilterOption<String>>[
                  TextFilterOption<String>(
                    value: AmpPolicy.level1VerifiedManual,
                    label: AmpStrings.hostMeterLevel1,
                  ),
                  TextFilterOption<String>(
                    value: AmpPolicy.level2SimulatedSmartMeter,
                    label: AmpStrings.hostMeterLevel2,
                  ),
                  TextFilterOption<String>(
                    value: AmpPolicy.level3NoVerifiedMeter,
                    label: AmpStrings.hostMeterLevel3,
                  ),
                ],
                selected: _meterLevel,
                onSelected: (String value) => setState(() {
                  _meterLevel = value;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: AmpTheme.spaceL),
              const Hairline(),
              const SizedBox(height: AmpTheme.spaceL),
              AmpField(
                controller: _hours,
                label: AmpStrings.hostOperatingHours,
                hint: '08:00 - 20:00',
                textInputAction: TextInputAction.next,
                maxLength: 40,
                validator: (String? value) => (value ?? '').trim().isEmpty
                    ? AmpStrings.hostHoursRequired
                    : null,
                onChanged: (_) => setState(() => _dirty = true),
              ),
              const SizedBox(height: AmpTheme.spaceM),
              AmpField(
                controller: _price,
                label: AmpStrings.hostPriceLabel,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: AmpInputFormatters.decimal,
                maxLength: 6,
                validator: _priceValidator,
                onChanged: (_) => setState(() => _dirty = true),
              ),
              const SizedBox(height: AmpTheme.spaceM),
              AmpField(
                controller: _access,
                label: AmpStrings.hostAccessRules,
                maxLines: 3,
                maxLength: 300,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() => _dirty = true),
              ),
              const SizedBox(height: AmpTheme.spaceS),
              Text(AmpStrings.hostPlatformFees, style: text.bodySmall),
              const SizedBox(height: AmpTheme.spaceL),
              const Hairline(),
              const SizedBox(height: AmpTheme.spaceL),
              const Eyebrow(AmpStrings.hostPortsTitle),
              const SizedBox(height: 4),
              Text(AmpStrings.hostPortsBody, style: text.bodySmall),
              const SizedBox(height: AmpTheme.spaceM),
              for (int index = 0; index < _ports.length; index++) ...<Widget>[
                _PortEditor(
                  fields: _ports[index],
                  connectors: _connectors,
                  onChanged: () => setState(() => _dirty = true),
                  onRemove: _ports.length > 1
                      ? () => _removePort(_ports[index])
                      : null,
                ),
                if (index < _ports.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AmpTheme.spaceS),
                    child: Hairline(),
                  ),
              ],
              const SizedBox(height: AmpTheme.spaceS),
              TextAction(AmpStrings.hostAddPortType, onPressed: _addPort),
            ],
          ),
        ),
        bottomBar: AmpButton(
          label: _busy
              ? AmpStrings.hostSavingStation
              : AmpStrings.hostSaveStation,
          loading: _busy,
          onPressed: _busy ? null : _save,
        ),
      ),
    );
  }
}

class _PortFields {
  _PortFields({required this.connector})
    : count = TextEditingController(text: '1'),
      power = TextEditingController(text: '7.2');

  String connector;
  bool isDc = false;
  final TextEditingController count;
  final TextEditingController power;

  void dispose() {
    count.dispose();
    power.dispose();
  }
}

class _PortEditor extends StatelessWidget {
  const _PortEditor({
    required this.fields,
    required this.connectors,
    required this.onChanged,
    this.onRemove,
  });

  final _PortFields fields;
  final List<String> connectors;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFilterRow<String>(
          options: <TextFilterOption<String>>[
            for (final String code in connectors)
              TextFilterOption<String>(
                value: code,
                label: code == 'TYPE_2_AC'
                    ? 'Type 2 AC'
                    : code == 'CCS_2_DC'
                    ? 'CCS2 DC'
                    : code == 'GB_T'
                    ? 'GB/T'
                    : 'CHAdeMO',
              ),
          ],
          selected: fields.connector,
          onSelected: (String value) {
            fields.connector = value;
            onChanged();
          },
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: AmpField(
                controller: fields.count,
                label: AmpStrings.hostPortCountLabel,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: <TextInputFormatter>[
                  AmpInputFormatters.digits,
                ],
                maxLength: 2,
                validator: (String? value) {
                  final int? count = int.tryParse((value ?? '').trim());
                  return count == null || count < 1
                      ? AmpStrings.hostPortCountInvalid
                      : null;
                },
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: AmpTheme.spaceS),
            Expanded(
              child: AmpField(
                controller: fields.power,
                label: AmpStrings.hostPowerLabel,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: AmpInputFormatters.decimal,
                maxLength: 5,
                validator: (String? value) {
                  final double? power = double.tryParse((value ?? '').trim());
                  return power == null || power <= 0
                      ? AmpStrings.hostPortPowerInvalid
                      : null;
                },
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Row(
          children: <Widget>[
            const Eyebrow(AmpStrings.hostCurrentTypeLabel),
            const SizedBox(width: AmpTheme.spaceM),
            Expanded(
              child: TextFilterRow<bool>(
                options: const <TextFilterOption<bool>>[
                  TextFilterOption<bool>(
                    value: false,
                    label: AmpStrings.hostAcLabel,
                  ),
                  TextFilterOption<bool>(
                    value: true,
                    label: AmpStrings.hostDcLabel,
                  ),
                ],
                selected: fields.isDc,
                onSelected: (bool value) {
                  fields.isDc = value;
                  onChanged();
                },
              ),
            ),
          ],
        ),
        if (onRemove != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onRemove,
              child: const Text(AmpStrings.hostRemovePortType),
            ),
          ),
      ],
    );
  }
}
