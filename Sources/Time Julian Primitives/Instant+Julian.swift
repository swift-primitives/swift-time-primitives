// Instant+Julian.swift
// StandardTime
//
// Conversions between Instant and Julian Day

public import Dimension_Primitives

// MARK: - Instant → Julian Day

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Tagged where Tag == Coordinate.X<Time.Julian.Space>, Underlying == Double {
    /// Creates a Julian Day from an Instant.
    ///
    /// - Parameter instant: The instant to convert
    public init(_ instant: Instant) {
        self = Self.from(instant)
    }

    /// Converts an Instant to Julian Day.
    ///
    /// Uses the Unix epoch Julian Day (2440587.5) as reference.
    public static func from(_ instant: Instant) -> Self {
        let secondsPerDay: Double = 86400.0
        let days =
            Double(instant.secondsSinceUnixEpoch) / secondsPerDay
            + Double(instant.nanosecondFraction) / (secondsPerDay * 1_000_000_000)
        return Self.unixEpoch + Time.Julian.Offset(days)
    }
}

// MARK: - Julian Day → Instant

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant {
    /// Creates an Instant from a Julian Day.
    ///
    /// - Parameter julianDay: The Julian Day to convert
    public init(_ julianDay: Time.Julian.Day) {
        self = Self.from(julianDay)
    }

    /// Converts a Julian Day to Instant.
    ///
    /// Uses the Unix epoch Julian Day (2440587.5) as reference.
    public static func from(_ julianDay: Time.Julian.Day) -> Self {
        let offset = julianDay - .unixEpoch
        let days = offset.underlying

        let secondsPerDay: Double = 86400.0
        let totalSeconds = days * secondsPerDay

        // Floored decomposition: `wholeSeconds` is the largest integer <= totalSeconds, so
        // `fractionalSeconds` (and therefore `nanoseconds`) is always in [0, 1) / [0, 1e9),
        // matching `Instant.nanosecondFraction`'s documented invariant (0..<1_000_000_000)
        // even for pre-1970 (negative) Julian Days. `Int64(totalSeconds)` (the previous
        // behavior) truncates *toward zero*, which for negative `totalSeconds` rounds up
        // instead of down, leaving a negative fractional remainder and therefore a negative
        // `nanosecondFraction` - an invalid `Instant` that bypasses the type's own
        // range-checked initializer via `_unchecked`.
        let flooredSeconds = totalSeconds.rounded(.down)
        let wholeSeconds = Int64(flooredSeconds)
        let fractionalSeconds = totalSeconds - flooredSeconds  // mathematically in [0, 1)

        // Clamp for floating-point edge cases (fractionalSeconds landing a hair outside
        // [0, 1) due to Double rounding, e.g. for very large-magnitude Julian Days) so the
        // invariant holds exactly rather than merely "usually".
        let nanoseconds = Int32(
            min(max(fractionalSeconds * 1_000_000_000, 0), 999_999_999)
        )

        return Instant(
            _unchecked: (),
            secondsSinceUnixEpoch: wholeSeconds,
            nanosecondFraction: nanoseconds
        )
    }

    /// The Julian Day representation of this instant.
    public var julianDay: Time.Julian.Day {
        Time.Julian.Day(self)
    }
}
