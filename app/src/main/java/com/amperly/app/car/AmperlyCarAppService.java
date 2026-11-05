package com.amperly.app.car;

import android.content.pm.ApplicationInfo;

import androidx.annotation.NonNull;
import androidx.car.app.CarAppService;
import androidx.car.app.Session;
import androidx.car.app.validation.HostValidator;

import com.amperly.app.R;

public class AmperlyCarAppService extends CarAppService {

    @NonNull
    @Override
    public HostValidator createHostValidator() {
        // Sideloaded builds and the Desktop Head Unit are not signed like the production host, so
        // debug builds accept any host. Release builds only accept the Android Auto and Google
        // Automotive host signatures from the Car App Library's maintained allowlist.
        if ((getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            return HostValidator.ALLOW_ALL_HOSTS_VALIDATOR;
        }
        return new HostValidator.Builder(getApplicationContext())
                .addAllowedHosts(R.array.car_hosts_allowlist)
                .build();
    }

    @NonNull
    @Override
    public Session onCreateSession() {
        return new AmperlyCarSession();
    }
}
