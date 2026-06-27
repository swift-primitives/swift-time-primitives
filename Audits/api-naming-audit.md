# Time Primitives API Naming Audit

<!--
---
version: 1.0.0
last_updated: 2026-02-27
status: RECOMMENDATION
---
-->

## Context

Audit of swift-time-primitives against the **implementation** skill, triggered by
`inSeconds` compound identifier violation. Expanded to full [API-NAME-002] and
[IMPL-*] compliance review. Informed by two companion research documents in
`swift-institute/Research/`:

- `time-primitives-api-prior-art.md` — cross-language survey (Rust, Java, C++, Haskell, Go, Python, Swift stdlib)
- `time-api-naming-literature-review.md` — academic/practitioner literature (Bloch, Fowler, Muratori, Schankin et al., SE-0329)

## Question

What is the correct API surface for swift-time-primitives, given [API-NAME-002]
(no compound identifiers) and [IMPL-INTENT] (code reads as intent)?

## Findings

### 1. Duration Conversion Properties — CRITICAL

**Current** (violates [API-NAME-002]):
```swift
duration.inSeconds        // compound identifier
duration.inMilliseconds
duration.inMicroseconds
duration.inNanoseconds
```

**Recommended**: `duration.total.seconds` via nested accessor.

```swift
duration.total.seconds       // 1.5
duration.total.milliseconds  // 1500.0
duration.total.microseconds  // 1_500_000.0
duration.total.nanoseconds   // 1_500_000_000.0
```

**Rationale**:
- `total` disambiguates from `.components.seconds` (the stored seconds field).
  The Python `.seconds` vs `.total_seconds()` and C# `.Seconds` vs `.TotalSeconds`
  confusion is a documented, frequent source of bugs.
- `in` is a Swift keyword (requires backticks). `as` is also a keyword.
  `total` has no keyword conflict.
- Cross-language precedent: C# `TotalSeconds`, Python `total_seconds()`.
- Generalizes across the ecosystem: `size.total.bytes`, `angle.total.degrees`,
  `frequency.total.hertz`.

**Implementation**: Zero-cost `Swift.Duration.Total` struct with `@inlinable`
computed properties. No new package dependencies needed.

**Cascading change**: `Duration+Format.swift` calls `inSeconds` etc. ~10 times
in `selectUnit(for:)`.

### 2. Instant Stored Properties — CRITICAL

**Current** (violates [API-NAME-002]):
```swift
instant.secondsSinceUnixEpoch   // compound
instant.nanosecondFraction      // compound
```

**Recommended**: Simple rename.
```swift
instant.seconds      // Int64, seconds since Unix epoch
instant.nanoseconds  // Int32, sub-second fraction (0-999,999,999)
```

**Rationale**:
- `Instant` is documented as "a point on the UTC timeline" since Unix epoch.
  Type context makes epoch-relative semantics unambiguous.
- The (seconds, nanoseconds) two-part representation is so conventional
  (POSIX `timespec`, Java `Instant`, Haskell `SystemTime`, Go `Time`) that
  developers expect `nanoseconds` to be the fraction.
- `Int32` return type reinforces fraction semantics (can't hold total epoch ns).
- Follows Go's approach: rely on type name for context.

### 3. Time Epoch Access — CRITICAL

**Current** (violates [API-NAME-002]):
```swift
time.secondsSinceEpoch   // compound
```

**Recommended**: Nested accessor.
```swift
time.epoch.seconds
```

**Rationale**: Unlike `Instant`, `Time` is a calendar type — it doesn't
inherently imply an epoch. The `epoch` accessor makes the domain crossing
explicit.

### 4. Time Sub-Second Aggregate — MEDIUM

**Current** (violates [API-NAME-002]):
```swift
time.totalNanoseconds    // compound
```

**Recommended**: Nested accessor.
```swift
time.subsecond.nanoseconds
```

**Rationale**: Aggregates millisecond + microsecond + nanosecond fields into
one Int. `subsecond` describes what it is; `nanoseconds` describes the unit.

### 5. Instant Arithmetic Normalization — MEDIUM

**Current** (mechanism, violates [IMPL-EXPR-001]):
```swift
while totalNanos >= 1_000_000_000 {
    totalSeconds += 1
    totalNanos -= 1_000_000_000
}
while totalNanos < 0 {
    totalSeconds -= 1
    totalNanos += 1_000_000_000
}
```

**Recommended**: Single expression.
```swift
let (carry, nanos) = totalNanos.quotientAndRemainder(dividingBy: 1_000_000_000)
totalSeconds += carry
// Handle negative remainder
```

**Rationale**: O(1) vs O(n). Reads as intent. Same fix in both `add` and
`subtract`.

### 6. Refinement Type Consistency — LOW

**Current**: `Hour`/`Minute`/`Second`/`Millisecond`/etc. use `.value`.
`Year`/`Month` use `.rawValue` (via `RawRepresentable`).

**Recommended**: Make all refinement types conform to `RawRepresentable`.
Unifies on `.rawValue` throughout. Provides `init?(rawValue:)` alongside
existing throwing inits.

### 7. Missing WORKAROUND Comments — LOW

**Current**: `@_disfavoredOverload` on `Instant` `+` and `-` operators
(lines 108, 149) has no documentation.

**Recommended**: Add [PATTERN-016] comments documenting the workaround for
`InstantProtocol` default operator ambiguity.

### 8. Epoch Static Constants — DEFERRED

`windowsFileTime` and `appleAbsolute` are compound names but low call-site
frequency. Fix requires adding `Time.Epoch.Windows` and `Time.Epoch.Apple`
namespace enums. Marginal benefit.

## Priority

| # | Fix | Severity | Files |
|---|-----|----------|-------|
| 1 | `duration.total.seconds` | CRITICAL | Duration+Conversions.swift, Duration+Format.swift |
| 2 | Instant field rename | CRITICAL | Instant.swift + all Instant call sites |
| 3 | `time.epoch.seconds` | CRITICAL | Time.swift |
| 4 | `time.subsecond.nanoseconds` | MEDIUM | Time.swift |
| 5 | Instant arithmetic | MEDIUM | Instant.swift |
| 6 | RawRepresentable unification | LOW | 8+ refinement type files |
| 7 | WORKAROUND comments | LOW | Instant.swift |
| 8 | Epoch statics | DEFERRED | Time.Epoch.swift |

## Performance

All changes are naming/structural with identical codegen, except #5 which
improves from O(n) to O(1) (single division replaces while loops).

## References

- `swift-institute/Research/time-primitives-api-prior-art.md`
- `swift-institute/Research/time-api-naming-literature-review.md`
- [API-NAME-002] No compound identifiers
- [IMPL-INTENT] Code reads as intent
- [IMPL-EXPR-001] Single expressions over separate declarations
- [PATTERN-016] Conscious technical debt documentation
- SE-0329: Clock, Instant, and Duration
