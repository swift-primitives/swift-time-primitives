// Instant.swift
// StandardTime
//
// Point on the UTC timeline

/// A point on the UTC timeline.
///
/// Represents an absolute moment as seconds and nanoseconds since Unix epoch (1970-01-01 00:00:00 UTC).
/// Use for timeline arithmetic, comparisons, and compact serialization. For calendar operations, convert to `Time`.
///
/// ## Example
///
/// ```swift
/// // Timeline arithmetic
/// let now = Instant(secondsSinceUnixEpoch: 1732276800)
/// let later = now + .seconds(3600)
/// let duration = later - now
///
/// // Conversion to/from Time
/// let time = try Time(year: 2024, month: 11, day: 22, hour: 10, minute: 0, second: 0)
/// let instant = Instant(time)
/// let backToTime = Time(instant)
/// ```
public struct Instant: Sendable, Equatable, Hashable, Comparable {
    /// Seconds since Unix epoch (Int64 for platform portability).
    public let secondsSinceUnixEpoch: Int64

    /// Nanosecond fraction within the second (0-999,999,999, Int32 for compact 12-byte total).
    public let nanosecondFraction: Int32

    /// Creates an instant from seconds and nanoseconds.
    ///
    /// - Throws: `Instant.Error.nanosecondOutOfRange` if nanosecondFraction is not in valid range
    public init(
        secondsSinceUnixEpoch: Int64,
        nanosecondFraction: Int32 = 0
    ) throws(Self.Error) {
        guard nanosecondFraction >= 0 && nanosecondFraction < 1_000_000_000 else {
            throw Error.nanosecondOutOfRange(nanosecondFraction)
        }
        self.secondsSinceUnixEpoch = secondsSinceUnixEpoch
        self.nanosecondFraction = nanosecondFraction
    }
}

// MARK: - Error

extension Instant {
    /// Validation errors for instant values.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Nanosecond fraction is not in valid range (0-999,999,999)
        case nanosecondOutOfRange(Int32)
    }
}

// MARK: - Unchecked Initialization

extension Instant {
    /// Creates an instant without validation (internal use only).
    ///
    /// - Warning: Only use when nanosecondFraction is known to be valid (0-999,999,999).
    public init(
        _unchecked: Void,
        secondsSinceUnixEpoch: Int64,
        nanosecondFraction: Int32
    ) {
        self.secondsSinceUnixEpoch = secondsSinceUnixEpoch
        self.nanosecondFraction = nanosecondFraction
    }
}

// MARK: - Seconds-Only Initialization

extension Instant {
    /// Creates an instant from a whole-second Unix timestamp.
    ///
    /// Non-throwing: every `Int64` is a valid seconds-since-epoch value and
    /// `nanosecondFraction` is fixed to zero, so there is no range to validate.
    /// Use the `(secondsSinceUnixEpoch:nanosecondFraction:)` throwing init when
    /// a sub-second fraction is required.
    ///
    /// - Parameter secondsSinceUnixEpoch: Whole seconds since 1970-01-01 UTC.
    @inlinable
    public init(secondsSinceUnixEpoch: Int64) {
        self.init(
            _unchecked: (),
            secondsSinceUnixEpoch: secondsSinceUnixEpoch,
            nanosecondFraction: 0
        )
    }
}

// MARK: - Conversions

extension Instant {

    /// Creates instant from time.
    ///
    /// Converts calendar representation to timeline representation.
    public init(_ time: Time) {
        self.secondsSinceUnixEpoch = Int64(time.secondsSinceEpoch)
        self.nanosecondFraction = Int32(time.totalNanoseconds)
    }
}

// MARK: - Comparable

extension Instant {
    /// Returns whether the first instant is less than the second.
    @inlinable
    public static func < (lhs: Instant, rhs: Instant) -> Bool {
        Self.isLessThan(lhs: lhs, rhs: rhs)
    }

    /// Compares two instants to determine if the first is less than the second.
    @inlinable
    public static func isLessThan(lhs: Instant, rhs: Instant) -> Bool {
        if lhs.secondsSinceUnixEpoch == rhs.secondsSinceUnixEpoch {
            return lhs.nanosecondFraction < rhs.nanosecondFraction
        }
        return lhs.secondsSinceUnixEpoch < rhs.secondsSinceUnixEpoch
    }
}

// MARK: - Timeline Arithmetic

extension Instant {
    /// Adds a duration to an instant.
    ///
    /// Sub-nanosecond precision is lost (Duration has attosecond precision, Instant has nanosecond).
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: Instant, rhs: Duration) -> Instant {
        Self.add(instant: lhs, duration: rhs)
    }

    /// Adds a duration to an instant.
    ///
    /// Sub-nanosecond precision is lost (Duration has attosecond precision, Instant has nanosecond).
    @inlinable
    public static func add(instant: Instant, duration: Duration) -> Instant {
        let (durationSeconds, attoseconds) = duration.components

        // Convert attoseconds to nanoseconds (loses sub-nanosecond precision)
        // attoseconds / 10^9 = nanoseconds
        let nanosFromDuration = attoseconds / 1_000_000_000

        // Add seconds and nanoseconds separately
        var totalSeconds = instant.secondsSinceUnixEpoch + durationSeconds
        var totalNanos = Int64(instant.nanosecondFraction) + nanosFromDuration

        // Normalize: ensure nanos in range [0, 1_000_000_000)
        while totalNanos >= 1_000_000_000 {
            totalSeconds += 1
            totalNanos -= 1_000_000_000
        }
        while totalNanos < 0 {
            totalSeconds -= 1
            totalNanos += 1_000_000_000
        }

        return .init(
            _unchecked: (),
            secondsSinceUnixEpoch: totalSeconds,
            nanosecondFraction: Int32(totalNanos)
        )
    }

    /// Subtracts a duration from an instant.
    ///
    /// Sub-nanosecond precision is lost (Duration has attosecond precision, Instant has nanosecond).
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: Instant, rhs: Duration) -> Instant {
        Self.subtract(duration: rhs, from: lhs)
    }

    /// Subtracts a duration from an instant.
    ///
    /// Sub-nanosecond precision is lost (Duration has attosecond precision, Instant has nanosecond).
    @inlinable
    public static func subtract(duration: Duration, from instant: Instant) -> Instant {
        let (durationSeconds, attoseconds) = duration.components

        // Convert attoseconds to nanoseconds (loses sub-nanosecond precision)
        let nanosFromDuration = attoseconds / 1_000_000_000

        // Subtract seconds and nanoseconds separately
        var totalSeconds = instant.secondsSinceUnixEpoch - durationSeconds
        var totalNanos = Int64(instant.nanosecondFraction) - nanosFromDuration

        // Normalize: ensure nanos in range [0, 1_000_000_000)
        while totalNanos >= 1_000_000_000 {
            totalSeconds += 1
            totalNanos -= 1_000_000_000
        }
        while totalNanos < 0 {
            totalSeconds -= 1
            totalNanos += 1_000_000_000
        }

        return .init(
            _unchecked: (),
            secondsSinceUnixEpoch: totalSeconds,
            nanosecondFraction: Int32(totalNanos)
        )
    }

    /// Calculates duration between two instants.
    ///
    /// Returns positive duration if lhs > rhs, negative if lhs < rhs.
    @inlinable
    public static func - (lhs: Instant, rhs: Instant) -> Duration {
        Self.duration(from: rhs, to: lhs)
    }

    /// Calculates duration between two instants.
    ///
    /// Returns positive duration if to > from, negative if to < from.
    @inlinable
    public static func duration(from: Instant, to: Instant) -> Duration {
        let secondsDiff = to.secondsSinceUnixEpoch - from.secondsSinceUnixEpoch
        let nanosDiff = to.nanosecondFraction - from.nanosecondFraction

        return Duration.seconds(secondsDiff) + Duration.nanoseconds(Int64(nanosDiff))
    }
}

// MARK: - InstantProtocol Conformance

extension Instant: InstantProtocol {
    /// The duration type used to advance and measure between instants.
    public typealias Duration = Swift.Duration

    /// Returns an instant advanced from this one by the given duration.
    public func advanced(by duration: Duration) -> Instant {
        self + duration
    }

    /// Returns the duration from this instant to another instant.
    public func duration(to other: Instant) -> Duration {
        other - self
    }
}

// MARK: - Codable

#if !hasFeature(Embedded)
    extension Instant: Codable {}
#endif
