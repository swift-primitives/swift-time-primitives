import Foundation
import Testing
import Time_Primitives

@testable import Time_Primitive

@Suite
struct `Time vs Foundation Comparison Tests` {

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

        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)
    }

    private func foundationWeekday(year: Int, month: Int, day: Int) -> Int? {
        guard let date = foundationDate(year: year, month: month, day: day) else {
            return nil
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.gmt
        return calendar.component(.weekday, from: date)
    }

    @Test
    func `Epoch Conversion - Unix Epoch Zero`() {
        let time = Time(secondsSinceEpoch: 0)

        #expect(time.year.rawValue == 1970)
        #expect(time.month == 1)
        #expect(time.day == 1)
        #expect(time.hour.value == 0)
        #expect(time.minute.value == 0)
        #expect(time.second.value == 0)

        let foundationEpoch = Date(timeIntervalSince1970: 0)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.gmt
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: foundationEpoch
        )

        #expect(time.year.rawValue == components.year)
        #expect(time.month.rawValue == components.month)
        #expect(time.day.rawValue == components.day)
        #expect(time.hour.value == components.hour)
        #expect(time.minute.value == components.minute)
        #expect(time.second.value == components.second)
    }

    @Test(
        arguments: [
            (2000, 1, 1, 0, 0, 0),
            (2024, 1, 15, 12, 30, 45),
            (1999, 12, 31, 23, 59, 59),
            (2020, 2, 29, 0, 0, 0),
            (2038, 1, 19, 3, 14, 7),
            (1980, 1, 6, 0, 0, 0),
        ]
    )
    func `Epoch Conversion - Known dates vs Foundation`(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int
    ) throws {
        let time = try Time(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )

        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        guard
            let foundationDate = foundationDate(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second
            )
        else {
            Issue.record("Failed to create Foundation date")
            return
        }
        let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

        #expect(ourSeconds == foundationSeconds)
    }

    @Test(
        arguments: [
            (2000, 1, 1),
            (2100, 1, 1),
            (2200, 1, 1),
            (1999, 12, 31),
            (2099, 12, 31),
        ]
    )
    func `Epoch Conversion - Century boundaries`(year: Int, month: Int, day: Int) throws {
        let time = try Time(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        guard let foundationDate = foundationDate(year: year, month: month, day: day) else {
            Issue.record("Failed to create Foundation date")
            return
        }
        let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

        #expect(ourSeconds == foundationSeconds)
    }

    @Test(
        arguments: [
            0,
            86400,
            1_000_000_000,
            1_234_567_890,
            1_700_000_000,
            2_147_483_647,
        ]
    )
    func `Epoch Conversion - Round trip with Foundation`(seconds: Int) throws {

        let time = Time(secondsSinceEpoch: seconds)

        let roundTripSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

        #expect(roundTripSeconds == seconds)

        let foundationDate = Date(timeIntervalSince1970: TimeInterval(seconds))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.gmt
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: foundationDate
        )

        #expect(time.year.rawValue == components.year)
        #expect(time.month.rawValue == components.month)
        #expect(time.day.rawValue == components.day)
        #expect(time.hour.value == components.hour)
        #expect(time.minute.value == components.minute)
        #expect(time.second.value == components.second)
    }

    @Test
    func `Epoch Conversion - Every Day in 2024`() throws {
        let year = 2024
        let daysInMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        for month in 1...12 {
            for day in 1...daysInMonths[month - 1] {
                let time = try Time(
                    year: year,
                    month: month,
                    day: day,
                    hour: 0,
                    minute: 0,
                    second: 0
                )
                let ourSeconds = Time.Epoch.Conversion.secondsSinceEpoch(from: time)

                guard let foundationDate = foundationDate(year: year, month: month, day: day) else {
                    Issue.record("Failed to create Foundation date for \(year)-\(month)-\(day)")
                    continue
                }
                let foundationSeconds = Int(foundationDate.timeIntervalSince1970)

                #expect(
                    ourSeconds == foundationSeconds,
                    "Mismatch on \(year)-\(month)-\(day): ours=\(ourSeconds) foundation=\(foundationSeconds)"
                )

                let roundTrip = Time(secondsSinceEpoch: ourSeconds)
                #expect(roundTrip.year.rawValue == year)
                #expect(roundTrip.month == month)
                #expect(roundTrip.day == day)
            }
        }
    }

    @Test(
        arguments: [

            (1776, 7, 4, Time.Weekday.thursday),
            (1969, 7, 20, Time.Weekday.sunday),
            (2000, 1, 1, Time.Weekday.saturday),
            (2001, 9, 11, Time.Weekday.tuesday),
            (2024, 1, 1, Time.Weekday.monday),

            (2024, 1, 31, Time.Weekday.wednesday),
            (2024, 2, 29, Time.Weekday.thursday),
            (2024, 3, 31, Time.Weekday.sunday),
            (2024, 12, 31, Time.Weekday.tuesday),

            (1900, 1, 1, Time.Weekday.monday),
            (2000, 1, 1, Time.Weekday.saturday),
            (2100, 1, 1, Time.Weekday.friday),
        ]
    )
    func `Weekday - Known dates vs Foundation`(
        year: Int,
        month: Int,
        day: Int,
        expectedWeekday: Time.Weekday
    ) throws {
        let weekday = try Time.Weekday(year: year, month: month, day: day)
        #expect(weekday == expectedWeekday)

        if let foundationWeekdayValue = foundationWeekday(year: year, month: month, day: day) {

            let foundationWeekdayEnum: Time.Weekday
            switch foundationWeekdayValue {
            case 1: foundationWeekdayEnum = .sunday
            case 2: foundationWeekdayEnum = .monday
            case 3: foundationWeekdayEnum = .tuesday
            case 4: foundationWeekdayEnum = .wednesday
            case 5: foundationWeekdayEnum = .thursday
            case 6: foundationWeekdayEnum = .friday
            case 7: foundationWeekdayEnum = .saturday
            default: fatalError("Invalid Foundation weekday: \(foundationWeekdayValue)")
            }

            #expect(weekday == foundationWeekdayEnum)
        }
    }

    @Test
    func `Weekday - Every Day in 2024 vs Foundation`() throws {
        let year = 2024
        let daysInMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        for month in 1...12 {
            for day in 1...daysInMonths[month - 1] {
                let weekday = try Time.Weekday(year: year, month: month, day: day)

                if let foundationWeekdayValue = foundationWeekday(
                    year: year,
                    month: month,
                    day: day
                ) {
                    let foundationWeekdayEnum: Time.Weekday
                    switch foundationWeekdayValue {
                    case 1: foundationWeekdayEnum = .sunday
                    case 2: foundationWeekdayEnum = .monday
                    case 3: foundationWeekdayEnum = .tuesday
                    case 4: foundationWeekdayEnum = .wednesday
                    case 5: foundationWeekdayEnum = .thursday
                    case 6: foundationWeekdayEnum = .friday
                    case 7: foundationWeekdayEnum = .saturday
                    default: fatalError("Invalid Foundation weekday: \(foundationWeekdayValue)")
                    }

                    #expect(
                        weekday == foundationWeekdayEnum,
                        "Weekday mismatch for \(year)-\(month)-\(day): ours=\(weekday) foundation=\(foundationWeekdayEnum)"
                    )
                }
            }
        }
    }

    @Test(
        arguments: [
            (1969, 12, 31),
            (1969, 1, 1),
            (1960, 1, 1),
            (1950, 1, 1),
            (1945, 5, 8),
            (1920, 1, 1),
            (1900, 1, 1),
        ]
    )
    func `Weekday - Dates before epoch vs Foundation`(year: Int, month: Int, day: Int) throws {
        let weekday = try Time.Weekday(year: year, month: month, day: day)

        if let foundationWeekdayValue = foundationWeekday(year: year, month: month, day: day) {
            let foundationWeekdayEnum: Time.Weekday
            switch foundationWeekdayValue {
            case 1: foundationWeekdayEnum = .sunday
            case 2: foundationWeekdayEnum = .monday
            case 3: foundationWeekdayEnum = .tuesday
            case 4: foundationWeekdayEnum = .wednesday
            case 5: foundationWeekdayEnum = .thursday
            case 6: foundationWeekdayEnum = .friday
            case 7: foundationWeekdayEnum = .saturday
            default: fatalError("Invalid Foundation weekday: \(foundationWeekdayValue)")
            }

            #expect(weekday == foundationWeekdayEnum)
        }
    }

    @Test(
        arguments: [
            1900, 1904, 1996, 1997, 1998, 1999,
            2000, 2001, 2004, 2020, 2024, 2100, 2400,
        ]
    )
    func `Leap Year - Validate against Foundation`(year: Int) {
        let ourResult = Time.Calendar.Gregorian.isLeapYear(Time.Year(year))

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.gmt

        var components = DateComponents()
        components.year = year
        components.month = 2
        components.day = 29

        if let date = calendar.date(from: components) {
            let resultComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let foundationResult =
                resultComponents.year == year
                && resultComponents.month == 2
                && resultComponents.day == 29

            #expect(ourResult == foundationResult)
        } else {

            #expect(ourResult == false)
        }
    }
}
