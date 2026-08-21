extension Time {

    public struct Minute: Sendable, Equatable, Hashable, Comparable {

        public let value: Int

        public init(_ value: Int) throws(Self.Error) {
            guard (0...59).contains(value) else {
                throw Error.invalidMinute(value)
            }
            self.value = value
        }
    }
}

extension Time.Minute {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidMinute(Int)
    }
}

extension Time.Minute {

    internal init(unchecked value: Int) {
        self.value = value
    }
}

extension Time.Minute {

    public static func < (lhs: Time.Minute, rhs: Time.Minute) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Minute {

    public static let zero = Time.Minute(unchecked: 0)
}
