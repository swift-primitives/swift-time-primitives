# Time Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Calendar and timeline value types for Swift — absolute UTC `Time` with nanosecond precision, timeline `Instant` arithmetic, validated calendar components (year through yoctosecond), the Gregorian and Julian calendars, and duration formatting, with zero platform dependencies.

---

## Quick Start

`Time` is the namespace. Calendar components are *refinement types*: a month is constrained to 1–12, a day is validated against its month and year, so an impossible date cannot be constructed without an explicit error.

```swift
import Time_Primitives

// Pre-validated components compose without throwing.
let year = Time.Year(2024)
let month = Time.Month.february
let day = try Time.Month.Day(29, in: month, year: year)   // valid only in a leap year

// Raw integers are validated; February 30 throws rather than silently wrapping.
let time = try Time(year: 2024, month: 2, day: 29, hour: 14, minute: 30, second: 0)
print(time.weekday)   // .thursday   (Zeller's congruence, no Foundation)
```

`Time` is the calendar view; `Instant` is the timeline view — an absolute point stored as seconds plus a nanosecond fraction since the Unix epoch. Convert between them and do timeline arithmetic with `Swift.Duration`:

```swift
let instant = Instant(time)
let later = instant + .seconds(3600)
let elapsed: Duration = later - instant   // .seconds(3600)

let backToCalendar = Time(later)
```

Epochs are first-class, so timestamps from different systems are unambiguous:

```swift
let unix = Time.Epoch.unix              // 1970-01-01
let gps = Time.Epoch.gps                // 1980-01-06
print(unix.referenceDate.year)          // 1970
```

For astronomy, `Time.Julian.Day` is a phantom-typed coordinate with affine arithmetic — a Julian Day minus a Julian Day is an `Offset`, not another Day:

```swift
import Time_Julian_Primitives

let jd = Time.Julian.Day(time)          // continuous day count
let mjd = jd.modified                   // Modified Julian Day
```

Durations format themselves with automatic unit selection:

```swift
import Time_Format_Primitives

Duration.milliseconds(1500).formatted(.duration)               // "1.5 s"
Duration.microseconds(500).formatted(.duration)                // "500 µs"
Duration.milliseconds(1500).formatted(.duration.precision(2))  // "1.50 s"
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Time Primitives", package: "swift-time-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

The umbrella product `Time Primitives` re-exports four targets. Import the umbrella for everything, or a single target to keep dependencies minimal.

| Product | Import | When to import |
|---------|--------|----------------|
| `Time Primitives` | `Time_Primitives` | Everything below, via one umbrella import. |
| `Time Primitive` | `Time_Primitive` | The `Time` namespace, `Instant`, the calendar/timeline value types, epochs, and the Gregorian calendar. Zero external dependencies. |
| `Time Format Primitives` | `Time_Format_Primitives` | `Duration.formatted(_:)` and `Time.Format` (auto-unit duration strings). Adds the formatting dependencies. |
| `Time Julian Primitives` | `Time_Julian_Primitives` | `Time.Julian.Day` / `Time.Julian.Offset` and their conversions. Adds the dimension dependency. |

The core `Time Primitive` target imports no other Swift packages and uses no Foundation types — distinct calendar (`Time`) and timeline (`Instant`) representations stay distinct, rather than being conflated into a single `Date`.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Swift Embedded | Partial (value types; `Codable` conformances excluded) |

Under Embedded Swift the calendar/timeline value types, arithmetic, epochs, and Julian conversions are available. The `Codable` conformances on `Time`, `Instant`, and `Time.Timezone.Offset` are excluded under Embedded.

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
