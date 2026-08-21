extension Time {

    public struct Month: RawRepresentable, Sendable, Equatable, Hashable, Comparable {

        public let rawValue: Int

        public init?(rawValue: Int) {
            guard (1...12).contains(rawValue) else {
                return nil
            }
            self.rawValue = rawValue
        }

        public init(_ value: Int) throws(Self.Error) {
            guard (1...12).contains(value) else {
                throw Error.invalidMonth(value)
            }
            self.rawValue = value
        }
    }
}

extension Time.Month {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidMonth(Int)
    }
}

extension Time.Month {

    internal init(unchecked value: Int) {
        self.rawValue = value
    }
}

extension Time.Month {

    public static func < (lhs: Time.Month, rhs: Time.Month) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Time.Month {

    public static func == (lhs: Time.Month, rhs: Int) -> Bool {
        lhs.rawValue == rhs
    }

    public static func == (lhs: Int, rhs: Time.Month) -> Bool {
        lhs == rhs.rawValue
    }
}

extension Time.Month {

    @inlinable
    public func days(in year: Time.Year) -> Int {
        Self.days(in: year, month: self)
    }

    @inlinable
    public static func days(in year: Time.Year, month: Time.Month) -> Int {
        Time.Calendar.Gregorian.daysInMonth(year, month)
    }
}

extension Time.Month {

    public static let january = Self(unchecked: 1)

    public static let february = Self(unchecked: 2)

    public static let march = Self(unchecked: 3)

    public static let april = Self(unchecked: 4)

    public static let may = Self(unchecked: 5)

    public static let june = Self(unchecked: 6)

    public static let july = Self(unchecked: 7)

    public static let august = Self(unchecked: 8)

    public static let september = Self(unchecked: 9)

    public static let october = Self(unchecked: 10)

    public static let november = Self(unchecked: 11)

    public static let december = Self(unchecked: 12)
}
