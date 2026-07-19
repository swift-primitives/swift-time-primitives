// Instant+Julian Tests.swift
// Time Primitives Tests
//
// Regression tests for fable-448 F-003: Julian Day -> Instant conversion yielded an
// invalid negative `nanosecondFraction` for pre-1970 (negative) Julian Days. Follows
// [INST-TEST-013]: an @Suite subdomain extension of the affected source type, with
// tests nested under the `Edge Case` sub-suite.

import Testing
import Time_Primitives

@testable import Time_Primitive

extension Instant {
    @Suite
    struct Tests {
        @Suite
        struct `Edge Case` {}
    }
}

extension Instant.Tests.`Edge Case` {

    // MARK: - nanosecondFraction invariant holds for pre-1970 Julian Days

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test(
        arguments: [
            // Non-"round" fractional-day offsets: whole-day and half-day offsets happen
            // to multiply out to an exact integer number of seconds even in the buggy
            // (truncating) implementation, so they don't exercise the bug. These
            // fractions deliberately do NOT align to a whole second, so
            // `days * secondsPerDay` lands mid-second and genuinely exercises the
            // truncate-vs-floor discrepancy for negative `totalSeconds`.
            Time.Julian.Day.unixEpoch - Time.Julian.Offset(1.123_456_789),  // ~1.12 days before epoch
            Time.Julian.Day.unixEpoch - Time.Julian.Offset(10.333_333),  // ~10.33 days before epoch
            Time.Julian.Day(2_440_586.123_456_789),  // literal, pre-1970, mid-second
            Time.Julian.Day(2_440_500.987_654_321),  // literal, pre-1970, mid-second
            Time.Julian.Day(0.0),  // Julian Day 0 (4714 BCE, deep pre-1970, extreme magnitude)
        ]
    )
    func `nanosecondFraction is never negative for a pre-1970 Julian Day`(
        julianDay: Time.Julian.Day
    ) {
        let instant = Instant(julianDay)
        #expect(
            instant.nanosecondFraction >= 0,
            "nanosecondFraction=\(instant.nanosecondFraction) for julianDay=\(julianDay.underlying) violates Instant's documented 0..<1_000_000_000 invariant"
        )
        #expect(instant.nanosecondFraction < 1_000_000_000)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `Instant throwing initializer accepts the nanosecondFraction produced from a pre-1970 Julian Day`() throws {
        // The whole point of the invariant: a value that round-trips through the
        // type's own validating initializer without throwing.
        let julianDay = Time.Julian.Day.unixEpoch - Time.Julian.Offset(10.75)
        let unchecked = Instant(julianDay)
        let rechecked = try Instant(
            secondsSinceUnixEpoch: unchecked.secondsSinceUnixEpoch,
            nanosecondFraction: unchecked.nanosecondFraction
        )
        #expect(rechecked == unchecked)
    }

    // MARK: - Exact boundary: one second before the Unix epoch

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `one second before the Unix epoch decodes to seconds -1, fraction near 0`() {
        // Julian Day exactly 1 second before Time.Julian.Day.unixEpoch. This is the
        // precise scenario the bug fix targets: `Int64(totalSeconds)` (the pre-fix
        // behavior) truncates toward zero for negative `totalSeconds`, landing on
        // secondsSinceUnixEpoch = 0 with a *negative* nanosecondFraction of about
        // -1_000_000_000 - a value `Instant`'s own throwing initializer would reject.
        // Floored decomposition (the fix) instead lands on secondsSinceUnixEpoch = -1
        // with a small *non-negative* fraction (a few microseconds, from Double's
        // limited precision at a ~2.44M-magnitude Julian Day - see
        // `JulianTests.instant Round Trip` for the same acknowledged tolerance).
        let julianDay = Time.Julian.Day.unixEpoch - Time.Julian.Offset(1.0 / 86400.0)
        let instant = Instant(julianDay)

        #expect(instant.secondsSinceUnixEpoch == -1)
        #expect(instant.nanosecondFraction >= 0)
        #expect(
            instant.nanosecondFraction < 100_000,
            "nanosecondFraction=\(instant.nanosecondFraction), expected ~0 (within Double precision at this JD magnitude)"
        )
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `mid-second before the Unix epoch decodes to a positive fraction, not a negative one`() {
        // 0.5 seconds before the epoch: floored decomposition puts this at
        // secondsSinceUnixEpoch = -1, nanosecondFraction ~= 500_000_000 (half a second
        // *into* second -1), matching how the type represents times between whole
        // seconds everywhere else (nanosecondFraction always measures forward from
        // secondsSinceUnixEpoch, never backward). Tolerance matches
        // `JulianTests.instant Round Trip`'s acknowledged Double-precision loss at this
        // JD magnitude.
        let julianDay = Time.Julian.Day.unixEpoch - Time.Julian.Offset(0.5 / 86400.0)
        let instant = Instant(julianDay)

        #expect(instant.secondsSinceUnixEpoch == -1)
        #expect(
            abs(instant.nanosecondFraction - 500_000_000) < 100_000,
            "nanosecondFraction=\(instant.nanosecondFraction), expected ~500_000_000"
        )
    }

    // MARK: - Round trip through Julian Day for pre-1970 instants

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `pre-1970 Instant round trips through Julian Day`() throws {
        let original = try Instant(secondsSinceUnixEpoch: -100_000, nanosecondFraction: 250_000_000)
        let julianDay = Time.Julian.Day(original)
        let restored = Instant(julianDay)

        #expect(restored.secondsSinceUnixEpoch == original.secondsSinceUnixEpoch)
        #expect(abs(restored.nanosecondFraction - original.nanosecondFraction) < 100_000)
    }
}
