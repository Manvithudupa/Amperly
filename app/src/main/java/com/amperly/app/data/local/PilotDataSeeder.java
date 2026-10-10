package com.amperly.app.data.local;

import android.content.Context;

import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;

public class PilotDataSeeder {

    public static void seedPilotData(Context context) {
        AmperlyRepository repo = AmperlyRepository.getInstance(context);

        User campusAdmin = new User("user_campus_admin", "ABC College Admin", "admin@abccollege.edu", "+919876543210", "HOST");
        User studentConsumer = new User("user_student_1", "Aarav Student", "aarav@abccollege.edu", "+919876543211", "CONSUMER");

        repo.insertUser(campusAdmin);
        repo.insertUser(studentConsumer);

        Vehicle studentVehicle = new Vehicle(
                "veh_101", "user_student_1", "Tata", "Nexon EV", "Max",
                2023, 40.5, "CCS_2_DC", 7.2, 30.0, 6.5, 2.0, 15, 80, "KA09EV1234"
        );
        repo.insertVehicle(studentVehicle);

        ChargerStation campusStation = new ChargerStation(
                "st_campus_1", "user_campus_admin", "ABC College Campus Charger",
                "Gate 2 Parking, ABC Campus, Mysore", 12.301, 76.652, "CAMPUS",
                "08:00 - 20:00", 18.0, 5.0, 4.0, "LEVEL_1", true, false, 4.9, System.currentTimeMillis()
        );
        repo.insertStation(campusStation);

        User aptHost = new User("user_apt_association", "GreenPark Association", "president@greenpark.org", "+919876543220", "HOST");
        repo.insertUser(aptHost);

        ChargerStation aptStation = new ChargerStation(
                "st_apt_1", "user_apt_association", "GreenPark Shared Charger",
                "Visitor Parking, GreenPark Apts, Mysore", 12.310, 76.640, "APARTMENT",
                "24/7", 16.0, 5.0, 4.0, "LEVEL_1", true, false, 4.7, System.currentTimeMillis()
        );
        repo.insertStation(aptStation);
    }
}
