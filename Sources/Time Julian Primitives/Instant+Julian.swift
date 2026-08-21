public import Dimension_Primitives

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Tagged where Tag == Coordinate.X<Time.Julian.Space>, Underlying == Double {

    public init(_ instant: Instant) {
        self = Self.from(instant)
    }

    public static func from(_ instant: Instant) -> Self {
        let secondsPerDay: Double = 86400.0
        let days =
            Double(instant.secondsSinceUnixEpoch) / secondsPerDay
            + Double(instant.nanosecondFraction) / (secondsPerDay * 1_000_000_000)
        return Self.unixEpoch + Time.Julian.Offset(days)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Instant {

    public init(_ julianDay: Time.Julian.Day) {
        self = Self.from(julianDay)
    }

    public static func from(_ julianDay: Time.Julian.Day) -> Self {
        let offset = julianDay - .unixEpoch
        let days = offset.underlying

        let secondsPerDay: Double = 86400.0
        let totalSeconds = days * secondsPerDay

        let flooredSeconds = totalSeconds.rounded(.down)
        let wholeSeconds = Int64(flooredSeconds)
        let fractionalSeconds = totalSeconds - flooredSeconds

        let nanoseconds = Int32(
            min(max(fractionalSeconds * 1_000_000_000, 0), 999_999_999)
        )

        return Instant(
            _unchecked: (),
            secondsSinceUnixEpoch: wholeSeconds,
            nanosecondFraction: nanoseconds
        )
    }

    public var julianDay: Time.Julian.Day {
        Time.Julian.Day(self)
    }
}
