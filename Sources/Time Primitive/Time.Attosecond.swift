extension Time {

    public struct Attosecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidAttosecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Attosecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidAttosecond(Int)
    }
}

extension Time.Attosecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Attosecond {

    public static func < (lhs: Time.Attosecond, rhs: Time.Attosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Attosecond {

    public static let zero = Time.Attosecond(unchecked: 0)
}
