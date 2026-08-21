extension Time.Calendar.Gregorian {

    public enum Easter {}
}

extension Time.Calendar.Gregorian.Easter {

    public enum Error: Swift.Error, Sendable, Equatable {

        case yearOutOfRange(Int)
    }
}

extension Time.Calendar.Gregorian {

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

        let month = Time.Month(unchecked: monthRaw)
        let day = Time.Month.Day(unchecked: dayRaw)

        return (month: month, day: day)
    }
}
