extension Time {

    public struct Hour: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...23).contains(value) else {
                throw Error.invalidHour(value)
            }
            self.value = value
        }
    }
}

extension Time.Hour {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidHour(Int)
    }
}

extension Time.Hour {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Hour {

    public static func < (lhs: Time.Hour, rhs: Time.Hour) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Hour {

    public static let zero = Time.Hour(unchecked: 0)
}
