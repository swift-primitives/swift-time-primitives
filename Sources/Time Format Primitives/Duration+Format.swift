public import Format_Primitives
import Formatter_Primitives
public import Time_Primitive

extension Time {

    public struct Format: Sendable {

        public let unit: Unit

        public let notation: Notation

        public let precisionDigits: Int?

        @usableFromInline
        init(unit: Unit = .auto, notation: Notation = .spaced, precisionDigits: Int? = nil) {
            self.unit = unit
            self.notation = notation
            self.precisionDigits = precisionDigits
        }

        public init() {
            self.unit = .auto
            self.notation = .spaced
            self.precisionDigits = nil
        }
    }
}

extension Time.Format {

    public enum Unit: Sendable, Equatable {

        case auto

        case nanoseconds

        case microseconds

        case milliseconds

        case seconds
    }
}

extension Time.Format.Unit {

    @inlinable
    public var symbol: String {
        switch self {
        case .auto: return ""
        case .nanoseconds: return "ns"
        case .microseconds: return "µs"
        case .milliseconds: return "ms"
        case .seconds: return "s"
        }
    }
}

extension Time.Format {

    public enum Notation: Sendable, Equatable {

        case spaced

        case compactName
    }
}

extension Time.Format.Notation {

    @inlinable
    public var separator: String {
        switch self {
        case .spaced: return " "
        case .compactName: return ""
        }
    }
}

extension Time.Format {

    @inlinable
    public static var duration: Self { .init() }

    @inlinable
    public static var nanoseconds: Self { .init(unit: .nanoseconds) }

    @inlinable
    public static var microseconds: Self { .init(unit: .microseconds) }

    @inlinable
    public static var milliseconds: Self { .init(unit: .milliseconds) }

    @inlinable
    public static var seconds: Self { .init(unit: .seconds) }
}

extension Time.Format {

    @inlinable
    public func unit(_ unit: Unit) -> Self {
        .init(unit: unit, notation: notation, precisionDigits: precisionDigits)
    }

    @inlinable
    public func notation(_ notation: Notation) -> Self {
        .init(unit: unit, notation: notation, precisionDigits: precisionDigits)
    }

    @inlinable
    public func precision(_ digits: Int) -> Self {
        .init(unit: unit, notation: notation, precisionDigits: digits)
    }
}

extension Time.Format: Formatter.`Protocol` {

    public typealias Input = Swift.Duration

    public typealias Output = String

    public typealias Failure = Never

    @inlinable
    public func format(_ duration: Swift.Duration) -> String {
        let (value, symbol) = selectUnit(for: duration)
        let numericFormat = numericFormatStyle(for: value)
        let numericString = numericFormat.format(value)
        return numericString + notation.separator + symbol
    }
}

extension Time.Format {

    @usableFromInline
    func selectUnit(for duration: Swift.Duration) -> (Double, String) {
        switch unit {
        case .nanoseconds:
            return (duration.inNanoseconds, Unit.nanoseconds.symbol)

        case .microseconds:
            return (duration.inMicroseconds, Unit.microseconds.symbol)

        case .milliseconds:
            return (duration.inMilliseconds, Unit.milliseconds.symbol)

        case .seconds:
            return (duration.inSeconds, Unit.seconds.symbol)

        case .auto:
            let seconds = duration.inSeconds
            let magnitude = abs(seconds)
            if magnitude < 0.000001 {
                return (duration.inNanoseconds, Unit.nanoseconds.symbol)
            } else if magnitude < 0.001 {
                return (duration.inMicroseconds, Unit.microseconds.symbol)
            } else if magnitude < 1.0 {
                return (duration.inMilliseconds, Unit.milliseconds.symbol)
            } else {
                return (seconds, Unit.seconds.symbol)
            }
        }
    }

    @usableFromInline
    func numericFormatStyle(for value: Double) -> Format_Primitives.Format.Decimal {
        if let digits = precisionDigits {
            return .number.precision(digits)
        }
        return .number
    }
}

extension Swift.Duration {

    @inlinable
    public func formatted(_ format: Time.Format = .duration) -> String {
        format.format(self)
    }
}
