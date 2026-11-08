import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/station_repository.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/discovery_providers.dart';
import 'package:flutter_test/flutter_test.dart';

StationCatalogueEntry _entry({
  required String id,
  required String connector,
  bool isDc = false,
  bool metered = true,
  int availablePorts = 1,
  int totalPorts = 2,
}) {
  return StationCatalogueEntry(
    station: ChargerStation(
      id: id,
      name: id,
      connectorTypes: connector,
      isDcCapable: isDc,
      verificationLevel: metered
          ? AmpPolicy.level1VerifiedManual
          : AmpPolicy.level3NoVerifiedMeter,
    ),
    ports: <ChargerPort>[
      for (int index = 0; index < totalPorts; index++)
        ChargerPort(
          id: '$id-port-$index',
          stationId: id,
          portNumber: '${index + 1}',
          connectorType: connector,
          status: index < availablePorts
              ? AmpPolicy.portAvailable
              : AmpPolicy.portOccupied,
        ),
    ],
  );
}

void main() {
  final StationCatalogueEntry ccs = _entry(
    id: 'ccs',
    connector: 'CCS2',
    isDc: true,
    availablePorts: 2,
    totalPorts: 3,
  );
  final StationCatalogueEntry type2 = _entry(
    id: 'type2',
    connector: 'TYPE_2_AC',
    metered: false,
    availablePorts: 0,
  );
  final List<StationCatalogueEntry> entries = <StationCatalogueEntry>[
    ccs,
    type2,
  ];
  const Vehicle vehicle = Vehicle(
    id: 'vehicle',
    connectorType: 'CCS2',
    batteryCapacityKwh: 40,
    typicalEfficiencyKmPerKwh: 6.5,
  );

  test('all returns the whole approved catalogue', () {
    expect(
      filterStationEntries(
        entries: entries,
        filter: DiscoveryFilter.all,
        vehicle: vehicle,
      ),
      entries,
    );
  });

  test('compatible follows the active vehicle connector', () {
    final List<StationCatalogueEntry> result = filterStationEntries(
      entries: entries,
      filter: DiscoveryFilter.compatible,
      vehicle: vehicle,
    );
    expect(
      result.map((StationCatalogueEntry entry) => entry.station.id),
      <String>['ccs'],
    );
  });

  test('compatible has no matches until a vehicle is saved', () {
    expect(
      filterStationEntries(
        entries: entries,
        filter: DiscoveryFilter.compatible,
        vehicle: null,
      ),
      isEmpty,
    );
  });

  test('DC and verified-meter filters use station facts', () {
    expect(
      filterStationEntries(
        entries: entries,
        filter: DiscoveryFilter.dc,
        vehicle: vehicle,
      ).single.station.id,
      'ccs',
    );
    expect(
      filterStationEntries(
        entries: entries,
        filter: DiscoveryFilter.metered,
        vehicle: vehicle,
      ).single.station.id,
      'ccs',
    );
  });

  test('port availability is counted, never inferred', () {
    expect(availablePortCount(ccs), 2);
    expect(availabilityLabel(ccs), '2 of 3 ports available now');
    expect(availabilityLabel(type2), 'No port available now');
  });
}
