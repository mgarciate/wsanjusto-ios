//
//  FirebaseMeasureRepository.swift
//  wsanjusto-ios
//
//  Created by Claude Code on 19/02/2026.
//

import Foundation

#if canImport(FirebaseDatabase)
import FirebaseDatabase

/// Production implementation of MeasureRepository that fetches from Firebase
final class FirebaseMeasureRepository: MeasureRepository, @unchecked Sendable {
    
    func fetchMeasures(limit: Int) async -> [Measure] {
        await withCheckedContinuation { continuation in
            let ref = Database.database().reference()
            ref.child("measures")
                .queryOrdered(byChild: "orderByDate")
                .queryLimited(toFirst: UInt(limit))
                .observeSingleEvent(of: .value) { snapshot in
                    #if DEBUG
                    print("*** Children \(snapshot.childrenCount)")
                    #endif
                    let measures = snapshot.children.compactMap { child in
                        Measure.build(with: child as? DataSnapshot)
                    }
                    continuation.resume(returning: measures)
                }
        }
    }
}
#else
/// Stub implementation when Firebase is not available
final class FirebaseMeasureRepository: MeasureRepository, @unchecked Sendable {
    func fetchMeasures(limit: Int) async -> [Measure] {
        return []
    }
}
#endif
