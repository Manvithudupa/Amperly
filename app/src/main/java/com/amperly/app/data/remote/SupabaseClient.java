package com.amperly.app.data.remote;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class SupabaseClient {
    private static final String DEFAULT_SUPABASE_URL = "https://your-project-id.supabase.co/rest/v1/";
    private static final String DEFAULT_SUPABASE_ANON_KEY = "your-supabase-anon-key";

    private static SupabaseApi instance;

    public static synchronized SupabaseApi getApi() {
        if (instance == null) {
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);

            OkHttpClient client = new OkHttpClient.Builder()
                    .addInterceptor(logging)
                    .addInterceptor(chain -> {
                        Request original = chain.request();
                        Request request = original.newBuilder()
                                .header("apikey", DEFAULT_SUPABASE_ANON_KEY)
                                .header("Authorization", "Bearer " + DEFAULT_SUPABASE_ANON_KEY)
                                .header("Content-Type", "application/json")
                                .header("Prefer", "return=representation")
                                .method(original.method(), original.body())
                                .build();
                        return chain.proceed(request);
                    })
                    .build();

            Retrofit retrofit = new Retrofit.Builder()
                    .baseUrl(DEFAULT_SUPABASE_URL)
                    .client(client)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build();

            instance = retrofit.create(SupabaseApi.class);
        }
        return instance;
    }
}
