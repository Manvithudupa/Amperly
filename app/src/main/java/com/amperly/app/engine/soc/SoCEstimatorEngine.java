package com.amperly.app.engine.soc;

import com.amperly.app.data.local.entity.BatteryUpdate;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class SoCEstimatorEngine {

    public static class RecalculationResult {
        private final int previousEstimatedSoc;
        private final int actualDashboardSoc;
        private final boolean wasOverrideApplied;
        private final List<ChargerStation> safeReachableStations;
        private final List<ChargerStation> unreachableStations;
        private final ChargerStation recommendedNextCharger;
        private final String warningMessage;

        public RecalculationResult(int previousEstimatedSoc, int actualDashboardSoc,
                                   boolean wasOverrideApplied, List<ChargerStation> safeReachableStations,
                                   List<ChargerStation> unreachableStations,
                                   ChargerStation recommendedNextCharger, String warningMessage) {
            this.previousEstimatedSoc = previousEstimatedSoc;
            this.actualDashboardSoc = actualDashboardSoc;
            this.wasOverrideApplied = wasOverrideApplied;
            this.safeReachableStations = safeReachableStations;
            this.unreachableStations = unreachableStations;
            this.recommendedNextCharger = recommendedNextCharger;
            this.warningMessage = warningMessage;
        }

        public int getPreviousEstimatedSoc() { return previousEstimatedSoc; }
        public int getActualDashboardSoc() { return actualDashboardSoc; }
        public boolean isWasOverrideApplied() { return wasOverrideApplied; }
        public List<ChargerStation> getSafeReachableStations() { return safeReachableStations; }
        public List<ChargerStation> getUnreachableStations() { return unreachableStations; }
        public ChargerStation getRecommendedNextCharger() { return recommendedNextCharger; }
        public String getWarningMessage() { return warningMessage; }
    }

    public static int estimateSocAfterDistance(int startSoc, double distanceKm, Vehicle vehicle) {
        if (vehicle == null) return Math.max(0, startSoc - (int) Math.round((distanceKm / 5.0)));
        double effectiveCapacity = vehicle.getBatteryCapacityKwh() * (1.0 - vehicle.getDegradationFactorPercent() / 100.0);
        double efficiency = vehicle.getTypicalEfficiencyKmPerKwh() > 0 ? vehicle.getTypicalEfficiencyKmPerKwh() : 6.5;
        double kwhConsumed = distanceKm / efficiency;
        int socUsed = (int) Math.round((kwhConsumed / effectiveCapacity) * 100.0);
        return Math.max(0, startSoc - socUsed);
    }

    public static RecalculationResult applyAuthoritativeSocOverride(
            String vehicleId, String tripPlanId, int currentEstimatedSoc,
            int actualDashboardSoc, double drivenDistanceKm, double remainingDistanceKm,
            double currentLat, double currentLng, Vehicle vehicle,
            List<ChargerStation> candidateStations) {

        int minReserve = vehicle != null ? vehicle.getMinArrivalSocPercent() : 15;
        double effectiveCapacity = vehicle != null ? vehicle.getBatteryCapacityKwh() * (1.0 - vehicle.getDegradationFactorPercent() / 100.0) : 40.0;
        double efficiency = vehicle != null && vehicle.getTypicalEfficiencyKmPerKwh() > 0 ? vehicle.getTypicalEfficiencyKmPerKwh() : 6.5;

        BatteryUpdate updateRecord = new BatteryUpdate(
                UUID.randomUUID().toString(), vehicleId, tripPlanId,
                currentEstimatedSoc, actualDashboardSoc, currentLat, currentLng,
                System.currentTimeMillis()
        );

        List<ChargerStation> safeList = new ArrayList<>();
        List<ChargerStation> unreachableList = new ArrayList<>();
        ChargerStation recommended = null;

        for (ChargerStation station : candidateStations) {
            double distToStation = Math.max(1.0, remainingDistanceKm * 0.3);
            double kwhToStation = distToStation / efficiency;
            int socUsed = (int) Math.round((kwhToStation / effectiveCapacity) * 100.0);
            int expectedArrivalSoc = actualDashboardSoc - socUsed;

            if (expectedArrivalSoc >= minReserve) {
                safeList.add(station);
                if (recommended == null) {
                    recommended = station;
                }
            } else {
                unreachableList.add(station);
            }
        }

        String warning = null;
        if (safeList.isEmpty()) {
            warning = "WARNING: No safe charger found within current battery range under reserve threshold (" + minReserve + "%). Consider wider search radius or emergency assistance.";
        }

        return new RecalculationResult(
                currentEstimatedSoc, actualDashboardSoc, true,
                safeList, unreachableList, recommended, warning
        );
    }
}
