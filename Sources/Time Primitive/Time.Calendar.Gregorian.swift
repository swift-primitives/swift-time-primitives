extension Time.Calendar {

    public enum Gregorian {

    }
}

extension Time.Calendar.Gregorian {

    public enum TimeConstants {}
}

extension Time.Calendar.Gregorian.TimeConstants {

    public static let secondsPerMinute = 60

    public static let secondsPerHour = 3600

    public static let secondsPerDay = 86400

    public static let daysPerCommonYear = 365

    public static let daysPerLeapYear = 366

    public static let daysPer4Years = 1461

    public static let daysPer100Years = 36524

    public static let daysPer400Years = 146_097
}

extension Time.Calendar.Gregorian {

    @inlinable
    public static func isLeapYear(_ year: Time.Year) -> Bool {
        let y = year.rawValue
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }

    @inlinable
    public static func isLeapYear(_ year: Int) -> Bool {
        isLeapYear(Time.Year(year))
    }
}

extension Time.Calendar.Gregorian {

    @usableFromInline
    internal static let daysInCommonYearMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    @usableFromInline
    internal static let daysInLeapYearMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    @inlinable
    public static func daysInMonth(_ year: Time.Year, _ month: Time.Month) -> Int {
        let monthArray = isLeapYear(year) ? daysInLeapYearMonths : daysInCommonYearMonths

        return monthArray[month.rawValue - 1]
    }

    @inlinable
    public static func daysInMonths(year: Int) -> [Int] {
        isLeapYear(year) ? daysInLeapYearMonths : daysInCommonYearMonths
    }

    @inlinable
    package static func daysInMonth(year: Int, month: Int) -> Int {
        let months = daysInMonths(year: year)

        return months[month - 1]
    }
}
