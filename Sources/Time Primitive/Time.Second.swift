extension Time {

    public struct Second: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...60).contains(value) else {
                throw Error.invalidSecond(value)
            }
            self.value = value
        }
    }
}

extension Time.Second {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidSecond(Int)
    }
}

extension Time.Second {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Second {

    public static func < (lhs: Time.Second, rhs: Time.Second) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Second {

    public static let zero = Time.Second(unchecked: 0)
}
