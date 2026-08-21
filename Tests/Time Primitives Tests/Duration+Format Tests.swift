import Testing
import Time_Primitives

@Suite
struct `Duration Format Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Duration Format Tests`.Unit {
    @Test
    func `automatic units cover subsecond boundaries`() {
        #expect(Duration.nanoseconds(500).formatted() == "500 ns")
        #expect(Duration.microseconds(500).formatted() == "500 µs")
        #expect(Duration.milliseconds(500).formatted() == "500 ms")
        #expect(Duration.milliseconds(1_500).formatted() == "1.5 s")
    }

    @Test
    func `forced units and precision are honored`() {
        let duration = Duration.milliseconds(1_500)

        #expect(duration.formatted(.seconds.precision(2)) == "1.50 s")
        #expect(duration.formatted(.milliseconds) == "1500 ms")
        #expect(duration.formatted(.microseconds.notation(.compactName)) == "1500000µs")
    }

    @Test
    func `floating point construction preserves unit conversions`() {
        let duration = Duration.seconds(1.25)

        #expect(abs(duration.inSeconds - 1.25) < 1e-12)
        #expect(abs(duration.inMilliseconds - 1_250) < 1e-9)
        #expect(abs(duration.inMicroseconds - 1_250_000) < 1e-6)
        #expect(abs(duration.inNanoseconds - 1_250_000_000) < 1e-3)
    }
}

extension `Duration Format Tests`.`Edge Case` {
    @Test
    func `negative durations select units by magnitude`() {
        #expect(Duration.seconds(-1.5).formatted() == "-1.5 s")
        #expect(Duration.milliseconds(-500).formatted() == "-500 ms")
        #expect(Duration.microseconds(-500).formatted() == "-500 µs")
        #expect(Duration.nanoseconds(-500).formatted() == "-500 ns")
    }

    @Test
    func `large durations retain explicit unit meaning`() {
        let duration = Duration.seconds(1_000_000_000)

        #expect(duration.formatted(.seconds) == "1000000000 s")
        #expect(duration.inSeconds == 1_000_000_000)
    }
}

extension `Duration Format Tests`.Integration {
    @Test
    func `format style is reusable through the formatter protocol surface`() {
        let format = Time.Format.duration.precision(3)

        #expect(format.format(.milliseconds(1_250)) == "1.250 s")
        #expect(Duration.milliseconds(1_250).formatted(format) == "1.250 s")
    }
}
