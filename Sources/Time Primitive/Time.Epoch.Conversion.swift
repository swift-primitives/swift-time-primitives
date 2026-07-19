// Time.Epoch.Conversion.swift
// Time
//
// Core Unix epoch conversion algorithms
// Extracted from RFC 5322 and ISO 8601 common logic

extension Time.Epoch {
    /// Unix epoch conversion algorithms.
    ///
    /// Optimized O(1) algorithms for converting between Unix epoch seconds (1970-01-01 00:00:00 UTC)
    /// and calendar components. Uses pure arithmetic based on Gregorian calendar cycle structure.
    public enum Conversion {
        // Empty - all functionality in extensions
    }
}

// MARK: - Type-Safe Public API

extension Time.Epoch.Conversion {
    /// Calculates seconds since Unix epoch from time components.
    ///
    /// Returns whole seconds only. Use `components.totalNanoseconds` for sub-second precision.
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

// MARK: - Internal Type-Safe Implementation

extension Time.Epoch.Conversion {
    /// Calculates seconds since epoch from refined type components (internal).
    ///
    /// Type-safe version that guarantees all values are pre-validated.
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

    /// Extracts date-time components from seconds since epoch (internal).
    ///
    /// Returns raw tuple with values guaranteed valid by algorithmic construction.
    ///
    /// Uses a floored (Euclidean) day/second split so that pre-1970 (negative)
    /// `secondsSinceEpoch` values decompose correctly: `secondsInDay` is always in
    /// `[0, secondsPerDay)`, never negative. Swift's native `/` and `%` truncate
    /// toward zero, which would otherwise yield a negative `secondsInDay` for
    /// negative input.
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

        // Calculate year, month, day from days since epoch
        let (year, remainingDays) = yearAndDays(fromDaysSinceEpoch: totalDays)

        // Calculate month and day
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

// MARK: - Year and Days Calculation (Internal)

extension Time.Epoch.Conversion {
    /// Number of days from the proleptic-Gregorian "computational epoch" (0000-03-01) to
    /// the Unix epoch (1970-01-01).
    ///
    /// `yearAndDays` below starts its computational year on March 1 rather than January 1.
    /// A year that starts on March 1 always ends with Feb 28/29 as its *last* day, so the
    /// leap day is the final day of every 4-year/100-year/400-year block instead of the
    /// first — which means a block is never "deficient" partway through, unlike a
    /// January-anchored decomposition. (A January-anchored version of this same cycle
    /// arithmetic has a bug: the four years immediately following a non-x400 century
    /// boundary, e.g. 1900-1904 or 2100-2104, form a 1460-day block with zero leap days,
    /// not the uniform 1461 assumed by dividing by `daysPer4Years` — silently producing
    /// wrong dates for roughly a third of all years once corrected for symmetry.)
    @usableFromInline
    package static let daysFromComputationalEpochToUnixEpoch = 719468

    /// Calculates year and remaining days (from January 1 of that year) from days since
    /// the Unix epoch (internal).
    ///
    /// O(1) algorithm using Gregorian calendar's 400-year cycle structure (exactly 146,097
    /// days), correct for the full `Int` domain including negative `days` (pre-1970 dates).
    ///
    /// Algorithm: Howard Hinnant, "chrono-Compatible Low-Level Date Algorithms",
    /// `civil_from_days` (<http://howardhinnant.github.io/date_algorithms.html>, public
    /// domain; the same algorithm used by LLVM libc++'s `<chrono>`). The March-1
    /// computational-year shift (see `daysFromComputationalEpochToUnixEpoch`) is what
    /// makes this correct across century boundaries in both directions, unlike a
    /// January-anchored cycle decomposition.
    @inlinable
    package static func yearAndDays(
        fromDaysSinceEpoch days: Int
    ) -> (year: Int, remainingDays: Int) {
        let z = days + daysFromComputationalEpochToUnixEpoch

        let era = floorDiv(z, Time.Calendar.Gregorian.TimeConstants.daysPer400Years)
        let dayOfEra = z - era * Time.Calendar.Gregorian.TimeConstants.daysPer400Years  // [0, 146096]
        let yearOfEra =
            (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146096) / 365  // [0, 399]
        let computationalYear = yearOfEra + era * 400

        // Day of the March-1-started computational year, [0, 365].
        let dayOfComputationalYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let shiftedMonth = (5 * dayOfComputationalYear + 2) / 153  // [0, 11], 0 = March
        let day = dayOfComputationalYear - (153 * shiftedMonth + 2) / 5 + 1  // [1, 31]
        let month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9  // [1, 12]
        let year = month <= 2 ? computationalYear + 1 : computationalYear

        // Re-express as days since January 1 of the (calendar, not computational) year, to
        // match this function's existing January-anchored contract.
        let monthDays = Time.Calendar.Gregorian.daysInMonths(year: year)
        var remainingDays = day - 1
        for m in 0..<(month - 1) {
            remainingDays += monthDays[m]
        }

        return (year, remainingDays)
    }
}

// MARK: - Days Since Epoch Calculation (Internal)

extension Time.Epoch.Conversion {
    /// Number of leap years strictly before the start of `year` (i.e. in `[.., year - 1]`),
    /// using the proleptic Gregorian rule (divisible by 4, except centuries, except
    /// again multiples of 400).
    ///
    /// Uses floored division throughout so the count is correct for negative `year`
    /// too (Swift's native `/` truncates toward zero, which silently miscounts leap
    /// years for negative dividends).
    @inlinable
    package static func leapYearsBefore(_ year: Int) -> Int {
        let y = year - 1
        return floorDiv(y, 4) - floorDiv(y, 100) + floorDiv(y, 400)
    }

    /// Calculates days since Unix epoch for a given date (internal).
    ///
    /// O(1) algorithm using leap year counting formula (no year-by-year iteration).
    /// Correct for years before 1970 as well as after: the leap-year count is expressed
    /// as a symmetric difference (`leapYearsBefore(year) - leapYearsBefore(1970)`), which
    /// is negative when `year < 1970`, exactly compensating `yearsSince1970` being negative.
    @inlinable
    package static func daysSinceEpoch(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day
    ) -> Int {
        // Optimized calculation avoiding year-by-year iteration
        let yearsSince1970 = year.rawValue - 1970

        // Calculate leap years between 1970 and year (as a signed difference, so it is
        // correct whether `year` is before or after 1970).
        let leapYears = leapYearsBefore(year.rawValue) - leapYearsBefore(1970)

        var days =
            yearsSince1970 * Time.Calendar.Gregorian.TimeConstants.daysPerCommonYear + leapYears

        // Add days for complete months in current year
        let monthDays = Time.Calendar.Gregorian.daysInMonths(year: year.rawValue)
        // SAFE: month.rawValue guaranteed to be in range 1-12 by Time.Month invariant
        for m in 0..<(month.rawValue - 1) {
            days += monthDays[m]
        }

        // Add remaining days
        days += day.rawValue - 1

        return days
    }
}

// MARK: - Floored Division (Internal)

extension Time.Epoch.Conversion {
    /// Floored (Euclidean-style) integer division: rounds toward negative infinity
    /// rather than toward zero.
    ///
    /// Swift's native `/` truncates toward zero, which is the wrong split for negative
    /// dividends in a day/second or year/day decomposition (it would put the remainder
    /// on the wrong side of zero). `divisor` is always a positive calendar constant
    /// (`secondsPerDay`, `daysPer400Years`, `4`, `100`, `400`, ...) in every call site
    /// in this file.
    @inlinable
    package static func floorDiv(_ dividend: Int, _ divisor: Int) -> Int {
        let quotient = dividend / divisor
        let remainder = dividend % divisor
        return remainder < 0 ? quotient - 1 : quotient
    }

    /// Floored (Euclidean-style) integer remainder: always has the same sign as
    /// (non-negative, given) `divisor`, unlike Swift's native `%` which has the same
    /// sign as the dividend.
    @inlinable
    package static func floorMod(_ dividend: Int, _ divisor: Int) -> Int {
        let remainder = dividend % divisor
        return remainder < 0 ? remainder + divisor : remainder
    }
}
