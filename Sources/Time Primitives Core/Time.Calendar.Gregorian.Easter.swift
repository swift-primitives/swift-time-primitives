// Time.Calendar.Gregorian.Easter.swift
// Time
//
// Easter date computation via Anonymous Gregorian algorithm (Meeus/Jones/Butcher)

extension Time.Calendar.Gregorian {
    /// Easter date computation namespace.
    ///
    /// Provides the Anonymous Gregorian algorithm (Meeus/Jones/Butcher) for
    /// computing Easter Sunday in the Gregorian calendar. O(1) pure arithmetic.
    public enum Easter {}
}

// MARK: - Error

extension Time.Calendar.Gregorian.Easter {
    /// Validation errors for Easter computation.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Year is before Gregorian calendar adoption (1583)
        case yearOutOfRange(Int)
    }
}

// MARK: - Computation

extension Time.Calendar.Gregorian {
    /// Easter Sunday for a Gregorian calendar year.
    ///
    /// Anonymous Gregorian algorithm (Meeus/Jones/Butcher). O(1) pure arithmetic.
    /// Valid for any year ≥ 1583 (Gregorian calendar adoption).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let (month, day) = try Time.Calendar.Gregorian.easter(year: 2024)
    /// // month == .march, day.rawValue == 31
    /// ```
    ///
    /// - Parameter year: Gregorian calendar year (must be ≥ 1583)
    /// - Returns: Month and day of Easter Sunday
    /// - Throws: `Easter.Error.yearOutOfRange` if year < 1583
    public static func easter(
        year: Time.Year
    ) throws(Easter.Error) -> (month: Time.Month, day: Time.Month.Day) {
        let y = year.rawValue
        guard y >= 1583 else {
            throw .yearOutOfRange(y)
        }

        let a = y % 19
        let b = y / 100
        let c = y % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451

        let monthRaw = (h + l - 7 * m + 114) / 31
        let dayRaw = ((h + l - 7 * m + 114) % 31) + 1

        // SAFE: Algorithm guarantees month ∈ {3, 4} and day is valid for the month
        let month = Time.Month(unchecked: monthRaw)
        let day = Time.Month.Day(unchecked: dayRaw)

        return (month: month, day: day)
    }
}
