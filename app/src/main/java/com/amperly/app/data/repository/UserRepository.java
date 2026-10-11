package com.amperly.app.data.repository;

import android.content.Context;

import androidx.lifecycle.LiveData;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.User;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class UserRepository {
    private static volatile UserRepository INSTANCE;
    private final AmperlyDatabase db;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);

    private UserRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
    }

    public static UserRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (UserRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new UserRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public LiveData<User> getUserById(String id) {
        return db.userDao().getUserById(id);
    }

    public void insertUser(User user) {
        executor.execute(() -> db.userDao().insert(user));
    }
}
