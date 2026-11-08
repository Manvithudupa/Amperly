import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/features/consumer/application/vehicle_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VehicleDraft', () {
    test('requires both parts of the vehicle name', () {
      const VehicleDraft draft = VehicleDraft();

      expect(draft.makeError, AmpStrings.vehicleMakeRequired);
      expect(draft.modelError, AmpStrings.vehicleModelRequired);
      expect(draft.isValid, isFalse);
    });

    test(
      'rejects years, numbers and state-of-charge limits outside the rules',
      () {
        final VehicleDraft draft = VehicleDraft(
          make: 'Tata',
          model: 'Nexon EV',
          year: '2028',
          capacityKwh: '0',
          maxAcKw: '51',
          maxDcKw: '501',
          efficiencyKmPerKwh: '0',
          healthPercent: '0',
          minArrivalPercent: '15',
          maxChargePercent: '80',
        );

        expect(
          VehicleDraft.validateYear('2028', currentYear: 2026),
          AmpStrings.vehicleYearInvalid,
        );
        expect(draft.capacityError, AmpStrings.vehicleCapacityInvalid);
        expect(draft.maxAcError, AmpStrings.vehicleMaxAcInvalid);
        expect(draft.maxDcError, AmpStrings.vehicleMaxDcInvalid);
        expect(draft.efficiencyError, AmpStrings.vehicleEfficiencyInvalid);
        expect(draft.healthError, AmpStrings.vehicleHealthInvalid);
        expect(draft.minArrivalError, isNull);
        expect(draft.maxChargeError, isNull);
        expect(draft.socOrderError, isNull);
        expect(
          VehicleDraft.validateSocOrder('80', '50'),
          AmpStrings.vehicleSocOrder,
        );
        expect(draft.isValid, isFalse);
      },
    );

    test('builds a valid active vehicle from the entered figures', () {
      const VehicleDraft draft = VehicleDraft(
        make: 'Tata',
        model: 'Nexon EV',
        variant: 'Empowered+',
        year: '2024',
        capacityKwh: '40.5',
        connectorType: 'CCS_2_DC',
        maxAcKw: '7.2',
        maxDcKw: '50',
        efficiencyKmPerKwh: '6.5',
        healthPercent: '95',
        minArrivalPercent: '15',
        maxChargePercent: '80',
        licensePlate: 'KA 01 EV 1234',
      );

      expect(draft.isValid, isTrue);
      final Vehicle vehicle = draft.toVehicle(
        id: 'vehicle-1',
        userId: 'user-1',
      );

      expect(vehicle.id, 'vehicle-1');
      expect(vehicle.userId, 'user-1');
      expect(vehicle.displayName, 'Tata Nexon EV');
      expect(vehicle.connectorType, 'CCS_2_DC');
      expect(vehicle.batteryCapacityKwh, 40.5);
      expect(vehicle.batteryHealthPercent, 95);
      expect(vehicle.minArrivalSocPercent, 15);
      expect(vehicle.maxChargeSocPercent, 80);
      expect(vehicle.licensePlate, 'KA 01 EV 1234');
      expect(vehicle.isActive, isTrue);
      expect(vehicle.effectiveCapacityKwh, closeTo(38.475, 0.001));
    });

    test(
      'keeps the learned efficiency correction while filling blank defaults',
      () {
        const Vehicle source = Vehicle(
          id: 'vehicle-1',
          userId: 'user-1',
          make: 'Tata',
          model: 'Nexon EV',
          purchaseYear: 2024,
          batteryCapacityKwh: 0,
          batteryHealthPercent: 0,
          efficiencyCorrectionPercent: -4.5,
        );

        final VehicleDraft draft = VehicleDraft.fromVehicle(
          source,
          currentYear: 2026,
        );
        final Vehicle rebuilt = draft.toVehicle(
          id: source.id,
          userId: 'user-1',
        );

        expect(draft.capacityKwh, '40.5');
        expect(draft.healthPercent, '96');
        expect(rebuilt.efficiencyCorrectionPercent, -4.5);
        expect(rebuilt.batteryCapacityKwh, 40.5);
        expect(rebuilt.batteryHealthPercent, 96);
      },
    );

    test('blank defaults stay inside the validation bounds', () {
      final VehicleDraft draft = VehicleDraft.blank(currentYear: 2026);

      expect(draft.year, '2026');
      expect(draft.connectorType, 'TYPE_2_AC');
      expect(draft.capacityError, isNull);
      expect(draft.efficiencyError, isNull);
      expect(draft.healthError, isNull);
      expect(draft.minArrivalError, isNull);
      expect(draft.maxChargeError, isNull);
      expect(draft.socOrderError, isNull);
    });
  });
}
