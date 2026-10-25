package com.amperly.app.data.remote;

import org.junit.Test;

import okhttp3.MediaType;
import okhttp3.ResponseBody;
import retrofit2.Response;

import static org.junit.Assert.assertTrue;

/**
 * How a server response is read.
 *
 * <p>Retrofit keeps a non-2xx payload in {@code errorBody()}, not {@code body()}. Reading only
 * the success body silently dropped every reason a server gave for refusing a call, which is
 * how one rejected sign-in turned into "check your internet connection". This test pins the
 * behaviour that keeps those messages.
 */
public class SupabaseRestTest {

    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");

    @Test
    public void anErrorResponseKeepsTheServersMessage() {
        ResponseBody error = ResponseBody.create(
                "{\"code\":400,\"error_code\":\"invalid_credentials\",\"msg\":\"Invalid login credentials\"}",
                JSON);

        String body = SupabaseRest.read(Response.error(400, error));

        assertTrue(body.contains("Invalid login credentials"));
        assertTrue(body.contains("invalid_credentials"));
    }

    @Test
    public void aSuccessfulResponseIsReadFromItsBody() {
        ResponseBody success = ResponseBody.create("{\"id\":\"veh_1\"}", JSON);

        String body = SupabaseRest.read(Response.success(success));

        assertTrue(body.contains("veh_1"));
    }
}
