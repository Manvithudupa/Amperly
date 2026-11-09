package com.amperly.app.car;

import androidx.annotation.Nullable;

import com.amperly.app.core.location.LocationProvider;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.RoutePlan;
import com.amperly.app.data.local.entity.RouteStop;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.availability.AvailabilityEngine;
import com.amperly.app.engine.booking.ReservationEngine;
import com.amperly.app.engine.soc.SoCEstimatorEngine;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.UUID;

/**
 * Bridge between the projected Android Auto experience and the same data the phone uses.
 *
 * <p>The car only reads a small, glanceable snapshot: the active plan, the reachable chargers, the
 * battery value the driver last confirmed, and the reservation. Everything it can do is a safe,
 * short action: update the battery, reserve the next free slot, or start navigation.
 *
 * <p>Every positional calculation uses the newest real fix when it is less than two minutes old,
 * and falls back to the planned origin only when there is genuinely no fresh position. The car
 * never pretends a planned origin is the driver's current location.
 */
public final class CarBridge {

    /** A fix older than this cannot be trusted for range arithmetic. */
    private static final long FRESH_FIX_MS = 2L * 60L * 1000L;

    public static class Snapshot {
        private final RoutePlan plan;
        private final Vehicle vehicle;
        private final Reservation reservation;
        private final List<ChargerStation> reachableStations;
        private final ChargerStation recommendedStation;
        private final double recommendedDetourKm;
        private final int currentSoc;
        private final boolean socAuthoritative;
        private final String noSafeChargerMessage;

        public Snapshot(RoutePlan plan, Vehicle vehicle, Reservation reservation,
                        List<ChargerStation> reachableStations, ChargerStation recommendedStation,
                        double recommendedDetourKm, int currentSoc, boolean socAuthoritative,
                        String noSafeChargerMessage) {
            this.plan = plan;
            this.vehicle = vehicle;
            this.reservation = reservation;
            this.reachableStations = reachableStations;
            this.recommendedStation = recommendedStation;
            this.recommendedDetourKm = recommendedDetourKm;
            this.currentSoc = currentSoc;
            this.socAuthoritative = socAuthoritative;
            this.noSafeChargerMessage = noSafeChargerMessage;
        }

        public RoutePlan getPlan() { return plan; }
        public Vehicle getVehicle() { return vehicle; }
        public Reservation getReservation() { return reservation; }
        public List<ChargerStation> getReachableStations() { return reachableStations; }
        public ChargerStation getRecommendedStation() { return recommendedStation; }
        public double getRecommendedDetourKm() { return recommendedDetourKm; }
        public int getCurrentSoc() { return currentSoc; }
        public boolean isSocAuthoritative() { return socAuthoritative; }
        public String getNoSafeChargerMessage() { return noSafeChargerMessage; }
    }

    /** Structured result of a dashboard-battery correction; screens localise the text. */
    public static final class BatteryUpdate {
        public static final String PROBLEM_NO_PLAN = "NO_PLAN";
        public static final String PROBLEM_FAILED = "FAILED";

        private final boolean applied;
        @Nullable private final String problem;
        private final boolean noSafeCharger;
        @Nullable private final String nextChargerName;
        private final int nextChargerDistanceKm;

        private BatteryUpdate(boolean applied, @Nullable String problem, boolean noSafeCharger,
                              @Nullable String nextChargerName, int nextChargerDistanceKm) {
            this.applied = applied;
            this.problem = problem;
            this.noSafeCharger = noSafeCharger;
            this.nextChargerName = nextChargerName;
            this.nextChargerDistanceKm = nextChargerDistanceKm;
        }

        static BatteryUpdate noPlan() {
            return new BatteryUpdate(false, PROBLEM_NO_PLAN, false, null, 0);
        }

        static BatteryUpdate failed() {
            return new BatteryUpdate(false, PROBLEM_FAILED, false, null, 0);
        }

        static BatteryUpdate applied(boolean noSafeCharger, @Nullable String nextChargerName,
                                     int nextChargerDistanceKm) {
            return new BatteryUpdate(true, null, noSafeCharger, nextChargerName,
                    nextChargerDistanceKm);
        }

        public boolean isApplied() { return applied; }
        @Nullable public String getProblem() { return problem; }
        public boolean isNoSafeCharger() { return noSafeCharger; }
        @Nullable public String getNextChargerName() { return nextChargerName; }
        public int getNextChargerDistanceKm() { return nextChargerDistanceKm; }
    }

    /** Structured result of a one-tap reservation; screens localise the text. */
    public static final class ReservationAttempt {
        public static final String PROBLEM_STATION_MISSING = "STATION_MISSING";
        public static final String PROBLEM_NO_METER = "NO_METER";
        public static final String PROBLEM_NO_SLOT = "NO_SLOT";
        public static final String PROBLEM_PORT_MISSING = "PORT_MISSING";
        public static final String PROBLEM_SERVER = "SERVER";

        private final boolean reserved;
        @Nullable private final String problem;
        @Nullable private final String serverMessage;
        @Nullable private final String stationName;
        @Nullable private final String portLabel;
        @Nullable private final String bookingCode;

        private ReservationAttempt(boolean reserved, @Nullable String problem,
                                   @Nullable String serverMessage, @Nullable String stationName,
                                   @Nullable String portLabel, @Nullable String bookingCode) {
            this.reserved = reserved;
            this.problem = problem;
            this.serverMessage = serverMessage;
            this.stationName = stationName;
            this.portLabel = portLabel;
            this.bookingCode = bookingCode;
        }

        static ReservationAttempt refused(String problem, @Nullable String serverMessage) {
            return new ReservationAttempt(false, problem, serverMessage, null, null, null);
        }

        static ReservationAttempt reserved(@Nullable String stationName, @Nullable String portLabel,
                                           @Nullable String bookingCode) {
            return new ReservationAttempt(true, null, null, stationName, portLabel, bookingCode);
        }

        public boolean isReserved() { return reserved; }
        @Nullable public String getProblem() { return problem; }
        @Nullable public String getServerMessage() { return serverMessage; }
        @Nullable public String getStationName() { return stationName; }
        @Nullable public String getPortLabel() { return portLabel; }
        @Nullable public String getBookingCode() { return bookingCode; }
    }

    public interface Callback<T> {
        void onResult(T value);
    }

    private CarBridge() {
    }

    public static void load(AmperlyRepository repo, Callback<Snapshot> callback) {
        repo.background(() -> {
            String userId = AuthManager.getInstance().getCurrentUserId();
            RoutePlan plan = AppStateStore.get().getActivePlan();
            if (plan == null) {
                plan = repo.getActiveRoutePlanSync(userId);
            }
            Vehicle vehicle = repo.getVehicleSync(userId);
            Reservation reservation = repo.getActiveReservationSync(userId);

            int soc = plan == null
                    ? AppStateStore.get().getCurrentSoc()
                    : (AppStateStore.get().getCurrentSoc() >= 0
                    ? AppStateStore.get().getCurrentSoc() : plan.getPlannedStartSoc());
            List<ChargerStation> reachable = new ArrayList<>();
            ChargerStation recommended = null;
            double detourKm = 0;

            if (plan != null) {
                com.amperly.app.data.local.entity.BatteryUpdate latest =
                        repo.getLatestBatteryUpdateSync(plan.getId());
                if (latest != null && latest.getActualDashboardSoc() >= 0
                        && latest.getActualDashboardSoc() <= 100) {
                    // The phone writes this row when the driver confirms the dashboard value.
                    // Apply it before range arithmetic so the car and phone agree.
                    AppStateStore.get().applyStoredSoc(plan.getVehicleId(),
                            latest.getEstimatedSoc());
                    AppStateStore.get().applySocCorrection(latest.getEstimatedSoc(),
                            latest.getActualDashboardSoc());
                    soc = latest.getActualDashboardSoc();
                }
                List<ChargerStation> candidates = repo.getApprovedStationsSync();
                double[] position = currentPosition(plan);
                reachable = SoCEstimatorEngine.safeAlternatives(candidates, soc, position[0],
                        position[1], vehicle, 5);
                if (!reachable.isEmpty()) {
                    recommended = reachable.get(0);
                }
                if (recommended != null) {
                    for (RouteStop stop : repo.getRouteStopsSync(plan.getId())) {
                        if (stop.getStationId() != null
                                && stop.getStationId().equals(recommended.getId())) {
                            detourKm = stop.getDetourKm();
                            break;
                        }
                    }
                }
            }

            return new Snapshot(plan, vehicle, reservation, reachable, recommended, detourKm,
                    soc, AppStateStore.get().isSocAuthoritative(),
                    AppStateStore.get().getNoSafeChargerMessage());
        }, callback::onResult);
    }

    /** Applies the driver's dashboard value as authoritative and recalculates the remaining trip. */
    public static void applyBatteryUpdate(AmperlyRepository repo, int actualSoc,
                                         Callback<String> callback) {
        applyBatteryUpdateResult(repo, actualSoc, result -> {
            if (!result.isApplied()) {
                callback.onResult(BatteryUpdate.PROBLEM_NO_PLAN.equals(result.getProblem())
                        ? "Plan a trip on your phone first."
                        : "Battery update failed. Try again.");
                return;
            }
            if (result.isNoSafeCharger()) {
                callback.onResult("Battery " + actualSoc + "% applied. No safe charger in range.");
                return;
            }
            String name = result.getNextChargerName();
            callback.onResult("Battery " + actualSoc + "% applied."
                    + (name == null ? "" : " Next safe charger: " + name + ", "
                    + result.getNextChargerDistanceKm() + " km away"));
        });
    }

    /**
     * Same correction as {@link #applyBatteryUpdate}, but returns data instead of an English
     * sentence so the car screens can show their own localised strings.
     */
    public static void applyBatteryUpdateResult(AmperlyRepository repo, int actualSoc,
                                                Callback<BatteryUpdate> callback) {
        repo.background(() -> {
            try {
                String userId = AuthManager.getInstance().getCurrentUserId();
                RoutePlan plan = AppStateStore.get().getActivePlan();
                if (plan == null) {
                    plan = repo.getActiveRoutePlanSync(userId);
                }
                if (plan == null) {
                    return BatteryUpdate.noPlan();
                }
                Vehicle vehicle = repo.getVehicleSync(userId);
                int previousEstimate = AppStateStore.get().getCurrentSoc() >= 0
                        ? AppStateStore.get().getCurrentSoc() : plan.getPlannedStartSoc();

                // The car has a real position now: use it while it is fresh, and only fall back to
                // the planned origin when no recent fix exists.
                double[] position = currentPosition(plan);

                SoCEstimatorEngine.RecalculationResult result =
                        SoCEstimatorEngine.applyAuthoritativeSocOverride(plan.getVehicleId(),
                                plan.getId(), previousEstimate, actualSoc, position[0], position[1],
                                plan.getTotalDistanceKm() * 0.6, plan.getDestinationLat(),
                                plan.getDestinationLng(), vehicle, repo.getApprovedStationsSync(),
                                AppStateStore.get().safeReachableStations());

                repo.saveBatteryUpdate(result.getAuditRecord());
                AppStateStore.get().applySocCorrection(previousEstimate, actualSoc);
                AppStateStore.get().setLastRecalculationSummary(result.getExplanation());
                AppStateStore.get().setNoSafeChargerMessage(result.getWarningMessage() == null ? ""
                        : result.getWarningMessage());

                String nextName = result.getRecommendedNextCharger() == null ? null
                        : result.getRecommendedNextCharger().getName();
                int nextKm = result.getRecommendedStop() == null ? 0
                        : (int) Math.round(result.getRecommendedStop().getDistanceFromCurrentKm());
                return BatteryUpdate.applied(result.isNoSafeCharger(), nextName, nextKm);
            } catch (RuntimeException e) {
                return BatteryUpdate.failed();
            }
        }, callback::onResult);
    }

    /** Reserves the next free slot on a station from the car display. */
    public static void reserveNextFreeSlot(AmperlyRepository repo, String stationId,
                                          Callback<String> callback) {
        reserveNextFreeSlotResult(repo, stationId, result -> {
            if (!result.isReserved()) {
                if (ReservationAttempt.PROBLEM_STATION_MISSING.equals(result.getProblem())) {
                    callback.onResult("Station not found.");
                } else if (ReservationAttempt.PROBLEM_NO_METER.equals(result.getProblem())) {
                    callback.onResult("No verified meter here. Discovery only.");
                } else if (ReservationAttempt.PROBLEM_NO_SLOT.equals(result.getProblem())) {
                    callback.onResult("No free slot published right now.");
                } else if (ReservationAttempt.PROBLEM_PORT_MISSING.equals(result.getProblem())) {
                    callback.onResult("That port is no longer listed.");
                } else {
                    callback.onResult(result.getServerMessage() == null
                            ? "The booking was refused. Try again." : result.getServerMessage());
                }
                return;
            }
            callback.onResult("Reserved " + result.getPortLabel() + " at "
                    + result.getStationName() + " · code " + result.getBookingCode());
        });
    }

    /**
     * Same one-tap reservation as {@link #reserveNextFreeSlot}, returning structured data so the
     * car screen can show a localised confirmation.
     */
    public static void reserveNextFreeSlotResult(AmperlyRepository repo, String stationId,
                                                 Callback<ReservationAttempt> callback) {
        repo.background(() -> {
            try {
                ChargerStation station = repo.getStationSync(stationId);
                if (station == null) {
                    return ReservationAttempt.refused(
                            ReservationAttempt.PROBLEM_STATION_MISSING, null);
                }
                if (!station.supportsPaidEnergyBilling()) {
                    return ReservationAttempt.refused(ReservationAttempt.PROBLEM_NO_METER, null);
                }
                Calendar day = Calendar.getInstance();
                day.set(Calendar.HOUR_OF_DAY, 0);
                day.set(Calendar.MINUTE, 0);
                day.set(Calendar.SECOND, 0);
                day.set(Calendar.MILLISECOND, 0);
                List<AvailabilityEngine.Slot> slots = new ArrayList<>();
                for (int offset = 0; offset < 2 && slots.isEmpty(); offset++) {
                    long start = day.getTimeInMillis() + (offset * 24L * 60L * 60L * 1000L);
                    for (AvailabilityEngine.Slot slot : repo.getSlots(stationId, start,
                            AvailabilityEngine.DEFAULT_SLOT_MINUTES, 12)) {
                        if (slot.isAvailable()) {
                            slots.add(slot);
                        }
                    }
                }
                if (slots.isEmpty()) {
                    return ReservationAttempt.refused(ReservationAttempt.PROBLEM_NO_SLOT, null);
                }
                AvailabilityEngine.Slot slot = slots.get(0);

                // The slot names a port; the booking call needs the row itself for its label.
                ChargerPort port = null;
                for (ChargerPort candidate : repo.getPortsSync(stationId)) {
                    if (candidate.getId().equals(slot.getPortId())) {
                        port = candidate;
                        break;
                    }
                }
                if (port == null) {
                    return ReservationAttempt.refused(ReservationAttempt.PROBLEM_PORT_MISSING, null);
                }

                String reservationId = UUID.randomUUID().toString();
                String code = ReservationEngine.buildBookingCode();
                // The server owns the slot: it checks the window under a per-port lock and
                // writes the row, so the car cannot confirm a slot another driver just took.
                AmperlyRepository.BookingResult result = repo.createReservationConfirmed(
                        reservationId, code, station, port, slot.getStartMs(), slot.getEndMs());
                if (!result.success || result.reservation == null) {
                    return ReservationAttempt.refused(ReservationAttempt.PROBLEM_SERVER,
                            result.message);
                }

                AppStateStore.get().setActiveReservation(result.reservation);
                AppStateStore.get().setLastBookingCode(code);
                return ReservationAttempt.reserved(station.getName(), slot.getPortLabel(), code);
            } catch (RuntimeException e) {
                return ReservationAttempt.refused(ReservationAttempt.PROBLEM_SERVER, null);
            }
        }, callback::onResult);
    }

    /**
     * The newest real position when it is recent enough to trust, else the planned origin.
     * Never invents a point: without either, the caller still gets the plan's own origin.
     */
    private static double[] currentPosition(RoutePlan plan) {
        double[] fix = LocationProvider.lastKnownFix();
        if (fix != null && LocationProvider.lastFixAgeMs() <= FRESH_FIX_MS
                && CarMapGeometry.isValidCoordinate(fix[0], fix[1])) {
            return fix;
        }
        return new double[]{plan.getOriginLat(), plan.getOriginLng()};
    }
}
