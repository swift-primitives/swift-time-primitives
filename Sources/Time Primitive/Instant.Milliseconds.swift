extension Instant {

    @inlinable
    public static func milliseconds(from duration: Duration?) -> CInt {
        guard let duration else { return -1 }
        let (seconds, attoseconds) = duration.components
        let ms = seconds * 1000 + attoseconds / 1_000_000_000_000_000
        return ms > Int64(CInt.max) ? CInt.max : CInt(ms)
    }
}
