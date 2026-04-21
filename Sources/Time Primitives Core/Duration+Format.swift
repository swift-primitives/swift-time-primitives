// Duration+Format.swift
// Duration formatting with auto-unit selection.

public import Format_Primitives

extension Time {
    /// Format style for converting Duration values to human-readable strings.
    ///
    /// Automatically selects appropriate units (ns, µs, ms, s) based on
    /// magnitude. Supports configurable precision and notation styles.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Duration.milliseconds(1500).formatted(.duration)              // "1.5 s"
    /// Duration.microseconds(500).formatted(.duration)               // "500 µs"
    /// Duration.milliseconds(1500).formatted(.duration.precision(2)) // "1.50 s"
    /// Duration.seconds(3).formatted(.milliseconds)                  // "3000 ms"
    /// ```
    public struct Format: Sendable {
        /// The unit to display, or auto for automatic selection.
        public let unit: Unit

        /// The notation style (spaced or compact).
        public let notation: Notation

        /// Number of decimal places to display, or nil for automatic.
        public let precisionDigits: Int?

        @usableFromInline
        init(unit: Unit = .auto, notation: Notation = .spaced, precisionDigits: Int? = nil) {
            self.unit = unit
            self.notation = notation
            self.precisionDigits = precisionDigits
        }

        /// Creates a duration format with default settings.
        ///
        /// Defaults: auto unit, spaced notation, automatic precision.
        public init() {
            self.unit = .auto
            self.notation = .spaced
            self.precisionDigits = nil
        }
    }
}

// MARK: - Unit

extension Time.Format {
    /// Unit for duration display.
    public enum Unit: Sendable, Equatable {
        /// Automatically select the most appropriate unit based on magnitude.
        case auto
        /// Display in nanoseconds (ns).
        case nanoseconds
        /// Display in microseconds (µs).
        case microseconds
        /// Display in milliseconds (ms).
        case milliseconds
        /// Display in seconds (s).
        case seconds

        /// The symbol for this unit.
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
}

// MARK: - Notation

extension Time.Format {
    /// Notation style for duration formatting.
    ///
    /// Controls spacing between the numeric value and unit symbol.
    ///
    /// ## Example
    ///
    /// ```swift
    /// duration.formatted(.duration.notation(.spaced))       // "1.5 ms"
    /// duration.formatted(.duration.notation(.compactName))  // "1.5ms"
    /// ```
    public enum Notation: Sendable, Equatable {
        /// Standard notation with space between value and unit.
        ///
        /// Example: "1.5 ms", "500 µs"
        case spaced

        /// Compact notation without space between value and unit.
        ///
        /// Example: "1.5ms", "500µs"
        case compactName

        /// The separator string between value and unit.
        @inlinable
        public var separator: String {
            switch self {
            case .spaced: return " "
            case .compactName: return ""
            }
        }
    }
}

// MARK: - Static Constructors

extension Time.Format {
    /// Default duration format (auto unit, spaced notation).
    @inlinable
    public static var duration: Self { .init() }

    /// Format that always displays nanoseconds.
    @inlinable
    public static var nanoseconds: Self { .init(unit: .nanoseconds) }

    /// Format that always displays microseconds.
    @inlinable
    public static var microseconds: Self { .init(unit: .microseconds) }

    /// Format that always displays milliseconds.
    @inlinable
    public static var milliseconds: Self { .init(unit: .milliseconds) }

    /// Format that always displays seconds.
    @inlinable
    public static var seconds: Self { .init(unit: .seconds) }
}

// MARK: - Chaining Methods

extension Time.Format {
    /// Returns a format with the specified unit.
    @inlinable
    public func unit(_ unit: Unit) -> Self {
        .init(unit: unit, notation: notation, precisionDigits: precisionDigits)
    }

    /// Returns a format with the specified notation style.
    @inlinable
    public func notation(_ notation: Notation) -> Self {
        .init(unit: unit, notation: notation, precisionDigits: precisionDigits)
    }

    /// Returns a format with the specified decimal precision.
    ///
    /// - Parameter digits: Number of decimal places to display.
    @inlinable
    public func precision(_ digits: Int) -> Self {
        .init(unit: unit, notation: notation, precisionDigits: digits)
    }
}

// MARK: - Format.Style Conformance

extension Time.Format: Format.Style {
    public typealias Input = Swift.Duration
    public typealias Output = String

    /// Formats a Duration to a human-readable string.
    ///
    /// - Parameter duration: The Duration to format.
    /// - Returns: A formatted string representation.
    public func format(_ duration: Swift.Duration) -> String {
        let (value, symbol) = selectUnit(for: duration)
        let numericFormat = numericFormatStyle(for: value)
        let numericString = numericFormat.format(value)
        return numericString + notation.separator + symbol
    }
}

// MARK: - Unit Selection

extension Time.Format {
    /// Selects the appropriate unit and calculates the display value.
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
            if seconds < 0.000001 {
                return (duration.inNanoseconds, Unit.nanoseconds.symbol)
            } else if seconds < 0.001 {
                return (duration.inMicroseconds, Unit.microseconds.symbol)
            } else if seconds < 1.0 {
                return (duration.inMilliseconds, Unit.milliseconds.symbol)
            } else {
                return (seconds, Unit.seconds.symbol)
            }
        }
    }

    /// Builds the appropriate `Format.Decimal` for the given value.
    @usableFromInline
    func numericFormatStyle(for value: Double) -> Format_Primitives.Format.Decimal {
        if let digits = precisionDigits {
            return .number.precision(digits)
        }
        return .number
    }
}

// MARK: - Duration Extension

extension Swift.Duration {
    /// Formats this duration to a human-readable string.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Duration.milliseconds(1500).formatted()             // "1.5 s"
    /// Duration.microseconds(500).formatted()              // "500 µs"
    /// Duration.milliseconds(1500).formatted(.milliseconds) // "1500 ms"
    /// ```
    ///
    /// - Parameter format: Format style to apply. Defaults to automatic unit selection.
    /// - Returns: Formatted string representation.
    @inlinable
    public func formatted(_ format: Time.Format = .duration) -> String {
        format.format(self)
    }
}
