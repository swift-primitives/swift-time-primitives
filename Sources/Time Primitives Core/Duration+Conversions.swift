// Duration+Conversions.swift
// Convenience conversions for Swift.Duration

extension Swift.Duration {
    /// Create a Duration from seconds as Double.
    ///
    /// Converts a floating-point seconds value to a Duration with nanosecond precision.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let duration = Duration.seconds(1.5)  // 1 second + 500 milliseconds
    /// ```
    ///
    /// - Parameter value: Seconds as a floating-point value.
    /// - Returns: A Duration representing the specified number of seconds.
    public static func seconds(_ value: Double) -> Duration {
        let integer = Int64(value)
        let fraction = value - Double(integer)
        return .seconds(integer) + .nanoseconds(Int64(fraction * 1_000_000_000))
    }

    /// Convert Duration to seconds as Double.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let duration = Duration.milliseconds(1500)
    /// print(duration.inSeconds)  // 1.5
    /// ```
    public var inSeconds: Double {
        let (seconds, attoseconds) = self.components
        return Double(seconds) + (Double(attoseconds) / 1_000_000_000_000_000_000)
    }

    /// Convert Duration to milliseconds as Double.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let duration = Duration.seconds(1) + .milliseconds(500)
    /// print(duration.inMilliseconds)  // 1500.0
    /// ```
    public var inMilliseconds: Double {
        inSeconds * 1_000
    }

    /// Convert Duration to microseconds as Double.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let duration = Duration.milliseconds(1)
    /// print(duration.inMicroseconds)  // 1000.0
    /// ```
    public var inMicroseconds: Double {
        inSeconds * 1_000_000
    }

    /// Convert Duration to nanoseconds as Double.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let duration = Duration.microseconds(1)
    /// print(duration.inNanoseconds)  // 1000.0
    /// ```
    public var inNanoseconds: Double {
        inSeconds * 1_000_000_000
    }
}
