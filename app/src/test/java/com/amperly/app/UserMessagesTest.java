package com.amperly.app;

import com.amperly.app.core.common.GeoapifyErrors;
import com.amperly.app.core.common.UserMessages;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;

/**
 * The decision behind every error message the app shows.
 *
 * <p>The rule is pure, so it is tested directly: a map key that was rejected must read as a map
 * problem, a spent free-plan quota as "too many requests", a missing place as no results, and a
 * transport failure as offline. None of the technical text may decide the wording on its own.
 */
public class UserMessagesTest {

    @Test
    public void aRejectedGeoapifyKeyIsAMapProblem() {
        assertEquals(UserMessages.Kind.MAP_UNAVAILABLE,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(401)));
        assertEquals(UserMessages.Kind.MAP_UNAVAILABLE,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(403)));
    }

    @Test
    public void aSpentQuotaIsARateLimit() {
        assertEquals(UserMessages.Kind.RATE_LIMIT,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(429)));
        assertEquals(UserMessages.Kind.RATE_LIMIT,
                UserMessages.classify(-1, "Geoapify rate limit or daily credits exhausted."));
    }

    @Test
    public void aServerFailureAndAnInvalidRequestAreDistinguished() {
        assertEquals(UserMessages.Kind.SERVER,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(500)));
        assertEquals(UserMessages.Kind.SERVER,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(503)));
        assertEquals(UserMessages.Kind.VALIDATION,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(400)));
    }

    @Test
    public void aPlaceOrRouteThatDoesNotExistIsNoResults() {
        assertEquals(UserMessages.Kind.PLACE_NO_RESULTS,
                UserMessages.classify(-1, "Geoapify found no route between those points."));
        assertEquals(UserMessages.Kind.PLACE_NO_RESULTS,
                UserMessages.classify(-1, "Geoapify found no matching place."));
        assertEquals(UserMessages.Kind.PLACE_NO_RESULTS,
                UserMessages.classify(-1, "Geoapify found no address for that point."));
    }

    @Test
    public void theShapeOfTheKeyMattersNotTheWordKeyAlone() {
        // A Supabase message that mentions a key must not be relabelled as a map failure.
        assertNotEquals(UserMessages.Kind.MAP_UNAVAILABLE,
                UserMessages.classify(400, "Invalid API key"));
        assertEquals(UserMessages.Kind.VALIDATION,
                UserMessages.classify(400, "bad request"));
    }

    @Test
    public void aWrongPasswordIsNeverReportedAsANetworkProblem() {
        // GoTrue answers a rejected sign-in with 400 and this message. It used to reach the
        // screen as "check your internet connection", because the error body was discarded and
        // nothing was left to classify.
        assertEquals(UserMessages.Kind.AUTH_INVALID_CREDENTIALS,
                UserMessages.classify(400, "Invalid login credentials"));
        assertEquals(UserMessages.Kind.AUTH_INVALID_CREDENTIALS,
                UserMessages.classify(-1, "invalid_credentials"));
        assertEquals(UserMessages.Kind.AUTH_INVALID_CREDENTIALS,
                UserMessages.classify(400, "Invalid login credentials [invalid_credentials]"));
        assertEquals(UserMessages.Kind.AUTH_INVALID_CREDENTIALS,
                UserMessages.classify(400, "Incorrect password"));
        assertNotEquals(UserMessages.Kind.OFFLINE,
                UserMessages.classify(400, "Invalid login credentials"));
    }

    @Test
    public void transportAndDatabaseFailuresKeepTheirExistingMeaning() {
        assertEquals(UserMessages.Kind.OFFLINE, UserMessages.classify(0, null));
        assertEquals(UserMessages.Kind.OFFLINE,
                UserMessages.classify(-1, "Unable to resolve host \"example.com\""));
        assertEquals(UserMessages.Kind.PERMISSION,
                UserMessages.classify(-1, "JWT expired"));
        assertEquals(UserMessages.Kind.CONFLICT,
                UserMessages.classify(-1, "duplicate key value violates unique constraint"));
        assertEquals(UserMessages.Kind.NOT_FOUND, UserMessages.classify(404, null));
        assertEquals(UserMessages.Kind.RATE_LIMIT,
                UserMessages.classify(-1, "too many requests"));
        assertEquals(UserMessages.Kind.UNKNOWN, UserMessages.classify(-1, ""));
    }
}
