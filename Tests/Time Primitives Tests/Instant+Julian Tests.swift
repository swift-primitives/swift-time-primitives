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

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test(
        arguments: [

            Time.Julian.Day.unixEpoch - Time.Julian.Offset(1.123_456_789),
            Time.Julian.Day.unixEpoch - Time.Julian.Offset(10.333_333),
            Time.Julian.Day(2_440_586.123_456_789),
            Time.Julian.Day(2_440_500.987_654_321),
            Time.Julian.Day(0.0),
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
    func
        `Instant throwing initializer accepts the nanosecondFraction produced from a pre-1970 Julian Day`()
        throws
    {

        let julianDay = Time.Julian.Day.unixEpoch - Time.Julian.Offset(10.75)
        let unchecked = Instant(julianDay)
        let rechecked = try Instant(
            secondsSinceUnixEpoch: unchecked.secondsSinceUnixEpoch,
            nanosecondFraction: unchecked.nanosecondFraction
        )
        #expect(rechecked == unchecked)
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    @Test
    func `one second before the Unix epoch decodes to seconds -1, fraction near 0`() {

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

        let julianDay = Time.Julian.Day.unixEpoch - Time.Julian.Offset(0.5 / 86400.0)
        let instant = Instant(julianDay)

        #expect(instant.secondsSinceUnixEpoch == -1)
        #expect(
            abs(instant.nanosecondFraction - 500_000_000) < 100_000,
            "nanosecondFraction=\(instant.nanosecondFraction), expected ~500_000_000"
        )
    }

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
