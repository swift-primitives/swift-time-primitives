extension Time {

    public struct Zeptosecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidZeptosecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Zeptosecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidZeptosecond(Int)
    }
}

extension Time.Zeptosecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Zeptosecond {

    public static func < (lhs: Time.Zeptosecond, rhs: Time.Zeptosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Zeptosecond {

    public static let zero = Time.Zeptosecond(unchecked: 0)
}
