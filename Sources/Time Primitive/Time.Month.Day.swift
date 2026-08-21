extension Time.Month {

    public struct Day: Sendable, Equatable, Hashable, Comparable {

        public let rawValue: Int

        public init(_ value: Int, in month: Time.Month, year: Time.Year) throws(Self.Error) {
            let maxDay = month.days(in: year)
            guard (1...maxDay).contains(value) else {
                throw Error.invalidDay(value, month: month, year: year)
            }
            self.rawValue = value
        }
    }
}

extension Time.Month.Day {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidDay(Int, month: Time.Month, year: Time.Year)
    }
}

extension Time.Month.Day {

    internal init(unchecked value: Int) {
        self.rawValue = value
    }
}

extension Time.Month.Day {

    public static func < (lhs: Time.Month.Day, rhs: Time.Month.Day) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Time.Month.Day {

    public static func == (lhs: Time.Month.Day, rhs: Int) -> Bool {
        lhs.rawValue == rhs
    }

    public static func == (lhs: Int, rhs: Time.Month.Day) -> Bool {
        lhs == rhs.rawValue
    }
}
