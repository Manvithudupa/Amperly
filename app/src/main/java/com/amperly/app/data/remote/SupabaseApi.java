package com.amperly.app.data.remote;

import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.User;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface SupabaseApi {
    @GET("users")
    Call<List<User>> getUsers(@Query("id") String idFilter);

    @POST("users")
    Call<List<User>> createUser(@Body User user);

    @GET("charger_stations")
    Call<List<ChargerStation>> getStations();

    @POST("charger_stations")
    Call<List<ChargerStation>> createStation(@Body ChargerStation station);

    @GET("reservations")
    Call<List<Reservation>> getReservations(@Query("consumer_id") String consumerIdFilter);

    @POST("reservations")
    Call<List<Reservation>> createReservation(@Body Reservation reservation);

    @GET("charging_sessions")
    Call<List<ChargingSession>> getChargingSessions(@Query("consumer_id") String consumerIdFilter);

    @POST("charging_sessions")
    Call<List<ChargingSession>> createChargingSession(@Body ChargingSession session);

    @GET("disputes")
    Call<List<Dispute>> getDisputes();

    @POST("disputes")
    Call<List<Dispute>> createDispute(@Body Dispute dispute);
}
