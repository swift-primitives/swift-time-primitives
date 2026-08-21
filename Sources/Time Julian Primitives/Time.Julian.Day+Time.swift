public import Dimension_Primitives
@_spi(Internal) internal import Time_Primitive

extension Tagged where Tag == Coordinate.X<Time.Julian.Space>, Underlying == Double {

    public init(_ time: Time) {
        self = Self.from(time)
    }

    public static func from(_ time: Time) -> Self {
        let year = time.year.rawValue
        let month = time.month.rawValue
        let day = time.day.rawValue

        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3

        let jdn = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045

        let dayFraction =
            (Double(time.hour.value) - 12.0) / 24.0
            + Double(time.minute.value) / 1440.0
            + Double(time.second.value) / 86400.0
            + Double(time.totalNanoseconds) / 86_400_000_000_000.0

        return Self(Double(jdn) + dayFraction)
    }
}

extension Time {

    public init(_ julianDay: Time.Julian.Day) {
        self = Self.from(julianDay)
    }

    public static func from(_ julianDay: Time.Julian.Day) -> Self {
        let jd = julianDay.underlying

        let jdPlus = jd + 0.5
        let z = Int(jdPlus.rounded(.down))
        let f = jdPlus - Double(z)

        let y = 4716
        let j = 1401
        let m = 2
        let n = 12
        let r = 4
        let p = 1461
        let v = 3
        let u = 5
        let s = 153
        let w = 2
        let b = 274277
        let c = -38

        let f1 = z + j + (((4 * z + b) / 146097) * 3) / 4 + c
        let e = r * f1 + v
        let g = (e % p) / r
        let h = u * g + w
        let day = (h % s) / u + 1
        let month = ((h / s + m) % n) + 1
        let year = e / p - y + (n + m - month) / n

        let totalSeconds = f * 86400.0
        let hour = Int(totalSeconds / 3600.0)
        let remainingAfterHour = totalSeconds - Double(hour * 3600)
        let minute = Int(remainingAfterHour / 60.0)
        let remainingAfterMinute = remainingAfterHour - Double(minute * 60)
        let second = Int(remainingAfterMinute)
        let nanoseconds = Int((remainingAfterMinute - Double(second)) * 1_000_000_000)

        return Time(
            _unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: nanoseconds / 1_000_000,
            microsecond: (nanoseconds % 1_000_000) / 1000,
            nanosecond: nanoseconds % 1000
        )
    }
}

extension Time {

    public var julianDay: Time.Julian.Day {
        Self.Julian.Day(self)
    }
}
