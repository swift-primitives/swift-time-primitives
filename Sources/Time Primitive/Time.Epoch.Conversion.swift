extension Time.Epoch {

    public enum Conversion {

    }
}

extension Time.Epoch.Conversion {

    @inlinable
    public static func secondsSinceEpoch(from components: Time) -> Int {
        secondsSinceEpoch(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: components.hour,
            minute: components.minute,
            second: components.second
        )
    }
}

extension Time.Epoch.Conversion {

    @inlinable
    package static func secondsSinceEpoch(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day,
        hour: Time.Hour,
        minute: Time.Minute,
        second: Time.Second
    ) -> Int {
        let days = daysSinceEpoch(year: year, month: month, day: day)

        return days * Time.Calendar.Gregorian.TimeConstants.secondsPerDay + hour.value
            * Time.Calendar.Gregorian.TimeConstants.secondsPerHour + minute.value
            * Time.Calendar.Gregorian.TimeConstants.secondsPerMinute + second.value
    }

    @inlinable
    package static func componentsRaw(
        fromSecondsSinceEpoch secondsSinceEpoch: Int
    ) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        let totalDays = floorDiv(
            secondsSinceEpoch,
            Time.Calendar.Gregorian.TimeConstants.secondsPerDay
        )
        let secondsInDay = floorMod(
            secondsSinceEpoch,
            Time.Calendar.Gregorian.TimeConstants.secondsPerDay
        )

        let hour = secondsInDay / Time.Calendar.Gregorian.TimeConstants.secondsPerHour
        let minute =
            (secondsInDay % Time.Calendar.Gregorian.TimeConstants.secondsPerHour)
            / Time.Calendar.Gregorian
            .TimeConstants.secondsPerMinute
        let second = secondsInDay % Time.Calendar.Gregorian.TimeConstants.secondsPerMinute

        let (year, remainingDays) = yearAndDays(fromDaysSinceEpoch: totalDays)

        let daysInMonths = Time.Calendar.Gregorian.daysInMonths(year: year)
        var month = 1
        var daysInCurrentMonth = remainingDays
        for daysInMonth in daysInMonths {
            if daysInCurrentMonth < daysInMonth {
                break
            }
            daysInCurrentMonth -= daysInMonth
            month += 1
        }

        let day = daysInCurrentMonth + 1

        return (year, month, day, hour, minute, second)
    }
}

extension Time.Epoch.Conversion {

    @usableFromInline
    package static let daysFromComputationalEpochToUnixEpoch = 719468

    @inlinable
    package static func yearAndDays(
        fromDaysSinceEpoch days: Int
    ) -> (year: Int, remainingDays: Int) {
        let z = days + daysFromComputationalEpochToUnixEpoch

        let era = floorDiv(z, Time.Calendar.Gregorian.TimeConstants.daysPer400Years)

        let dayOfEra = z - era * Time.Calendar.Gregorian.TimeConstants.daysPer400Years
        let yearOfEra =
            (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146096) / 365
        let computationalYear = yearOfEra + era * 400

        let dayOfComputationalYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let shiftedMonth = (5 * dayOfComputationalYear + 2) / 153
        let day = dayOfComputationalYear - (153 * shiftedMonth + 2) / 5 + 1
        let month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9
        let year = month <= 2 ? computationalYear + 1 : computationalYear

        let monthDays = Time.Calendar.Gregorian.daysInMonths(year: year)
        var remainingDays = day - 1
        for m in 0..<(month - 1) {
            remainingDays += monthDays[m]
        }

        return (year, remainingDays)
    }
}

extension Time.Epoch.Conversion {

    @inlinable
    package static func leapYearsBefore(_ year: Int) -> Int {
        let y = year - 1
        return floorDiv(y, 4) - floorDiv(y, 100) + floorDiv(y, 400)
    }

    @inlinable
    package static func daysSinceEpoch(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day
    ) -> Int {

        let yearsSince1970 = year.rawValue - 1970

        let leapYears = leapYearsBefore(year.rawValue) - leapYearsBefore(1970)

        var days =
            yearsSince1970 * Time.Calendar.Gregorian.TimeConstants.daysPerCommonYear + leapYears

        let monthDays = Time.Calendar.Gregorian.daysInMonths(year: year.rawValue)

        for m in 0..<(month.rawValue - 1) {
            days += monthDays[m]
        }

        days += day.rawValue - 1

        return days
    }
}

extension Time.Epoch.Conversion {

    @inlinable
    package static func floorDiv(_ dividend: Int, _ divisor: Int) -> Int {
        let quotient = dividend / divisor
        let remainder = dividend % divisor
        return remainder < 0 ? quotient - 1 : quotient
    }

    @inlinable
    package static func floorMod(_ dividend: Int, _ divisor: Int) -> Int {
        let remainder = dividend % divisor
        return remainder < 0 ? remainder + divisor : remainder
    }
}
