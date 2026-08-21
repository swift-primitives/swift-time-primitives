extension Time {

    public struct Nanosecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidNanosecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Nanosecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidNanosecond(Int)
    }
}

extension Time.Nanosecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Nanosecond {

    public static func < (lhs: Time.Nanosecond, rhs: Time.Nanosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Nanosecond {

    public static let zero = Time.Nanosecond(unchecked: 0)
}
