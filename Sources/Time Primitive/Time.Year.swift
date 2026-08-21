extension Time {

    public struct Year: RawRepresentable, Sendable, Equatable, Hashable, Comparable {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public init(_ value: Int) {
            self.rawValue = value
        }
    }
}

extension Time.Year {

    public static func < (lhs: Time.Year, rhs: Time.Year) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Time.Year {

    @inlinable
    public var isLeapYear: Bool {
        Self.isLeapYear(self)
    }

    @inlinable
    public static func isLeapYear(_ year: Time.Year) -> Bool {
        Time.Calendar.Gregorian.isLeapYear(year)
    }
}

extension Time.Year: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
