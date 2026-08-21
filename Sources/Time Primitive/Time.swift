public struct Time: Sendable, Equatable, Hashable {

    public let year: Self.Year

    public let month: Self.Month

    public let day: Self.Month.Day

    public let hour: Self.Hour

    public let minute: Self.Minute

    public let second: Self.Second

    public let millisecond: Self.Millisecond

    public let microsecond: Self.Microsecond

    public let nanosecond: Self.Nanosecond

    public init(
        year: Self.Year,
        month: Self.Month,
        day: Self.Month.Day,
        hour: Self.Hour = .zero,
        minute: Self.Minute = .zero,
        second: Self.Second = .zero,
        millisecond: Self.Millisecond = .zero,
        microsecond: Self.Microsecond = .zero,
        nanosecond: Self.Nanosecond = .zero
    ) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.millisecond = millisecond
        self.microsecond = microsecond
        self.nanosecond = nanosecond
    }
}

extension Time {

    @_spi(Internal)
    public init(
        _unchecked: Void,
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        millisecond: Int = 0,
        microsecond: Int = 0,
        nanosecond: Int = 0
    ) {
        self = Self(
            year: Self.Year(year),
            month: Self.Month(unchecked: month),
            day: Self.Month.Day(unchecked: day),
            hour: Self.Hour(unchecked: hour),
            minute: Self.Minute(unchecked: minute),
            second: Self.Second(unchecked: second),
            millisecond: Self.Millisecond(unchecked: millisecond),
            microsecond: Self.Microsecond(unchecked: microsecond),
            nanosecond: Self.Nanosecond(unchecked: nanosecond)
        )
    }
}

extension Time {

    public init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        millisecond: Int = 0,
        microsecond: Int = 0,
        nanosecond: Int = 0
    ) throws(Self.Error) {
        let y = Self.Year(year)

        let m: Self.Month
        do throws(Self.Month.Error) {
            m = try Self.Month(month)
        } catch {
            throw Error.monthOutOfRange(month)
        }

        let d: Self.Month.Day
        do throws(Self.Month.Day.Error) {
            d = try Self.Month.Day(day, in: m, year: y)
        } catch {
            throw Error.dayOutOfRange(day, month: month, year: year)
        }

        let h: Self.Hour
        do throws(Self.Hour.Error) {
            h = try Self.Hour(hour)
        } catch {
            throw Error.hourOutOfRange(hour)
        }

        let min: Self.Minute
        do throws(Self.Minute.Error) {
            min = try Self.Minute(minute)
        } catch {
            throw Error.minuteOutOfRange(minute)
        }

        let s: Self.Second
        do throws(Self.Second.Error) {
            s = try Self.Second(second)
        } catch {
            throw Error.secondOutOfRange(second)
        }

        let ms: Self.Millisecond
        do throws(Self.Millisecond.Error) {
            ms = try Self.Millisecond(millisecond)
        } catch {
            throw Error.millisecondOutOfRange(millisecond)
        }

        let us: Self.Microsecond
        do throws(Self.Microsecond.Error) {
            us = try Self.Microsecond(microsecond)
        } catch {
            throw Error.microsecondOutOfRange(microsecond)
        }

        let ns: Self.Nanosecond
        do throws(Self.Nanosecond.Error) {
            ns = try Self.Nanosecond(nanosecond)
        } catch {
            throw Error.nanosecondOutOfRange(nanosecond)
        }

        self.init(
            year: y,
            month: m,
            day: d,
            hour: h,
            minute: min,
            second: s,
            millisecond: ms,
            microsecond: us,
            nanosecond: ns
        )
    }
}

extension Time {

    public init(
        secondsSinceEpoch: Int
    ) {
        let (year, month, day, hour, minute, second) = Self.Epoch.Conversion
            .componentsRaw(fromSecondsSinceEpoch: secondsSinceEpoch)

        self = .init(
            _unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    }

    public init(
        secondsSinceEpoch: Int,
        nanoseconds: Int
    ) throws(Self.Error) {
        guard nanoseconds >= 0 && nanoseconds < 1_000_000_000 else {
            throw Error.nanosecondOutOfRange(nanoseconds)
        }

        let (year, month, day, hour, minute, second) = Self.Epoch.Conversion
            .componentsRaw(fromSecondsSinceEpoch: secondsSinceEpoch)

        let millisecond = nanoseconds / 1_000_000
        let microsecond = (nanoseconds % 1_000_000) / 1_000
        let nanosecond = nanoseconds % 1_000

        self = .init(
            _unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: millisecond,
            microsecond: microsecond,
            nanosecond: nanosecond
        )
    }

    @_spi(Internal)
    public init(
        _unchecked: (),
        secondsSinceEpoch: Int,
        nanoseconds: Int
    ) {
        let (year, month, day, hour, minute, second) = Self.Epoch.Conversion
            .componentsRaw(fromSecondsSinceEpoch: secondsSinceEpoch)

        let millisecond = nanoseconds / 1_000_000
        let microsecond = (nanoseconds % 1_000_000) / 1_000
        let nanosecond = nanoseconds % 1_000

        self = .init(
            _unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: millisecond,
            microsecond: microsecond,
            nanosecond: nanosecond
        )
    }
}

extension Time {

    public enum Error: Swift.Error, Sendable, Equatable {

        case monthOutOfRange(Int)

        case dayOutOfRange(Int, month: Int, year: Int)

        case hourOutOfRange(Int)

        case minuteOutOfRange(Int)

        case secondOutOfRange(Int)

        case millisecondOutOfRange(Int)

        case microsecondOutOfRange(Int)

        case nanosecondOutOfRange(Int)
    }
}

extension Time {

    @inlinable
    public var totalNanoseconds: Int {
        Self.totalNanoseconds(
            millisecond: millisecond,
            microsecond: microsecond,
            nanosecond: nanosecond
        )
    }

    @inlinable
    public static func totalNanoseconds(
        millisecond: Time.Millisecond,
        microsecond: Time.Microsecond,
        nanosecond: Time.Nanosecond
    ) -> Int {
        millisecond.value * 1_000_000 + microsecond.value * 1000 + nanosecond.value
    }

    @inlinable
    public var weekday: Time.Weekday {
        Self.weekday(year: year, month: month, day: day)
    }

    @inlinable
    public static func weekday(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day
    ) -> Time.Weekday {
        Self.Weekday(year: year, month: month, day: day)
    }

    @inlinable
    public var secondsSinceEpoch: Int {
        Self.secondsSinceEpoch(from: self)
    }

    @inlinable
    public static func secondsSinceEpoch(from time: Time) -> Int {
        Self.Epoch.Conversion.secondsSinceEpoch(from: time)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Time {

    public init(_ instant: Instant) {

        self = .init(
            _unchecked: (),
            secondsSinceEpoch: Int(instant.secondsSinceUnixEpoch),
            nanoseconds: Int(instant.nanosecondFraction)
        )
    }
}

#if !hasFeature(Embedded)
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    extension Time: Codable {

        public init(from decoder: any Decoder) throws {
            let instant = try Instant(from: decoder)
            self.init(instant)
        }

        public func encode(to encoder: any Encoder) throws {
            try Instant(self).encode(to: encoder)
        }
    }
#endif
