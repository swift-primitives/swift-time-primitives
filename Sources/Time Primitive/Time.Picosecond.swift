extension Time {

    public struct Picosecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidPicosecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Picosecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidPicosecond(Int)
    }
}

extension Time.Picosecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Picosecond {

    public static func < (lhs: Time.Picosecond, rhs: Time.Picosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Picosecond {

    public static let zero = Time.Picosecond(unchecked: 0)
}
