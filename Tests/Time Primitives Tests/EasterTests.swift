// EasterTests.swift
// Time Tests
//
// Tests for Easter/Computus algorithm

import Testing

@testable import Time_Primitives_Core

@Suite
struct `Easter Tests` {

    @Test
    func `2024 — March 31`() throws {
        let (month, day) = try Time.Calendar.Gregorian.easter(year: 2024)
        #expect(month == .march)
        #expect(day == 31)
    }

    @Test
    func `2025 — April 20`() throws {
        let (month, day) = try Time.Calendar.Gregorian.easter(year: 2025)
        #expect(month == .april)
        #expect(day == 20)
    }

    @Test
    func `2026 — April 5`() throws {
        let (month, day) = try Time.Calendar.Gregorian.easter(year: 2026)
        #expect(month == .april)
        #expect(day == 5)
    }

    @Test
    func `2027 — March 28`() throws {
        let (month, day) = try Time.Calendar.Gregorian.easter(year: 2027)
        #expect(month == .march)
        #expect(day == 28)
    }

    @Test
    func `2000 — April 23`() throws {
        let (month, day) = try Time.Calendar.Gregorian.easter(year: 2000)
        #expect(month == .april)
        #expect(day == 23)
    }

    @Test
    func `1583 — April 10`() throws {
        let (month, day) = try Time.Calendar.Gregorian.easter(year: 1583)
        #expect(month == .april)
        #expect(day == 10)
    }

    @Test
    func `year before 1583 throws yearOutOfRange`() {
        #expect(throws: Time.Calendar.Gregorian.Easter.Error.yearOutOfRange(1582)) {
            try Time.Calendar.Gregorian.easter(year: 1582)
        }
    }
}
