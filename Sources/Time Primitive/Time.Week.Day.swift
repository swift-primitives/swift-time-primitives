extension Time {

    public typealias Weekday = Time.Week.Day
}

extension Time.Week {

    public enum Day: Sendable, Equatable, Hashable, CaseIterable {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
}

extension Time.Week.Day {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidMonth(Int)

        case invalidDay(Int, month: Int, year: Int)
    }
}

extension Time.Weekday {

    @inlinable
    public init(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day
    ) {
        self = Self.calculate(year: year, month: month, day: day)
    }

    @inlinable
    public static func calculate(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day
    ) -> Time.Weekday {
        var y = year.rawValue
        var m = month.rawValue

        if m < 3 {
            m += 12
            y -= 1
        }

        let q = day.rawValue
        let k = y % 100
        let j = y / 100

        let h = (q + ((13 * (m + 1)) / 5) + k + (k / 4) + (j / 4) - (2 * j)) % 7

        let gregorianDay = (h + 6) % 7

        switch gregorianDay {
        case 0: return .sunday
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        default: return .saturday
        }
    }

    public init(year: Int, month: Int, day: Int) throws(Self.Error) {
        let y = Time.Year(year)

        let m: Time.Month
        do throws(Time.Month.Error) {
            m = try Time.Month(month)
        } catch {
            throw Error.invalidMonth(month)
        }

        let d: Time.Month.Day
        do throws(Time.Month.Day.Error) {
            d = try Time.Month.Day(day, in: m, year: y)
        } catch {
            throw Error.invalidDay(day, month: month, year: year)
        }

        self.init(year: y, month: m, day: d)
    }
}
