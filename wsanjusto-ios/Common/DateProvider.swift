//
//  DateProvider.swift
//  wsanjusto-ios
//
//  Created by Claude Code on 10/02/2026.
//

import Foundation

protocol DateProviding: Sendable {
    var now: Date { get }
}

struct SystemDateProvider: DateProviding, Sendable {
    var now: Date { Date() }
}

struct FixedDateProvider: DateProviding, Sendable {
    let fixedNow: Date
    var now: Date { fixedNow }
}
