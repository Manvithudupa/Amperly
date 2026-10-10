package com.amperly.app.engine.routing;

import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;

import java.util.ArrayList;
import java.util.List;

public class RoutePlannerEngine {

    public static class CandidateEvaluation {
        private final ChargerStation station;
        private final double detourKm;
        private final int detourMins;
        private final int expectedArrivalSoc;
        private final double energyAddedKwh;
        private final int chargingTimeMins;
        private final int socAfterCharging;
        private final int finalArrivalSoc;
        private final boolean isReachable;

        public CandidateEvaluation(ChargerStation station, double detourKm, int detourMins,
                                   int expectedArrivalSoc, double energyAddedKwh,
                                   int chargingTimeMins, int socAfterCharging,
                                   int finalArrivalSoc, boolean isReachable) {
            this.station = station;
            this.detourKm = detourKm;
            this.detourMins = detourMins;
            this.expectedArrivalSoc = expectedArrivalSoc;
            this.energyAddedKwh = energyAddedKwh;
            this.chargingTimeMins = chargingTimeMins;
            this.socAfterCharging = socAfterCharging;
            this.finalArrivalSoc = finalArrivalSoc;
            this.isReachable = isReachable;
        }

        public ChargerStation getStation() { return station; }
        public double getDetourKm() { return detourKm; }
        public int getDetourMins() { return detourMins; }
        public int getExpectedArrivalSoc() { return expectedArrivalSoc; }
        public double getEnergyAddedKwh() { return energyAddedKwh; }
        public int getChargingTimeMins() { return chargingTimeMins; }
        public int getSocAfterCharging() { return socAfterCharging; }
        public int getFinalArrivalSoc() { return finalArrivalSoc; }
        public boolean isReachable() { return isReachable; }
    }

    public static class RoutePlanResult {
        private final String origin;
        private final String destination;
        private final double totalDistanceKm;
        private final int estimatedDriveMins;
        private final CandidateEvaluation recommendedStop;
        private final List<CandidateEvaluation> candidateEvaluations;

        public RoutePlanResult(String origin, String destination, double totalDistanceKm,
                               int estimatedDriveMins, CandidateEvaluation recommendedStop,
                               List<CandidateEvaluation> candidateEvaluations) {
            this.origin = origin;
            this.destination = destination;
            this.totalDistanceKm = totalDistanceKm;
            this.estimatedDriveMins = estimatedDriveMins;
            this.recommendedStop = recommendedStop;
            this.candidateEvaluations = candidateEvaluations;
        }

        public String getOrigin() { return origin; }
        public String getDestination() { return destination; }
        public double getTotalDistanceKm() { return totalDistanceKm; }
        public int getEstimatedDriveMins() { return estimatedDriveMins; }
        public CandidateEvaluation getRecommendedStop() { return recommendedStop; }
        public List<CandidateEvaluation> getCandidateEvaluations() { return candidateEvaluations; }
    }

    public static RoutePlanResult planRoute(String origin, String destination, double totalDistanceKm,
                                           int currentSoc, Vehicle vehicle, List<ChargerStation> candidateStations) {
        int estimatedDriveMins = (int) Math.round((totalDistanceKm / 60.0) * 60.0);
        List<CandidateEvaluation> evaluations = new ArrayList<>();
        CandidateEvaluation bestStop = null;

        double effectiveCapacity = vehicle != null ? vehicle.getBatteryCapacityKwh() * (1.0 - vehicle.getDegradationFactorPercent() / 100.0) : 40.0;
        double efficiency = vehicle != null && vehicle.getTypicalEfficiencyKmPerKwh() > 0 ? vehicle.getTypicalEfficiencyKmPerKwh() : 6.5;
        int minReserve = vehicle != null ? vehicle.getMinArrivalSocPercent() : 15;
        int maxTargetSoc = vehicle != null ? vehicle.getMaxChargeSocPercent() : 80;

        for (int i = 0; i < candidateStations.size(); i++) {
            ChargerStation station = candidateStations.get(i);
            double distToCharger = (totalDistanceKm * 0.5) + (i * 4.0);
            double detourKm = 2.0 + (i * 2.2);
            int detourMins = (int) Math.round((detourKm / 30.0) * 60.0);

            double kwhUsedToCharger = distToCharger / efficiency;
            int socUsed = (int) Math.round((kwhUsedToCharger / effectiveCapacity) * 100.0);
            int arrivalSoc = currentSoc - socUsed;

            boolean isReachable = arrivalSoc >= minReserve;

            int targetSoc = Math.max(arrivalSoc, maxTargetSoc);
            int socNeeded = targetSoc - arrivalSoc;
            double energyAddedKwh = (socNeeded / 100.0) * effectiveCapacity;

            int chargingMins = (int) Math.round((energyAddedKwh / 30.0) * 60.0);
            if (chargingMins < 10) chargingMins = 15;

            double remainingDist = (totalDistanceKm - distToCharger) + detourKm;
            double kwhUsedRemaining = remainingDist / efficiency;
            int socUsedRemaining = (int) Math.round((kwhUsedRemaining / effectiveCapacity) * 100.0);
            int finalSoc = targetSoc - socUsedRemaining;

            CandidateEvaluation eval = new CandidateEvaluation(
                    station, detourKm, detourMins, arrivalSoc, energyAddedKwh,
                    chargingMins, targetSoc, finalSoc, isReachable
            );
            evaluations.add(eval);

            if (isReachable && (bestStop == null || eval.getDetourKm() < bestStop.getDetourKm())) {
                bestStop = eval;
            }
        }

        return new RoutePlanResult(origin, destination, totalDistanceKm, estimatedDriveMins, bestStop, evaluations);
    }
}
