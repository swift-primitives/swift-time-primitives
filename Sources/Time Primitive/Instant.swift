public struct Instant: Sendable, Equatable, Hashable, Comparable {

    public let secondsSinceUnixEpoch: Int64

    public let nanosecondFraction: Int32

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

extension Instant {

    public enum Error: Swift.Error, Sendable, Equatable {

        case nanosecondOutOfRange(Int32)
    }
}

extension Instant {

    public init(
        _unchecked: Void,
        secondsSinceUnixEpoch: Int64,
        nanosecondFraction: Int32
    ) {
        self.secondsSinceUnixEpoch = secondsSinceUnixEpoch
        self.nanosecondFraction = nanosecondFraction
    }
}

extension Instant {

    @inlinable
    public init(secondsSinceUnixEpoch: Int64) {
        self.init(
            _unchecked: (),
            secondsSinceUnixEpoch: secondsSinceUnixEpoch,
            nanosecondFraction: 0
        )
    }
}

extension Instant {

    public init(_ time: Time) {
        self.secondsSinceUnixEpoch = Int64(time.secondsSinceEpoch)
        self.nanosecondFraction = Int32(time.totalNanoseconds)
    }
}

extension Instant {

    @inlinable
    public static func < (lhs: Instant, rhs: Instant) -> Bool {
        Self.isLessThan(lhs: lhs, rhs: rhs)
    }

    @inlinable
    public static func isLessThan(lhs: Instant, rhs: Instant) -> Bool {
        if lhs.secondsSinceUnixEpoch == rhs.secondsSinceUnixEpoch {
            return lhs.nanosecondFraction < rhs.nanosecondFraction
        }
        return lhs.secondsSinceUnixEpoch < rhs.secondsSinceUnixEpoch
    }
}

extension Instant {

    @inlinable
    @_disfavoredOverload
    public static func + (lhs: Instant, rhs: Duration) -> Instant {
        Self.add(instant: lhs, duration: rhs)
    }

    @inlinable
    public static func add(instant: Instant, duration: Duration) -> Instant {
        let (durationSeconds, attoseconds) = duration.components

        let nanosFromDuration = attoseconds / 1_000_000_000

        var totalSeconds = instant.secondsSinceUnixEpoch + durationSeconds
        var totalNanos = Int64(instant.nanosecondFraction) + nanosFromDuration

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

    @inlinable
    @_disfavoredOverload
    public static func - (lhs: Instant, rhs: Duration) -> Instant {
        Self.subtract(duration: rhs, from: lhs)
    }

    @inlinable
    public static func subtract(duration: Duration, from instant: Instant) -> Instant {
        let (durationSeconds, attoseconds) = duration.components

        let nanosFromDuration = attoseconds / 1_000_000_000

        var totalSeconds = instant.secondsSinceUnixEpoch - durationSeconds
        var totalNanos = Int64(instant.nanosecondFraction) - nanosFromDuration

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

    @inlinable
    public static func - (lhs: Instant, rhs: Instant) -> Duration {
        Self.duration(from: rhs, to: lhs)
    }

    @inlinable
    public static func duration(from: Instant, to: Instant) -> Duration {
        let secondsDiff = to.secondsSinceUnixEpoch - from.secondsSinceUnixEpoch
        let nanosDiff = to.nanosecondFraction - from.nanosecondFraction

        return Duration.seconds(secondsDiff) + Duration.nanoseconds(Int64(nanosDiff))
    }
}

extension Instant: InstantProtocol {

    public typealias Duration = Swift.Duration

    public func advanced(by duration: Duration) -> Instant {
        self + duration
    }

    public func duration(to other: Instant) -> Duration {
        other - self
    }
}

#if !hasFeature(Embedded)
    extension Instant: Codable {}
#endif
