extension Time {

    public struct Calendar: Sendable {

        public let isLeapYear: @Sendable (Time.Year) -> Bool

        public let daysInMonth: @Sendable (Time.Year, Time.Month) -> Int

        public init(
            isLeapYear: @escaping @Sendable (Time.Year) -> Bool,
            daysInMonth: @escaping @Sendable (Time.Year, Time.Month) -> Int
        ) {
            self.isLeapYear = isLeapYear
            self.daysInMonth = daysInMonth
        }
    }
}

extension Time.Calendar {

    public static let gregorian = Time.Calendar(
        isLeapYear: Time.Calendar.Gregorian.isLeapYear,
        daysInMonth: Time.Calendar.Gregorian.daysInMonth
    )
}
