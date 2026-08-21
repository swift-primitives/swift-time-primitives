import Testing
import Time_Primitives

@testable import Time_Primitive

@Suite
struct `Time Target Tests` {

    @Test
    func `GregorianCalendar - Leap Year`() {

        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2000)) == true)

        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2100)) == false)

        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2024)) == true)

        #expect(Time.Calendar.Gregorian.isLeapYear(Time.Year(2023)) == false)
    }

    @Test
    func `GregorianCalendar - Days in Month`() {
        #expect(
            Time.Calendar.Gregorian
                .daysInMonth(Time.Year(2024), Time.Month(unchecked: 2)) == 29
        )
        #expect(
            Time.Calendar.Gregorian
                .daysInMonth(Time.Year(2023), Time.Month(unchecked: 2)) == 28
        )
        #expect(
            Time.Calendar.Gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 1)) == 31
        )
        #expect(
            Time.Calendar.Gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 4)) == 30
        )
    }

    @Test
    func `Weekday - Calculate from Date`() throws {

        let monday = try Time.Weekday(year: 2024, month: 1, day: 1)
        #expect(monday == .monday)

        let sunday = try Time.Weekday(year: 2024, month: 1, day: 7)
        #expect(sunday == .sunday)

        let monday2 = try Time.Weekday(year: 2024, month: 1, day: 15)
        #expect(monday2 == .monday)
    }

    @Test
    func `Weekday - All Cases`() {
        let allCases = Time.Weekday.allCases
        #expect(allCases.count == 7)
        #expect(allCases.contains(.monday))
        #expect(allCases.contains(.sunday))
    }

    @Test
    func `Weekday - Known Dates`() throws {

        let independence = try Time.Weekday(year: 1776, month: 7, day: 4)
        #expect(independence == .thursday)

        let millennium = try Time.Weekday(year: 1999, month: 12, day: 31)
        #expect(millennium == .friday)

        let y2k = try Time.Weekday(year: 2000, month: 1, day: 1)
        #expect(y2k == .saturday)
    }

    @Test
    func `Weekday - Invalid Date Throws`() {

        #expect(throws: Time.Weekday.Error.self) {
            try Time.Weekday(year: 2024, month: 13, day: 1)
        }

        #expect(throws: Time.Weekday.Error.self) {
            try Time.Weekday(year: 2024, month: 2, day: 30)
        }

        #expect(throws: Time.Weekday.Error.self) {
            try Time.Weekday(year: 2023, month: 2, day: 29)
        }
    }

    @Test
    func `DateComponents - Validation`() throws {

        let valid = try Time(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45,
            millisecond: 123,
            microsecond: 456,
            nanosecond: 789
        )
        #expect(valid.year.rawValue == 2024)
        #expect(valid.month == 1)
        #expect(valid.day == 15)
        #expect(valid.hour.value == 12)
        #expect(valid.minute.value == 30)
        #expect(valid.second.value == 45)
        #expect(valid.millisecond.value == 123)
        #expect(valid.microsecond.value == 456)
        #expect(valid.nanosecond.value == 789)

        #expect(valid.totalNanoseconds == 123_456_789)

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 13, day: 1, hour: 0, minute: 0, second: 0)
        }

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 2, day: 30, hour: 0, minute: 0, second: 0)
        }

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 24, minute: 0, second: 0)
        }

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 60, second: 0)
        }

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 61)
        }

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0, millisecond: 1000)
        }

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0, microsecond: 1000)
        }

        #expect(throws: Time.Error.self) {
            try Time(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 1000)
        }

        let leapSecond = try Time(
            year: 2024,
            month: 1,
            day: 1,
            hour: 23,
            minute: 59,
            second: 60
        )
        #expect(leapSecond.second.value == 60)
    }

    @Test
    func `EpochConversion - Round Trip`() throws {

        let epoch = Time(secondsSinceEpoch: 0)
        #expect(epoch.year.rawValue == 1970)
        #expect(epoch.month == 1)
        #expect(epoch.day == 1)
        #expect(epoch.hour.value == 0)
        #expect(epoch.minute.value == 0)
        #expect(epoch.second.value == 0)

        let components = try Time(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 0
        )

        let seconds = Time.Epoch.Conversion.secondsSinceEpoch(from: components)

        let roundTrip = Time(secondsSinceEpoch: seconds)
        #expect(roundTrip.year.rawValue == 2024)
        #expect(roundTrip.month == 1)
        #expect(roundTrip.day == 15)
        #expect(roundTrip.hour.value == 12)
        #expect(roundTrip.minute.value == 30)
        #expect(roundTrip.second.value == 0)
    }

    @Test
    func `Calendar - First-Class Value`() {

        let gregorian = Time.Calendar.gregorian

        #expect(gregorian.isLeapYear(Time.Year(2000)) == true)
        #expect(gregorian.isLeapYear(Time.Year(2024)) == true)
        #expect(gregorian.isLeapYear(Time.Year(2100)) == false)

        #expect(gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 2)) == 29)
        #expect(gregorian.daysInMonth(Time.Year(2023), Time.Month(unchecked: 2)) == 28)
        #expect(gregorian.daysInMonth(Time.Year(2024), Time.Month(unchecked: 1)) == 31)
    }

    @Test
    func `Epoch - First-Class Value`() {

        let unix = Time.Epoch.unix
        let ntp = Time.Epoch.ntp
        let gps = Time.Epoch.gps

        #expect(unix.referenceDate.year.rawValue == 1970)
        #expect(unix.referenceDate.month == 1)
        #expect(unix.referenceDate.day == 1)

        #expect(ntp.referenceDate.year.rawValue == 1900)
        #expect(ntp.referenceDate.month == 1)
        #expect(ntp.referenceDate.day == 1)

        #expect(gps.referenceDate.year.rawValue == 1980)
        #expect(gps.referenceDate.month == 1)
        #expect(gps.referenceDate.day == 6)

        #expect(unix == Time.Epoch.unix)
        #expect(unix != ntp)
        #expect(ntp != gps)
    }
}
