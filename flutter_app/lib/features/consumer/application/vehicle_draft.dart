import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';

/// The editable values of one vehicle and the rules that keep them usable.
///
/// This is deliberately independent of widgets: the form, the derived range
/// preview and the tests all use the same parsing and bounds.
final class VehicleDraft {
  const VehicleDraft({
    this.make = '',
    this.model = '',
    this.variant = '',
    this.year = '',
    this.capacityKwh = '',
    this.connectorType = 'TYPE_2_AC',
    this.maxAcKw = '',
    this.maxDcKw = '',
    this.efficiencyKmPerKwh = '',
    this.healthPercent = '',
    this.minArrivalPercent = '',
    this.maxChargePercent = '',
    this.licensePlate = '',
    this.efficiencyCorrectionPercent = 0,
  });

  factory VehicleDraft.blank({int? currentYear}) {
    final int year = currentYear ?? DateTime.now().year;
    return VehicleDraft(
      year: '$year',
      capacityKwh: '40.5',
      maxAcKw: '7.2',
      maxDcKw: '30',
      efficiencyKmPerKwh: '6.5',
      healthPercent: VehiclePlanning.defaultHealthForYear(
        year,
        currentYear: currentYear,
      ).toStringAsFixed(0),
      minArrivalPercent: '15',
      maxChargePercent: '80',
    );
  }

  factory VehicleDraft.fromVehicle(Vehicle vehicle, {int? currentYear}) {
    final int year = vehicle.purchaseYear > 0
        ? vehicle.purchaseYear
        : (currentYear ?? DateTime.now().year);
    String decimal(double value, String fallback) =>
        value > 0 ? value.toStringAsFixed(1) : fallback;
    String whole(num value, String fallback) =>
        value > 0 ? value.toStringAsFixed(0) : fallback;

    return VehicleDraft(
      make: vehicle.make ?? '',
      model: vehicle.model ?? '',
      variant: vehicle.variant ?? '',
      year: '$year',
      capacityKwh: decimal(vehicle.batteryCapacityKwh, '40.5'),
      connectorType: vehicle.connectorType ?? 'TYPE_2_AC',
      maxAcKw: decimal(vehicle.maxAcKw, '7.2'),
      maxDcKw: decimal(vehicle.maxDcKw, '30'),
      efficiencyKmPerKwh: decimal(vehicle.typicalEfficiencyKmPerKwh, '6.5'),
      healthPercent: whole(
        vehicle.batteryHealthPercent,
        VehiclePlanning.defaultHealthForYear(
          year,
          currentYear: currentYear,
        ).toStringAsFixed(0),
      ),
      minArrivalPercent: whole(vehicle.minArrivalSocPercent, '15'),
      maxChargePercent: whole(vehicle.maxChargeSocPercent, '80'),
      licensePlate: vehicle.licensePlate ?? '',
      efficiencyCorrectionPercent: vehicle.efficiencyCorrectionPercent,
    );
  }

  static const List<String> connectors = <String>[
    'TYPE_2_AC',
    'CCS_2_DC',
    'GB_T',
    'CHADEMO',
  ];

  final String make;
  final String model;
  final String variant;
  final String year;
  final String capacityKwh;
  final String connectorType;
  final String maxAcKw;
  final String maxDcKw;
  final String efficiencyKmPerKwh;
  final String healthPercent;
  final String minArrivalPercent;
  final String maxChargePercent;
  final String licensePlate;
  final double efficiencyCorrectionPercent;

  String? get makeError =>
      make.trim().isEmpty ? AmpStrings.vehicleMakeRequired : null;

  String? get modelError =>
      model.trim().isEmpty ? AmpStrings.vehicleModelRequired : null;

  String? get yearError => validateYear(year);

  String? get capacityError => validateCapacity(capacityKwh);

  String? get maxAcError => validateMaxAc(maxAcKw);

  String? get maxDcError => validateMaxDc(maxDcKw);

  String? get efficiencyError => validateEfficiency(efficiencyKmPerKwh);

  String? get healthError => validateHealth(healthPercent);

  String? get minArrivalError => validateMinArrival(minArrivalPercent);

  String? get maxChargeError => validateMaxCharge(maxChargePercent);

  String? get socOrderError =>
      validateSocOrder(minArrivalPercent, maxChargePercent);

  bool get isValid =>
      makeError == null &&
      modelError == null &&
      yearError == null &&
      capacityError == null &&
      maxAcError == null &&
      maxDcError == null &&
      efficiencyError == null &&
      healthError == null &&
      minArrivalError == null &&
      maxChargeError == null &&
      socOrderError == null;

  double get usableCapacityKwh {
    final double capacity = double.tryParse(capacityKwh.trim()) ?? 40.5;
    final double health = double.tryParse(healthPercent.trim()) ?? 100;
    return (capacity * (health.clamp(1, 100) / 100)).clamp(1, 200).toDouble();
  }

  double get rangeKm {
    final double efficiency = double.tryParse(efficiencyKmPerKwh.trim()) ?? 6.5;
    return (usableCapacityKwh * efficiency.clamp(1, 20)).toDouble();
  }

  Vehicle toVehicle({required String id, required String userId}) {
    final int parsedYear = int.tryParse(year.trim()) ?? DateTime.now().year;
    final int minArrival = int.tryParse(minArrivalPercent.trim()) ?? 15;
    final int maxCharge = int.tryParse(maxChargePercent.trim()) ?? 80;
    final String plate = licensePlate.trim();

    return Vehicle(
      id: id,
      userId: userId,
      make: make.trim(),
      model: model.trim(),
      variant: variant.trim().isEmpty ? null : variant.trim(),
      purchaseYear: parsedYear,
      batteryCapacityKwh: double.tryParse(capacityKwh.trim()) ?? 40.5,
      connectorType: connectorType,
      maxAcKw: double.tryParse(maxAcKw.trim()) ?? 7.2,
      maxDcKw: double.tryParse(maxDcKw.trim()) ?? 30,
      typicalEfficiencyKmPerKwh:
          double.tryParse(efficiencyKmPerKwh.trim()) ?? 6.5,
      batteryHealthPercent:
          double.tryParse(healthPercent.trim()) ??
          VehiclePlanning.defaultHealthForYear(parsedYear),
      efficiencyCorrectionPercent: efficiencyCorrectionPercent,
      minArrivalSocPercent: minArrival.clamp(5, 40).toInt(),
      maxChargeSocPercent: maxCharge.clamp(50, 100).toInt(),
      licensePlate: plate.isEmpty ? null : plate,
      isActive: true,
    );
  }

  static String? validateYear(String? value, {int? currentYear}) {
    final int? parsed = int.tryParse((value ?? '').trim());
    final int nextYear = (currentYear ?? DateTime.now().year) + 1;
    if (parsed == null || parsed < 1980 || parsed > nextYear) {
      return AmpStrings.vehicleYearInvalid;
    }
    return null;
  }

  static String? validateCapacity(String? value) {
    return _validateNumber(
      value,
      min: 1,
      max: 200,
      message: AmpStrings.vehicleCapacityInvalid,
    );
  }

  static String? validateMaxAc(String? value) {
    return _validateNumber(
      value,
      min: 0,
      max: 50,
      message: AmpStrings.vehicleMaxAcInvalid,
      allowZero: true,
    );
  }

  static String? validateMaxDc(String? value) {
    return _validateNumber(
      value,
      min: 0,
      max: 500,
      message: AmpStrings.vehicleMaxDcInvalid,
      allowZero: true,
    );
  }

  static String? validateEfficiency(String? value) {
    return _validateNumber(
      value,
      min: 1,
      max: 20,
      message: AmpStrings.vehicleEfficiencyInvalid,
    );
  }

  static String? validateHealth(String? value) {
    return _validateNumber(
      value,
      min: 1,
      max: 100,
      message: AmpStrings.vehicleHealthInvalid,
    );
  }

  static String? validateMinArrival(String? value) {
    final int? parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 5 || parsed > 40) {
      return AmpStrings.vehicleMinArrivalInvalid;
    }
    return null;
  }

  static String? validateMaxCharge(String? value) {
    final int? parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 50 || parsed > 100) {
      return AmpStrings.vehicleMaxChargeInvalid;
    }
    return null;
  }

  static String? validateSocOrder(String? minArrival, String? maxCharge) {
    final int? minimum = int.tryParse((minArrival ?? '').trim());
    final int? maximum = int.tryParse((maxCharge ?? '').trim());
    if (minimum != null && maximum != null && minimum >= maximum) {
      return AmpStrings.vehicleSocOrder;
    }
    return null;
  }

  static String? _validateNumber(
    String? value, {
    required double min,
    required double max,
    required String message,
    bool allowZero = false,
  }) {
    final double? parsed = double.tryParse((value ?? '').trim());
    if (parsed == null ||
        parsed < min ||
        parsed > max ||
        (!allowZero && parsed <= 0)) {
      return message;
    }
    return null;
  }
}
