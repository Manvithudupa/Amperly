package com.amperly.app;

import com.amperly.app.core.common.RequestSequence;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * The staleness rule behind address autocomplete.
 *
 * <p>Typing "Koramangala" starts more than one request. If the answer for "Kor" were applied after
 * the answer for "Koramangala", the driver would see a suggestion list that does not match the
 * field — and could pick, and then route to, the wrong place.
 */
public class RequestSequenceTest {

    @Test
    public void onlyTheNewestTokenIsCurrent() {
        RequestSequence sequence = new RequestSequence();
        int first = sequence.next();
        assertTrue(sequence.isCurrent(first));

        int second = sequence.next();
        assertTrue(sequence.isCurrent(second));
        assertFalse("the answer for the older query must be ignored", sequence.isCurrent(first));
    }

    @Test
    public void aTokenThatWasNeverIssuedIsNotCurrent() {
        RequestSequence sequence = new RequestSequence();
        sequence.next();
        assertFalse(sequence.isCurrent(0));
        assertFalse(sequence.isCurrent(99));
    }
}
