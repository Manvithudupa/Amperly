package com.amperly.app.car;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.constraints.ConstraintManager;

/** Reads the host's row limit and folds it into {@link CarLimits}. */
public final class CarConstraints {

    private CarConstraints() {
    }

    /**
     * The number of list rows this screen may draw.
     *
     * <p>{@link ConstraintManager} is available on every host that supports templates, but a host
     * can still refuse the call while a session is being torn down. In that case the screen's own
     * desired size is used, which is always a safe value.
     */
    public static int listLimit(@NonNull CarContext carContext, int desired) {
        int hostLimit = -1;
        try {
            ConstraintManager manager = carContext.getCarService(ConstraintManager.class);
            if (manager != null) {
                hostLimit = manager.getContentLimit(ConstraintManager.CONTENT_LIMIT_TYPE_LIST);
            }
        } catch (RuntimeException ignored) {
            // No constraint service in this host; fall back to the screen's own limit.
        }
        return CarLimits.listLimit(hostLimit, desired);
    }
}
