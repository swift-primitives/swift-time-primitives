// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-time-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-time-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Instant {
    /// Converts a Duration to milliseconds for epoll/poll-style timeouts.
    ///
    /// - Parameter duration: The duration to convert, or `nil` for infinite wait.
    /// - Returns: Milliseconds as `CInt`. Returns `-1` for infinite (nil).
    ///   Saturates at `CInt.max` for very large durations.
    ///
    /// This is a pure conversion function with no policy decisions.
    /// The caller decides what "infinite" means and when to use it.
    @inlinable
    public static func milliseconds(from duration: Duration?) -> CInt {
        guard let duration else { return -1 }
        let (seconds, attoseconds) = duration.components
        let ms = seconds * 1000 + attoseconds / 1_000_000_000_000_000
        return ms > Int64(CInt.max) ? CInt.max : CInt(ms)
    }
}
