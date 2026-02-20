//
//  MeasureRepository.swift
//  wsanjusto-ios
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation

/// Protocol for fetching measures, enabling dependency injection for testing
protocol MeasureRepository: Sendable {
    /// Fetches measures from the data source
    /// - Parameter limit: Maximum number of measures to fetch
    /// - Returns: Array of measures ordered by date
    func fetchMeasures(limit: Int) async -> [Measure]
}
