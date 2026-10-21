package com.amperly.app.data.repository;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LiveData;

import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.AndroidAutoSession;
import com.amperly.app.data.local.entity.AvailabilitySchedule;
import com.amperly.app.data.local.entity.BatteryUpdate;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.ChatMessage;
import com.amperly.app.data.local.entity.CommunicationThread;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.HostEnforcementAction;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.local.entity.MeterReading;
import com.amperly.app.data.local.entity.Notification;
import com.amperly.app.data.local.entity.Payment;
import com.amperly.app.data.local.entity.Report;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.RoutePlan;
import com.amperly.app.data.local.entity.RouteStop;
import com.amperly.app.data.local.entity.SyncOutboxEntry;
import com.amperly.app.data.local.entity.SafetyEvent;
import com.amperly.app.data.local.entity.TripEstimate;
import com.amperly.app.data.local.entity.TrustedContact;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.remote.SupabaseRest;
import com.amperly.app.data.remote.SyncEngine;
import com.amperly.app.engine.analytics.HostAnalyticsEngine;
import com.amperly.app.engine.availability.AvailabilityEngine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Single entry point for reading and writing Amperly data. Room queries that would block are pushed
 * onto a background executor and their results are delivered back on the main thread.
 */
public class AmperlyRepository {

    private static final String TAG = "AmperlyRepository";

    public interface Callback<T> {
        void onResult(T value);
    }

    private static volatile AmperlyRepository INSTANCE;

    private final AmperlyDatabase db;
    private final Context appContext;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    /**
     * Set when the server refused to create the signed-in account's profile row. The account then
     * exists on the device but not in {@code public.users}, which makes it anonymous to every RLS
     * policy, so the UI has to say so instead of showing a silently empty app.
     */
    private volatile boolean profileWriteFailed;

    /** Set while a push is in flight, so a burst of writes produces one sync at a time. */
    private final java.util.concurrent.atomic.AtomicBoolean syncRunning =
            new java.util.concurrent.atomic.AtomicBoolean(false);

    /**
     * Set when a write arrives while a push is already running. The running push drains the
     * outbox once more before it finishes, so a save made mid-sync can never be left queued.
     */
    private final java.util.concurrent.atomic.AtomicBoolean syncRequestedAgain =
            new java.util.concurrent.atomic.AtomicBoolean(false);

    private AmperlyRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
        appContext = context.getApplicationContext();
    }

    public static AmperlyRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (AmperlyRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new AmperlyRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public AmperlyDatabase database() {
        return db;
    }

    /**
     * Runs background work and delivers the result on the main thread.
     *
     * <p>A failure delivers {@code null}, but it is also logged. Swallowing it silently is how a
     * screen ends up looking like it works while showing nothing at all, which is exactly the
     * kind of bug that is hardest to report and hardest to find.
     */
    public <T> void background(Callable<T> work, Callback<T> callback) {
        executor.execute(() -> {
            try {
                T value = work.call();
                if (callback != null) {
                    mainHandler.post(() -> callback.onResult(value));
                }
            } catch (Exception e) {
                Log.e(TAG, "Background work failed: " + e, e);
                if (callback != null) {
                    mainHandler.post(() -> callback.onResult(null));
                }
            }
        });
    }

    public void run(Runnable work) {
        executor.execute(() -> {
            try {
                work.run();
            } catch (Exception e) {
                Log.e(TAG, "Background task failed: " + e, e);
            }
        });
    }

    // ------------------------------------------------------------------- sync
    // Room is always written first and the change is queued for Supabase in the same
    // pass, so the UI never waits on the network and a change cannot be lost while the
    // device is offline. The queue is then drained straight away, on a background thread, so a
    // saved row is in the database without the user having to trigger a sync.

    private void syncUpsert(String table, Object entity) {
        SyncEngine.enqueue(db, table, entity, SyncOutboxEntry.OP_UPSERT);
        requestAutoSync();
    }

    private void syncUpsertAll(String table, List<?> entities) {
        if (entities == null || entities.isEmpty()) {
            return;
        }
        for (Object entity : entities) {
            SyncEngine.enqueue(db, table, entity, SyncOutboxEntry.OP_UPSERT);
        }
        requestAutoSync();
    }

    private void syncDelete(String table, Object entity) {
        SyncEngine.enqueue(db, table, entity, SyncOutboxEntry.OP_DELETE);
        requestAutoSync();
    }

    /**
     * Queues a Postgres function call. Used where the change must be produced by the
     * server's own logic rather than by copying a locally edited row onto a table.
     */
    private void syncRpc(String function, String dedupeKey, Map<String, Object> args) {
        SyncEngine.enqueueRpc(db, function, dedupeKey, args);
        requestAutoSync();
    }

    /**
     * Pushes queued changes to the server immediately after a local write, so pressing Save is
     * enough: the row is in the database before the user leaves the screen.
     *
     * <p>Room is written first and the outbox makes each change durable, so the push runs on a
     * background thread and a device that is offline keeps the change queued for the next write
     * instead of losing it. A write made while a push is already running asks that push for one
     * more pass, which is what keeps a burst of saves from leaving the last one behind.
     *
     * <p>When the backend is not configured this is a no-op.
     */
    public void requestAutoSync() {
        if (!SyncEngine.isEnabled()) {
            return;
        }
        syncRequestedAgain.set(true);
        if (!syncRunning.compareAndSet(false, true)) {
            return;
        }
        executor.execute(this::drainOutbox);
    }

    /** Drains the outbox until no write has arrived since the pass started. */
    private void drainOutbox() {
        try {
            while (syncRequestedAgain.getAndSet(false)) {
                try {
                    SyncEngine.syncNow(appContext, db);
                } catch (Exception e) {
                    // Left queued on purpose: the next save retries it.
                    Log.w(TAG, "Automatic sync failed and will retry on the next save: "
                            + e.getMessage());
                    break;
                }
            }
        } finally {
            syncRunning.set(false);
            // A write can land between the loop's last check and the flag being cleared above.
            if (syncRequestedAgain.get() && syncRunning.compareAndSet(false, true)) {
                executor.execute(this::drainOutbox);
            }
        }
    }

    private static Map<String, Object> singleArg(String key, Object value) {
        Map<String, Object> args = new LinkedHashMap<>();
        args.put(key, value);
        return args;
    }

    /** Honest one-line sync state for the UI: queued, failing, last success. */
    public String syncStatus() {
        return SyncEngine.statusSummary(appContext, db);
    }

    public int pendingSyncCount() {
        return SyncEngine.pendingCount(db);
    }

    public boolean isBackendEnabled() {
        return SyncEngine.isEnabled();
    }

    // ---------------------------------------------------------------- users

    public LiveData<User> getUser(String id) {
        return db.userDao().getUserById(id);
    }

    public User getUserSync(String id) {
        return db.userDao().getUserByIdSync(id);
    }

    public List<User> getAllUsersSync() {
        return db.userDao().getAllUsersSync();
    }

    // ------------------------------------------------------ sign in / sign out

    /**
     * The application profile behind a signed-in Supabase account.
     *
     * <p>Read from the server rather than the local copy on purpose: the local
     * {@code users} table has no authUserId column — Gson ignores that key because it is
     * a server-only column — so there is nothing local to match on. Row Level Security
     * returns only the caller's own row here (an administrator sees everyone's).
     */
    public User findAppUserByAuthId(String authUserId) {
        if (authUserId == null || authUserId.isEmpty()) {
            return null;
        }
        try {
            Map<String, String> query = new LinkedHashMap<>();
            query.put("select", "*");
            query.put("id", "eq." + authUserId);
            query.put("limit", "1");
            List<User> rows = SupabaseRest.select("users", User.class, query);
            if (!rows.isEmpty()) {
                return rows.get(0);
            }
        } catch (Exception ignored) {}

        try {
            Map<String, String> query = new LinkedHashMap<>();
            query.put("select", "*");
            query.put("authUserId", "eq." + authUserId);
            query.put("limit", "1");
            List<User> rows = SupabaseRest.select("users", User.class, query);
            if (!rows.isEmpty()) {
                return rows.get(0);
            }
        } catch (Exception ignored) {}

        return null;
    }

    public User resolveOrCreateAppUser(String authUserId, String email, String fallbackName) {
        User existing = findAppUserByAuthId(authUserId);
        if (existing != null) {
            db.userDao().insert(existing);
            return existing;
        }

        String displayName = (fallbackName == null || fallbackName.trim().isEmpty())
                ? displayNameFrom(email) : fallbackName.trim();

        User localUser = new User(
                authUserId, displayName, email, "", AppConstants.ROLE_CONSUMER,
                "", "VERIFIED", false
        );

        // Always save locally so the user is never blocked from using the app
        db.userDao().insert(localUser);

        try {
            User created = SupabaseRest.upsert("users",
                    newUserProfileRow(authUserId, email, displayName), User.class);
            if (created != null) {
                profileWriteFailed = false;
                db.userDao().insert(created);
                return created;
            }
            profileWriteFailed = true;
        } catch (Exception e) {
            profileWriteFailed = true;
            Log.w(TAG, "Remote user profile creation failed: " + e.getMessage());
            // Do not give up. An account with no public.users row is anonymous to every Row
            // Level Security policy, so nothing the user does is stored anywhere — which is
            // exactly the symptom this queue exists to fix. The payload carries authUserId,
            // so the next sync can retry the insert until the server accepts it.
            SyncEngine.enqueuePayload(db, "users", authUserId,
                    newUserProfileRow(authUserId, email, displayName));
            requestAutoSync();
        }

        return localUser;
    }

    /** True when the last profile creation reached the device but not the server. */
    public boolean didProfileWriteFail() {
        return profileWriteFailed;
    }

    /**
     * The exact row a self-registered account inserts into {@code public.users}.
     *
     * <p>Column names have to match the table exactly. An earlier version also sent
     * {@code auth_user_id}, {@code verification_status} and {@code is_blocked} — columns that do
     * not exist — and PostgREST rejects the WHOLE insert when one column is unknown. No profile
     * row was ever created, so a brand-new account was anonymous to every policy that resolves the
     * caller through {@code current_app_user_id()}: the app looked empty and every write failed.
     *
     * <p>The role sent here must also satisfy the {@code users_insert_self} policy, which allows
     * insert only as CONSUMER or HOST. That is the same rule that makes one account able to be both:
     * host authority comes from station ownership, not from the role column.
     *
     * <p>Package-private so it can be asserted against {@code supabase/schema.sql} in a unit test.
     */
    @NonNull
    static Map<String, Object> newUserProfileRow(@NonNull String id, @Nullable String email,
                                                @NonNull String displayName) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("id", id);
        row.put("authUserId", id);
        row.put("email", email);
        row.put("name", displayName);
        row.put("phone", "");
        row.put("role", AppConstants.ROLE_CONSUMER);
        row.put("organizationName", "");
        row.put("verificationStatus", "VERIFIED");
        row.put("isBlocked", false);
        return row;
    }

    private static String displayNameFrom(String email) {
        if (email == null || email.trim().isEmpty()) {
            return "Amperly user";
        }
        int at = email.indexOf('@');
        return at > 0 ? email.substring(0, at) : email.trim();
    }

    /**
     * Wipes every local table and the sync cursors.
     *
     * <p>Two uses. Leaving offline demo mode, so the seeded demo rows can never be pushed
     * into a real project; and signing out, so one account's reservations and receipts are
     * not left on screen for whoever signs in next.
     */
    public void clearLocalData() {
        db.clearAllTables();
        SyncEngine.reset(appContext, db);
    }

    public void insertUser(User user) {
        run(() -> {
            db.userDao().insert(user);
            syncUpsert("users", user);
        });
    }

    public void updateUser(User user) {
        run(() -> {
            db.userDao().insert(user);
            // An update, not an upsert: users_insert_self would be checked against the
            // proposed insert row and refuse a change that is only meant to update.
            SyncEngine.enqueueUpdate(db, "users", user.getId(), user);
            requestAutoSync();
        });
    }

    /**
     * Renames the signed-in account, locally and on the server.
     *
     * <p>The local row is written first and the server change is queued, like every other write
     * in the app, so a rename made offline still sticks and is pushed on the next sync rather
     * than being silently lost.
     *
     * <p>Only {@code id} and {@code name} are sent. The {@code users_update_self_or_admin} policy
     * lets a person update their own row, while {@code prevent_privilege_escalation} refuses any
     * change to role, blocked state or verification — none of which this payload carries.
     *
     * <p>Must be called off the main thread (Room); the caller gets the updated entity back.
     */
    @Nullable
    public User updateDisplayName(@Nullable User user, @Nullable String newName) {
        if (user == null) {
            return null;
        }
        String name = newName == null ? "" : newName.trim();
        if (name.isEmpty()) {
            return null;
        }

        user.setName(name);
        // insert(REPLACE) rather than update(): the row is written even if it is somehow not
        // in Room yet, so the local copy can never be the reason a rename appears to vanish.
        db.userDao().insert(user);

        // Also update the AuthManager's user object so the UI reflects the change immediately
        AuthManager.getInstance().setCurrentUser(user);

        // A rename only changes one column of a row that already exists, so it is queued as an
        // update (PATCH). Sending it as an upsert made the server evaluate users_insert_self
        // against a half-filled insert row, which it refused — the name stayed on the device.
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("name", name);
        SyncEngine.enqueueUpdate(db, "users", user.getId(), row);
        requestAutoSync();
        return user;
    }

    // ------------------------------------------------------------- vehicles

    public LiveData<Vehicle> observeVehicle(String userId) {
        return db.vehicleDao().getVehicleByUserId(userId);
    }

    public Vehicle getVehicleSync(String userId) {
        return db.vehicleDao().getVehicleByUserIdSync(userId);
    }

    public void saveVehicle(Vehicle vehicle) {
        run(() -> {
            db.vehicleDao().insert(vehicle);
            syncUpsert("vehicles", vehicle);
        });
    }

    // ------------------------------------------------------------- stations

    public LiveData<List<ChargerStation>> observeAllStations() {
        return db.chargerStationDao().getAllStations();
    }

    public LiveData<List<ChargerStation>> observePendingStations() {
        return db.chargerStationDao().getPendingStations();
    }

    public LiveData<List<ChargerStation>> observeStationsForHost(String hostId) {
        return db.chargerStationDao().getStationsByHost(hostId);
    }

    public LiveData<ChargerStation> observeStation(String stationId) {
        return db.chargerStationDao().getStationById(stationId);
    }

    public List<ChargerStation> getAllStationsSync() {
        return db.chargerStationDao().getAllStationsSync();
    }

    public List<ChargerStation> getApprovedStationsSync() {
        return db.chargerStationDao().getApprovedStationsSync();
    }

    public List<ChargerStation> getPendingStationsSync() {
        return db.chargerStationDao().getPendingStationsSync();
    }

    public List<ChargerStation> getStationsForHostSync(String hostId) {
        return db.chargerStationDao().getStationsByHostSync(hostId);
    }

    public ChargerStation getStationSync(String stationId) {
        return db.chargerStationDao().getStationByIdSync(stationId);
    }

    public void saveStation(ChargerStation station) {
        run(() -> {
            db.chargerStationDao().insert(station);
            syncUpsert("charger_stations", station);
        });
    }

    public void updateStation(ChargerStation station) {
        run(() -> {
            db.chargerStationDao().update(station);
            syncUpsert("charger_stations", station);
        });
    }

    /**
     * Local-only station write. Used where the server already made the change through
     * one of the settlement functions and pushing the row as well would apply it twice.
     */
    public void updateStationLocally(ChargerStation station) {
        run(() -> db.chargerStationDao().update(station));
    }

    public void setStationPaused(ChargerStation station, boolean paused) {
        run(() -> {
            station.setPaused(paused);
            station.setLastUpdatedMs(System.currentTimeMillis());
            db.chargerStationDao().update(station);
            syncUpsert("charger_stations", station);
        });
    }

    // ---------------------------------------------------------------- ports

    public LiveData<List<ChargerPort>> observePorts(String stationId) {
        return db.chargerPortDao().getPortsForStation(stationId);
    }

    public List<ChargerPort> getPortsSync(String stationId) {
        return db.chargerPortDao().getPortsForStationSync(stationId);
    }

    public List<ChargerPort> getAllPortsSync() {
        return db.chargerPortDao().getAllPortsSync();
    }

    public void savePort(ChargerPort port) {
        run(() -> {
            db.chargerPortDao().insert(port);
            syncUpsert("charger_ports", port);
        });
    }

    public void savePorts(List<ChargerPort> ports) {
        run(() -> {
            db.chargerPortDao().insertAll(ports);
            syncUpsertAll("charger_ports", ports);
        });
    }

    public void setPortStatus(ChargerPort port, String status) {
        run(() -> {
            port.setStatus(status);
            db.chargerPortDao().update(port);
            syncUpsert("charger_ports", port);
        });
    }

    // ----------------------------------------------------------- schedules

    public List<AvailabilitySchedule> getSchedulesSync(String stationId) {
        return db.availabilityScheduleDao().getSchedulesForStationSync(stationId);
    }

    public List<AvailabilitySchedule> getAllSchedulesSync() {
        return db.availabilityScheduleDao().getAllSchedulesSync();
    }

    public void saveSchedules(List<AvailabilitySchedule> schedules) {
        run(() -> {
            db.availabilityScheduleDao().insertAll(schedules);
            syncUpsertAll("availability_schedules", schedules);
        });
    }

    public void blockStation(String stationId, boolean blocked, String reason) {
        run(() -> {
            db.availabilityScheduleDao().setStationBlocked(stationId, blocked, reason,
                    System.currentTimeMillis());
            // The block is a bulk update, so re-read what changed and queue those rows.
            syncUpsertAll("availability_schedules",
                    db.availabilityScheduleDao().getSchedulesForStationSync(stationId));
        });
    }

    public void blockPort(String portId, String reason) {
        run(() -> {
            db.availabilityScheduleDao().blockPort(portId, reason, System.currentTimeMillis());
            for (int day = 1; day <= 7; day++) {
                AvailabilitySchedule schedule =
                        db.availabilityScheduleDao().getScheduleForPortDaySync(portId, day);
                if (schedule != null) {
                    syncUpsert("availability_schedules", schedule);
                }
            }
        });
    }

    // --------------------------------------------------------- availability

    public List<AvailabilityEngine.Slot> getSlots(String stationId, long dayStartMs, int slotMinutes,
                                                 int maxSlots) {
        ChargerStation station = getStationSync(stationId);
        if (station == null) {
            return Collections.emptyList();
        }
        return AvailabilityEngine.generateSlots(station, getPortsSync(stationId),
                getSchedulesSync(stationId), getReservationsForStationSync(stationId),
                dayStartMs, slotMinutes, maxSlots);
    }

    public AvailabilityEngine.AvailabilitySummary getAvailabilitySummary(String stationId) {
        ChargerStation station = getStationSync(stationId);
        if (station == null) {
            return new AvailabilityEngine.AvailabilitySummary(0, 0, 0, System.currentTimeMillis(),
                    false, "Station not found");
        }
        return AvailabilityEngine.summarise(station, getPortsSync(stationId),
                getSchedulesSync(stationId), getReservationsForStationSync(stationId),
                System.currentTimeMillis());
    }

    // --------------------------------------------------------- reservations

    public LiveData<List<Reservation>> observeReservationsForConsumer(String consumerId) {
        return db.reservationDao().getReservationsForConsumer(consumerId);
    }

    public LiveData<List<Reservation>> observeReservationsForHost(String hostId) {
        return db.reservationDao().getReservationsForHost(hostId);
    }

    public List<Reservation> getReservationsForConsumerSync(String consumerId) {
        return db.reservationDao().getReservationsForConsumerSync(consumerId);
    }

    public List<Reservation> getReservationsForHostSync(String hostId) {
        return db.reservationDao().getReservationsForHostSync(hostId);
    }

    public List<Reservation> getReservationsForStationSync(String stationId) {
        return db.reservationDao().getReservationsForStationSync(stationId);
    }

    public Reservation getActiveReservationSync(String consumerId) {
        return db.reservationDao().getActiveReservationForConsumerSync(consumerId);
    }

    public Reservation getReservationSync(String reservationId) {
        return db.reservationDao().getReservationByIdSync(reservationId);
    }

    public Reservation getReservationByCodeSync(String bookingCode) {
        return db.reservationDao().getReservationByBookingCodeSync(bookingCode);
    }

    public int countSlotConflicts(String portId, long startMs, long endMs) {
        return db.reservationDao().countConflicts(portId, startMs, endMs);
    }

    public void saveReservation(Reservation reservation) {
        run(() -> {
            db.reservationDao().insert(reservation);
            syncUpsert("reservations", reservation);
        });
    }

    public void updateReservation(Reservation reservation) {
        run(() -> {
            db.reservationDao().update(reservation);
            syncUpsert("reservations", reservation);
        });
    }

    // ------------------------------------------------------------- sessions

    public LiveData<List<ChargingSession>> observeSessionsForConsumer(String consumerId) {
        return db.chargingSessionDao().getSessionsForConsumer(consumerId);
    }

    public LiveData<List<ChargingSession>> observeSessionsForHost(String hostId) {
        return db.chargingSessionDao().getSessionsForHost(hostId);
    }

    public List<ChargingSession> getSessionsForConsumerSync(String consumerId) {
        return db.chargingSessionDao().getSessionsForConsumerSync(consumerId);
    }

    public List<ChargingSession> getSessionsForHostSync(String hostId) {
        return db.chargingSessionDao().getSessionsForHostSync(hostId);
    }

    public List<ChargingSession> getAllSessionsSync() {
        return db.chargingSessionDao().getAllSessionsSync();
    }

    public ChargingSession getSessionSync(String sessionId) {
        return db.chargingSessionDao().getSessionByIdSync(sessionId);
    }

    public ChargingSession getSessionByReservationSync(String reservationId) {
        return db.chargingSessionDao().getSessionByReservationSync(reservationId);
    }

    public void saveSession(ChargingSession session) {
        run(() -> {
            db.chargingSessionDao().insert(session);
            syncUpsert("charging_sessions", session);
        });
    }

    public void updateSession(ChargingSession session) {
        run(() -> {
            db.chargingSessionDao().update(session);
            syncUpsert("charging_sessions", session);
        });
    }

    /**
     * Completes a session on the server (finalize_charging_session).
     *
     * <p>The server recomputes the bill from the meter readings and the station's
     * tariff, writes the session, the reading, the receipt and the capture in one
     * transaction, closes the reservation and frees the port. The local rows written
     * here are the offline copy — the same figures, computed by the app's BillingEngine
     * — and are replaced by the server's rows on the next pull.
     */
    public void finalizeSession(ChargingSession session, MeterReading reading, Invoice invoice,
                                Payment payment, Reservation reservation) {
        run(() -> {
            db.chargingSessionDao().insert(session);
            if (reading != null) {
                db.meterReadingDao().insert(reading);
            }
            if (invoice != null) {
                db.invoiceDao().insert(invoice);
            }
            if (payment != null) {
                db.paymentDao().insert(payment);
            }
            if (reservation != null) {
                db.reservationDao().update(reservation);
            }

            Map<String, Object> args = new LinkedHashMap<>();
            args.put("p_session_id", session.getId());
            args.put("p_reservation_id", session.getReservationId());
            args.put("p_start_meter_kwh", session.getStartingMeterKwh());
            args.put("p_end_meter_kwh", session.getEndingMeterKwh());
            args.put("p_is_simulated", session.isMeterSimulated());
            args.put("p_meter_reading_id", reading == null ? null : reading.getId());
            args.put("p_invoice_id", invoice == null ? null : invoice.getId());
            syncRpc("finalize_charging_session", session.getId(), args);
        });
    }

    // ------------------------------------------------------- admin transitions
    // Each of these asks the server to make the change (the function re-checks that
    // the caller is an administrator) and writes the local rows for immediate display.

    /** Approves or rejects a station listing (decide_station_approval). */
    public void decideStationApprovalOnServer(ChargerStation station, boolean approve) {
        run(() -> {
            db.chargerStationDao().update(station);
            Map<String, Object> args = new LinkedHashMap<>();
            args.put("p_station_id", station.getId());
            args.put("p_approve", approve);
            syncRpc("decide_station_approval", station.getId(), args);
        });
    }

    /** Refunds a dispute from the invoice's energy charge (resolve_dispute_refund). */
    public void resolveDisputeRefundOnServer(Dispute dispute, Invoice invoice) {
        run(() -> {
            db.disputeDao().update(dispute);
            if (invoice != null) {
                db.invoiceDao().update(invoice);
            }
            syncRpc("resolve_dispute_refund", dispute.getId(),
                    singleArg("p_dispute_id", dispute.getId()));
        });
    }

    /** Holds a host's payout while a dispute is reviewed (freeze_dispute_payout). */
    public void freezeDisputePayoutOnServer(Dispute dispute) {
        run(() -> {
            db.disputeDao().update(dispute);
            syncRpc("freeze_dispute_payout", dispute.getId(),
                    singleArg("p_dispute_id", dispute.getId()));
        });
    }

    /** Records an enforcement action against a host (apply_host_enforcement). */
    public void applyHostEnforcementOnServer(Dispute dispute, String action, double fineAmount,
                                             String note) {
        run(() -> {
            db.disputeDao().update(dispute);
            Map<String, Object> args = new LinkedHashMap<>();
            args.put("p_dispute_id", dispute.getId());
            args.put("p_action", action);
            args.put("p_fine_amount", fineAmount);
            args.put("p_note", note);
            syncRpc("apply_host_enforcement", dispute.getId(), args);
        });
    }

    // -------------------------------------------------------- meter readings

    public void saveMeterReading(MeterReading reading) {
        run(() -> {
            db.meterReadingDao().insert(reading);
            syncUpsert("meter_readings", reading);
        });
    }

    public MeterReading getLatestMeterReadingSync(String sessionId) {
        return db.meterReadingDao().getLatestForSessionSync(sessionId);
    }

    public List<MeterReading> getMeterReadingsSync(String sessionId) {
        return db.meterReadingDao().getReadingsForSessionSync(sessionId);
    }

    public List<MeterReading> getAllMeterReadingsSync() {
        return db.meterReadingDao().getAllReadingsSync();
    }

    // --------------------------------------------------------------- invoices

    public LiveData<List<Invoice>> observeInvoices(String consumerId) {
        return db.invoiceDao().getInvoicesForConsumer(consumerId);
    }

    /**
     * Stores an invoice locally. The server issues the real receipt from
     * finalize_charging_session() and adjusts it from resolve_dispute_refund(), so
     * these are offline views of the server's row and are not pushed.
     */
    public void saveInvoice(Invoice invoice) {
        run(() -> db.invoiceDao().insert(invoice));
    }

    public void updateInvoice(Invoice invoice) {
        run(() -> db.invoiceDao().update(invoice));
    }

    public Invoice getInvoiceSync(String invoiceId) {
        return db.invoiceDao().getInvoiceByIdSync(invoiceId);
    }

    public Invoice getInvoiceBySessionSync(String sessionId) {
        return db.invoiceDao().getInvoiceBySessionSync(sessionId);
    }

    public List<Invoice> getInvoicesForHostSync(String hostId) {
        return db.invoiceDao().getInvoicesForHostSync(hostId);
    }

    public List<Invoice> getInvoicesForConsumerSync(String consumerId) {
        return db.invoiceDao().getInvoicesForConsumerSync(consumerId);
    }

    public List<Invoice> getAllInvoicesSync() {
        return db.invoiceDao().getAllInvoicesSync();
    }

    // --------------------------------------------------------------- payments

    /**
     * Stores a payment locally, for the UI and for offline reads.
     *
     * <p>The payments table is no longer written by a client: the row is created by
     * {@link #authorizePayment} and its money fields are set by the settlement
     * functions, so pushing this row would be refused by Row Level Security anyway.
     */
    public void savePayment(Payment payment) {
        run(() -> db.paymentDao().insert(payment));
    }

    /** Creates the authorization on the server (authorize_payment). */
    public void authorizePayment(Payment payment, String stationId) {
        run(() -> {
            db.paymentDao().insert(payment);
            Map<String, Object> args = new LinkedHashMap<>();
            args.put("p_id", payment.getId());
            args.put("p_reservation_id", payment.getReservationId());
            args.put("p_station_id", stationId);
            args.put("p_amount", payment.getAuthorizedAmount());
            args.put("p_idempotency_key", payment.getIdempotencyKey());
            syncRpc("authorize_payment", payment.getId(), args);
        });
    }

    /**
     * Cancels on the server (cancel_reservation), which is where the published
     * late-cancellation policy and the release of the authorization are applied. The
     * local reservation and payment rows are still updated by the caller for the UI.
     */
    public void cancelReservationOnServer(String reservationId) {
        run(() -> syncRpc("cancel_reservation", reservationId,
                singleArg("p_reservation_id", reservationId)));
    }

    public Payment findPaymentByKey(String idempotencyKey) {
        return db.paymentDao().findByIdempotencyKey(idempotencyKey);
    }

    public Payment getPaymentForReservationSync(String reservationId) {
        return db.paymentDao().getPaymentForReservationSync(reservationId);
    }

    public Payment getPaymentForSessionSync(String sessionId) {
        return db.paymentDao().getPaymentForSessionSync(sessionId);
    }

    public List<Payment> getPaymentsForHostSync(String hostId) {
        return db.paymentDao().getPaymentsForHostSync(hostId);
    }

    // -------------------------------------------------------------- disputes

    public LiveData<List<Dispute>> observeDisputes() {
        return db.disputeDao().getAllDisputes();
    }

    public List<Dispute> getDisputesSync() {
        return db.disputeDao().getAllDisputesSync();
    }

    public List<Dispute> getOpenDisputesSync() {
        return db.disputeDao().getOpenDisputesSync();
    }

    public List<Dispute> getDisputesForHostSync(String hostId) {
        return db.disputeDao().getDisputesForHostSync(hostId);
    }

    public Dispute getDisputeSync(String disputeId) {
        return db.disputeDao().getDisputeByIdSync(disputeId);
    }

    public void saveDispute(Dispute dispute) {
        run(() -> {
            db.disputeDao().insert(dispute);
            syncUpsert("disputes", dispute);
        });
    }

    public void updateDispute(Dispute dispute) {
        run(() -> {
            db.disputeDao().update(dispute);
            syncUpsert("disputes", dispute);
        });
    }

    public int countProvenIncidents(String hostId) {
        return db.disputeDao().countProvenIncidentsForHost(hostId);
    }

    // --------------------------------------------------------------- reports

    public LiveData<List<Report>> observeReports() {
        return db.reportDao().getAllReports();
    }

    public List<Report> getAllReportsSync() {
        return db.reportDao().getAllReportsSync();
    }

    public List<Report> getOpenReportsSync() {
        return db.reportDao().getOpenReportsSync();
    }

    public List<Report> getReportsForStationSync(String stationId) {
        return db.reportDao().getReportsForStationSync(stationId);
    }

    public void saveReport(Report report) {
        run(() -> {
            db.reportDao().insert(report);
            syncUpsert("reports", report);
        });
    }

    // ----------------------------------------------------------- enforcement

    public void saveEnforcementAction(HostEnforcementAction action) {
        run(() -> {
            db.hostEnforcementActionDao().insert(action);
            syncUpsert("host_enforcements", action);
        });
    }

    public List<HostEnforcementAction> getEnforcementForHostSync(String hostId) {
        return db.hostEnforcementActionDao().getActionsForHostSync(hostId);
    }

    public List<HostEnforcementAction> getEnforcementForStationSync(String stationId) {
        return db.hostEnforcementActionDao().getActionsForStationSync(stationId);
    }

    public List<HostEnforcementAction> getAllEnforcementSync() {
        return db.hostEnforcementActionDao().getAllActionsSync();
    }

    // --------------------------------------------------------- notifications

    public LiveData<List<Notification>> observeNotifications(String userId) {
        return db.notificationDao().getNotificationsForUser(userId);
    }

    public List<Notification> getNotificationsSync(String userId) {
        return db.notificationDao().getNotificationsForUserSync(userId);
    }

    public void saveNotification(Notification notification) {
        run(() -> {
            db.notificationDao().insert(notification);
            syncUpsert("notifications", notification);
        });
    }

    public void markNotificationsRead(String userId) {
        run(() -> {
            db.notificationDao().markAllRead(userId);
            syncUpsertAll("notifications", db.notificationDao().getNotificationsForUserSync(userId));
        });
    }

    // ------------------------------------------------------------------ chat

    public LiveData<List<CommunicationThread>> observeThreadsForConsumer(String consumerId) {
        return db.communicationThreadDao().getThreadsForConsumer(consumerId);
    }

    public LiveData<List<CommunicationThread>> observeThreadsForHost(String hostId) {
        return db.communicationThreadDao().getThreadsForHost(hostId);
    }

    public CommunicationThread getThreadByReservationSync(String reservationId) {
        return db.communicationThreadDao().getThreadByReservationSync(reservationId);
    }

    public List<CommunicationThread> getAllThreadsSync() {
        return db.communicationThreadDao().getAllThreadsSync();
    }

    public void saveThread(CommunicationThread thread) {
        run(() -> {
            db.communicationThreadDao().insert(thread);
            syncUpsert("communication_threads", thread);
        });
    }

    public void updateThread(CommunicationThread thread) {
        run(() -> {
            db.communicationThreadDao().update(thread);
            syncUpsert("communication_threads", thread);
        });
    }

    public void reportThread(String threadId) {
        run(() -> {
            db.communicationThreadDao().markReported(threadId);
            CommunicationThread thread = db.communicationThreadDao().getThreadByIdSync(threadId);
            if (thread != null) {
                syncUpsert("communication_threads", thread);
            }
        });
    }

    public void blockThread(String threadId) {
        run(() -> {
            db.communicationThreadDao().block(threadId);
            CommunicationThread thread = db.communicationThreadDao().getThreadByIdSync(threadId);
            if (thread != null) {
                syncUpsert("communication_threads", thread);
            }
        });
    }

    public LiveData<List<ChatMessage>> observeMessages(String threadId) {
        return db.chatMessageDao().getMessagesForThread(threadId);
    }

    public List<ChatMessage> getMessagesSync(String threadId) {
        return db.chatMessageDao().getMessagesForThreadSync(threadId);
    }

    public List<ChatMessage> getAllMessagesSync() {
        return db.chatMessageDao().getAllMessagesSync();
    }

    public void saveMessage(ChatMessage message) {
        run(() -> {
            db.chatMessageDao().insert(message);
            syncUpsert("chat_messages", message);
        });
    }

    public void reportMessage(String messageId) {
        run(() -> {
            db.chatMessageDao().markReported(messageId);
            ChatMessage message = db.chatMessageDao().getMessageByIdSync(messageId);
            if (message != null) {
                syncUpsert("chat_messages", message);
            }
        });
    }

    public void purgeExpiredMessages() {
        run(() -> db.chatMessageDao().purgeExpired(System.currentTimeMillis()));
    }

    // ---------------------------------------------------------------- safety

    public LiveData<List<SafetyEvent>> observeSafetyEvents(String consumerId) {
        return db.safetyEventDao().getEventsForConsumer(consumerId);
    }

    public List<SafetyEvent> getSafetyEventsSync(String consumerId) {
        return db.safetyEventDao().getEventsForConsumerSync(consumerId);
    }

    public SafetyEvent getActiveLocationSharingSync(String consumerId) {
        return db.safetyEventDao().getActiveSharingSync(consumerId, System.currentTimeMillis());
    }

    public void saveSafetyEvent(SafetyEvent event) {
        run(() -> {
            db.safetyEventDao().insert(event);
            syncUpsert("safety_events", event);
        });
    }

    public void updateSafetyEvent(SafetyEvent event) {
        run(() -> {
            db.safetyEventDao().update(event);
            syncUpsert("safety_events", event);
        });
    }

    public void expireStaleLocationSharing() {
        run(() -> db.safetyEventDao().expireStaleSharing(System.currentTimeMillis()));
    }

    public LiveData<List<TrustedContact>> observeTrustedContacts(String userId) {
        return db.trustedContactDao().getContactsForUser(userId);
    }

    public List<TrustedContact> getTrustedContactsSync(String userId) {
        return db.trustedContactDao().getContactsForUserSync(userId);
    }

    public void saveTrustedContact(TrustedContact contact) {
        run(() -> {
            db.trustedContactDao().insert(contact);
            syncUpsert("trusted_contacts", contact);
        });
    }

    public void deleteTrustedContact(TrustedContact contact) {
        run(() -> {
            db.trustedContactDao().delete(contact);
            syncDelete("trusted_contacts", contact);
        });
    }

    // ---------------------------------------------------------- route plans

    public LiveData<List<RoutePlan>> observeRoutePlans(String consumerId) {
        return db.routePlanDao().getPlansForConsumer(consumerId);
    }

    public RoutePlan getRoutePlanSync(String planId) {
        return db.routePlanDao().getPlanByIdSync(planId);
    }

    public RoutePlan getActiveRoutePlanSync(String consumerId) {
        return db.routePlanDao().getActivePlanSync(consumerId);
    }

    public List<RoutePlan> getRoutePlansSync(String consumerId) {
        return db.routePlanDao().getPlansForConsumerSync(consumerId);
    }

    public void saveRoutePlan(RoutePlan plan) {
        run(() -> {
            db.routePlanDao().insert(plan);
            syncUpsert("route_plans", plan);
        });
    }

    public void updateRoutePlan(RoutePlan plan) {
        run(() -> {
            db.routePlanDao().update(plan);
            syncUpsert("route_plans", plan);
        });
    }

    public List<RouteStop> getRouteStopsSync(String planId) {
        return db.routeStopDao().getStopsForPlanSync(planId);
    }

    public List<RouteStop> getBackupStopsSync(String planId) {
        return db.routeStopDao().getBackupStopsSync(planId);
    }

    public void saveRouteStops(List<RouteStop> stops) {
        run(() -> {
            db.routeStopDao().insertAll(stops);
            syncUpsertAll("route_stops", stops);
        });
    }

    public void replaceRouteStops(String planId, List<RouteStop> stops) {
        run(() -> {
            db.routeStopDao().deleteStopsForPlan(planId);
            if (stops != null && !stops.isEmpty()) {
                db.routeStopDao().insertAll(stops);
            }
        });
    }

    // -------------------------------------------------------- trip estimates

    public void saveTripEstimate(TripEstimate estimate) {
        run(() -> {
            db.tripEstimateDao().insert(estimate);
            syncUpsert("trip_estimates", estimate);
        });
    }

    public List<TripEstimate> getTripEstimatesSync(String vehicleId) {
        return db.tripEstimateDao().getEstimatesForVehicleSync(vehicleId);
    }

    public List<TripEstimate> getTripEstimatesForPlanSync(String planId) {
        return db.tripEstimateDao().getEstimatesForPlanSync(planId);
    }

    public List<TripEstimate> getAllTripEstimatesSync() {
        return db.tripEstimateDao().getAllEstimatesSync();
    }

    public double averageDriftKwh(String vehicleId) {
        return db.tripEstimateDao().averageDriftForVehicle(vehicleId);
    }

    // -------------------------------------------------------- battery updates

    public void saveBatteryUpdate(BatteryUpdate update) {
        run(() -> {
            db.batteryUpdateDao().insert(update);
            syncUpsert("battery_updates", update);
        });
    }

    public List<BatteryUpdate> getBatteryUpdatesSync(String planId) {
        return db.batteryUpdateDao().getUpdatesForTripSync(planId);
    }

    public BatteryUpdate getLatestBatteryUpdateSync(String planId) {
        return db.batteryUpdateDao().getLatestForTripSync(planId);
    }

    public List<BatteryUpdate> getAllBatteryUpdatesSync() {
        return db.batteryUpdateDao().getAllUpdatesSync();
    }

    // --------------------------------------------------- android auto session

    public void saveAutoSession(AndroidAutoSession session) {
        run(() -> {
            db.androidAutoSessionDao().insert(session);
            syncUpsert("android_auto_sessions", session);
        });
    }

    public AndroidAutoSession getLatestAutoSessionSync(String userId) {
        return db.androidAutoSessionDao().getLatestForUserSync(userId);
    }

    public List<AndroidAutoSession> getAutoSessionsSync(String userId) {
        return db.androidAutoSessionDao().getSessionsForUserSync(userId);
    }

    // ------------------------------------------------------------- analytics

    public HostAnalyticsEngine.HostAnalytics hostAnalytics(String hostId) {
        List<ChargerStation> stations = getStationsForHostSync(hostId);
        List<ChargerPort> ports = new ArrayList<>();
        for (ChargerStation station : stations) {
            ports.addAll(getPortsSync(station.getId()));
        }
        List<Dispute> disputes = getDisputesForHostSync(hostId);
        return HostAnalyticsEngine.compute(stations, ports, getSessionsForHostSync(hostId),
                getReservationsForHostSync(hostId), getInvoicesForHostSync(hostId), disputes);
    }

    public HostAnalyticsEngine.HostAnalytics platformAnalytics() {
        List<ChargerStation> stations = getAllStationsSync();
        List<ChargerPort> ports = getAllPortsSync();
        return HostAnalyticsEngine.compute(stations, ports, getAllSessionsSync(),
                new ArrayList<>(), getAllInvoicesSync(), getDisputesSync());
    }

    public int stationCount() {
        return db.chargerStationDao().countStations();
    }

    public int userCount() {
        return db.userDao().countUsers();
    }
}
