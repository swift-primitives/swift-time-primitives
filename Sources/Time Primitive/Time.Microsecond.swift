extension Time {

    public struct Microsecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidMicrosecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Microsecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidMicrosecond(Int)
    }
}

extension Time.Microsecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Microsecond {

    public static func < (lhs: Time.Microsecond, rhs: Time.Microsecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Microsecond {

    public static let zero = Time.Microsecond(unchecked: 0)
}
