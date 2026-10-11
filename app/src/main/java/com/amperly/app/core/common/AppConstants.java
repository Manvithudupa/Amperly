package com.amperly.app.core.common;

public class AppConstants {
    public static final String ROLE_CONSUMER = "CONSUMER";
    public static final String ROLE_HOST = "HOST";
    public static final String ROLE_ADMIN = "ADMIN";

    public static final double DEFAULT_SERVICE_FEE_INR = 5.0;
    public static final double DEFAULT_GATEWAY_FEE_INR = 4.0;
    public static final double DEFAULT_TARIFF_INR_PER_KWH = 18.0;

    public static final int DEFAULT_MIN_RESERVE_SOC_PERCENT = 15;
    public static final int DEFAULT_MAX_TARGET_SOC_PERCENT = 80;

    public static final String LEVEL_1_VERIFIED_MANUAL = "LEVEL_1";
    public static final String LEVEL_2_SIMULATED_SMART_METER = "LEVEL_2";
    public static final String LEVEL_3_NO_VERIFIED_METER = "LEVEL_3";

    public static final String LOCATION_TYPE_CAMPUS = "CAMPUS";
    public static final String LOCATION_TYPE_APARTMENT = "APARTMENT";
    public static final String LOCATION_TYPE_OFFICE = "OFFICE";
}
