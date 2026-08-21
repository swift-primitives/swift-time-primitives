extension Time {

    public struct Millisecond: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...999).contains(value) else {
                throw Error.invalidMillisecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Millisecond {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidMillisecond(Int)
    }
}

extension Time.Millisecond {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Millisecond {

    public static func < (lhs: Time.Millisecond, rhs: Time.Millisecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Millisecond {

    public static let zero = Time.Millisecond(unchecked: 0)
}
