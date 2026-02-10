//
//  DateProvider.swift
//  wsanjusto-ios
//
//  Created by Claude Code on 10/02/2026.
//

import Foundation

protocol DateProviding {
    var now: Date { get }
}

struct SystemDateProvider: DateProviding {
    var now: Date { Date() }
}

struct FixedDateProvider: DateProviding {
    let fixedNow: Date
    var now: Date { fixedNow }
}
