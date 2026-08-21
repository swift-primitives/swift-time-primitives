extension Swift.Duration {

    public static func seconds(_ value: Double) -> Duration {
        let integer = Int64(value)
        let fraction = value - Double(integer)
        return .seconds(integer) + .nanoseconds(Int64(fraction * 1_000_000_000))
    }

    public var inSeconds: Double {
        let (seconds, attoseconds) = self.components
        return Double(seconds) + (Double(attoseconds) / 1_000_000_000_000_000_000)
    }

    public var inMilliseconds: Double {
        inSeconds * 1_000
    }

    public var inMicroseconds: Double {
        inSeconds * 1_000_000
    }

    public var inNanoseconds: Double {
        inSeconds * 1_000_000_000
    }
}
