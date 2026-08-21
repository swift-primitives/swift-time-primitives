extension Time {

    public struct Epoch: Sendable, Equatable, Hashable {

        public let referenceDate: Time

        public init(referenceDate: Time) {
            self.referenceDate = referenceDate
        }
    }
}

extension Time.Epoch {

    public static let unix = Time.Epoch(
        referenceDate: .init(
            _unchecked: (),
            year: 1970,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        )
    )

    public static let ntp = Time.Epoch(
        referenceDate: .init(
            _unchecked: (),
            year: 1900,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        )
    )

    public static let gps = Time.Epoch(
        referenceDate: .init(
            _unchecked: (),
            year: 1980,
            month: 1,
            day: 6,
            hour: 0,
            minute: 0,
            second: 0
        )
    )

    public static let tai = Time.Epoch(
        referenceDate: .init(
            _unchecked: (),
            year: 1958,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    )

    public static let windowsFileTime = Time.Epoch(
        referenceDate: .init(
            _unchecked: (),
            year: 1601,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    )

    public static let appleAbsolute = Time.Epoch(
        referenceDate: .init(
            _unchecked: (),
            year: 2001,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    )
}
