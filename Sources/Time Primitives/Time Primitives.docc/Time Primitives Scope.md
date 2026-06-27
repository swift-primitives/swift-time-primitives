# Time Primitives Scope

The identity boundary of `swift-time-primitives`.

## Identity

`swift-time-primitives` provides the **calendar and timeline value substrate**:
absolute UTC time with nanosecond precision (`Time`), instantaneous timeline
points (`Instant`), durations, and the full ladder of sub-second through
calendar-component value types (attosecond → year, week, weekday, month, day,
hour, minute, second, timezone offset, epoch, Gregorian calendar including the
Computus). It owns the `Time` namespace and every stdlib-only value type that
expresses a point or span on the civil/scientific timeline.

## Core targets

- **Time Primitive** — the `Time` namespace plus every stdlib-only foundational
  value type (the 28 calendar/timeline value declarations). Zero external
  dependencies per [MOD-017].
- **Time Format Primitives** — duration formatting with auto-unit selection
  (`Time.Format`, `Duration.formatted(_:)`). Carries the `Format Primitives` +
  `Formatter Primitives` dependencies because its signature surfaces
  `Format.Decimal` and conforms to `Formatter.Protocol`.
- **Time Julian Primitives** — the `Time.Julian` sub-namespace (Julian Day /
  Julian Offset and their conversions). Carries the `Dimension Primitives`
  dependency.
- **Time Primitives** — the umbrella, re-exporting the root + all sub-namespaces.

## Out of scope

- Wall-clock / monotonic clock sources and reading "now": → `swift-clock-primitives`.
- Angular / spatial dimension types (the `Coordinate`/`Tagged` machinery the
  Julian conversions consume): → `swift-dimension-primitives`.
- Numeric format styles and formatter machinery: → `swift-format-primitives`,
  `swift-formatter-primitives` (consumed, not owned).
- Time-zone databases, locale-aware calendars, and parsing of textual date
  representations: lives in consumer code / higher-layer standards packages.

## Evaluation rule

Sub-target additions are evaluated against this scope. If a proposed addition is
OUT of scope, it extracts to a sibling package, not into this one.
