//
//  MockMeasureRepository.swift
//  wsanjusto-iosTests
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation
@testable import wsanjusto_ios

/// Mock implementation of MeasureRepository for testing
final class MockMeasureRepository: MeasureRepository, @unchecked Sendable {
    var measuresToReturn: [Measure] = []
    var fetchCallCount = 0
    var lastRequestedLimit: Int?
    
    func fetchMeasures(limit: Int) async -> [Measure] {
        fetchCallCount += 1
        lastRequestedLimit = limit
        return measuresToReturn
    }
}
