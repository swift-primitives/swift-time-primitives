extension Time {

    public struct Yoctosecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidYoctosecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Yoctosecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidYoctosecond(Int)
    }
}

extension Time.Yoctosecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Yoctosecond {

    public static func < (lhs: Time.Yoctosecond, rhs: Time.Yoctosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Yoctosecond {

    public static let zero = Time.Yoctosecond(unchecked: 0)
}
