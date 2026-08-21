extension Time {

    public struct Femtosecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidFemtosecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Femtosecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidFemtosecond(Int)
    }
}

extension Time.Femtosecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Femtosecond {

    public static func < (lhs: Time.Femtosecond, rhs: Time.Femtosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Femtosecond {

    public static let zero = Time.Femtosecond(unchecked: 0)
}
