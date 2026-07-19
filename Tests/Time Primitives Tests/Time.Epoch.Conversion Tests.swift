// Time.Epoch.Conversion Tests.swift
// Time Primitives Tests
//
// Regression tests for fable-448 F-001: epoch conversion silently produced invalid or
// wrong values for all pre-1970 timestamps (negative `secondsSinceEpoch` / negative
// `year`). Follows [INST-TEST-013]: an @Suite subdomain extension of the affected
// source type, with tests nested under the `Edge Case` sub-suite.

import Foundation
import Testing

@testable import Time_Primitive

extension Time.Epoch.Conversion {
    @Suite
    struct Tests {
        @Suite
        struct `Edge Case` {}
    }
}

extension Time.Epoch.Conversion.Tests.`Edge Case` {

    // Helper to create a Foundation Date from calendar components in UTC.
    private func foundationDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0
    ) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components)
    }

    // MARK: - Pre-1970 dates vs Foundation (previously disabled; F-001 primary evidence)

    @Test(
        arguments: [
            (1969, 12, 31),  // Day before epoch
            (1969, 1, 1),  // Start of 1969
            (1960, 1, 1),  // Start of 1960s
            (1950, 1, 1),  // Mid-century
            (1945, 5, 8),  // VE Day
            (1920, 1, 1),  // Roaring Twenties
            (1900, 1, 1),  // Century boundary, non-leap century
            (1800, 1, 1),  // Century boundary, non-leap century
            (1700, 1, 1),  // Century boundary, non-leap century
            (1600, 1, 1),  // Century boundary, leap century (÷400)
        ]
    )
    func `secondsSinceEpoch matches Foundation for dates before 1970`(
        year: Int,
        month: Int,
        day: Int
    ) throws {
        let time = try Time(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        let expectedDate = try #require(foundationDate(year: year, month: month, day: day))
        let foundationSeconds = Int(expectedDate.timeIntervalSince1970)

        #expect(
            ourSeconds == foundationSeconds,
            "Epoch seconds mismatch for \(year)-\(month)-\(day): ours=\(ourSeconds) foundation=\(foundationSeconds)"
        )
        #expect(ourSeconds < 0, "Date before 1970 should have negative epoch seconds")
    }

    @Test(
        arguments: [
            (1969, 12, 31),
            (1960, 1, 1),
            (1945, 5, 8),
            (1900, 1, 1),
            (1800, 1, 1),
            (1700, 1, 1),
        ]
    )
    func `componentsRaw round trips for dates before 1970`(year: Int, month: Int, day: Int) throws {
        let time = try Time(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        let roundTrip = Time(secondsSinceEpoch: ourSeconds)

        #expect(roundTrip.year.rawValue == year)
        #expect(roundTrip.month.rawValue == month)
        #expect(roundTrip.day.rawValue == day)
    }

    // MARK: - Symmetric leap-year counting (daysSinceEpoch, package API)

    @Test
    func `daysSinceEpoch counts the leap day for 1968 when going backward from 1970`() throws {
        // 1968 is a leap year (366 days), 1969 is not (365 days), so 1968-01-01 is
        // exactly 731 days before 1970-01-01.
        let year: Time.Year = 1968
        let month = try Time.Month(1)
        let days = Time.Epoch.Conversion.daysSinceEpoch(
            year: year,
            month: month,
            day: try Time.Month.Day(1, in: month, year: year)
        )
        #expect(days == -731)
    }

    @Test
    func `daysSinceEpoch is antisymmetric around 1970 for a non-leap-affected span`() throws {
        // 1971-01-01 is +365 days from epoch; 1969-01-01 is -365 days (1969 has no leap
        // day between it and 1970).
        let january = try Time.Month(1)
        let year1971: Time.Year = 1971
        let year1969: Time.Year = 1969
        let forward = Time.Epoch.Conversion.daysSinceEpoch(
            year: year1971,
            month: january,
            day: try Time.Month.Day(1, in: january, year: year1971)
        )
        let backward = Time.Epoch.Conversion.daysSinceEpoch(
            year: year1969,
            month: january,
            day: try Time.Month.Day(1, in: january, year: year1969)
        )
        #expect(forward == 365)
        #expect(backward == -365)
    }

    // MARK: - Century-skip boundary (the specific bug found while verifying the fix:
    // a January-anchored 4-year-block decomposition silently mis-decodes the block
    // immediately following a non-x400 century boundary, e.g. 1900-1904 or the
    // symmetric case before 1970; this is not explicitly named in F-001's evidence
    // locations but is the same root defect the fix must not merely paper over for
    // pre-1970 dates only)

    @Test(
        arguments: [
            -900_690,  // -497-12-31 (last day of a non-leap century-skip year, computed via Foundation-independent reference)
            -900_689,  // -496-01-01 (first day of the following year)
        ]
    )
    func `componentsRaw does not overflow into a 13th month across a century-skip boundary`(
        secondsSinceEpochDays: Int
    ) {
        let seconds =
            secondsSinceEpochDays * Time.Calendar.Gregorian.TimeConstants.secondsPerDay
        let (year, month, day, _, _, _) = Time.Epoch.Conversion.componentsRaw(
            fromSecondsSinceEpoch: seconds
        )
        #expect((1...12).contains(month), "month=\(month) out of range for computed year=\(year) day=\(day)")
    }

    @Test
    func `year -497 to -496 boundary decodes correctly`() throws {
        // -497 is not a leap year (divisible by 100 [-500 nearest], not 4-pattern-aligned
        // the way a naive per-cycle block assumption expects); this pins down the exact
        // boundary discovered while brute-force verifying the fix against a reference
        // proleptic-Gregorian day-count algorithm.
        let yearMinus497: Time.Year = -497
        let december = try Time.Month(12)
        let yearMinus496: Time.Year = -496
        let january = try Time.Month(1)

        let lastDayOfMinus497 = Time.Epoch.Conversion.daysSinceEpoch(
            year: yearMinus497,
            month: december,
            day: try Time.Month.Day(31, in: december, year: yearMinus497)
        )
        let firstDayOfMinus496 = Time.Epoch.Conversion.daysSinceEpoch(
            year: yearMinus496,
            month: january,
            day: try Time.Month.Day(1, in: january, year: yearMinus496)
        )
        #expect(firstDayOfMinus496 == lastDayOfMinus497 + 1)

        let (backYear, backMonth, backDay, _, _, _) = Time.Epoch.Conversion.componentsRaw(
            fromSecondsSinceEpoch: firstDayOfMinus496
                * Time.Calendar.Gregorian.TimeConstants.secondsPerDay
        )
        #expect((backYear, backMonth, backDay) == (-496, 1, 1))
    }
}
