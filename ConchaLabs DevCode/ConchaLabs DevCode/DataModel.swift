//
//  DataModel.swift
//  ConchaLabs DevCode
//
//  Created by Dan Muana on 1/25/22.
//

import Foundation

// MARK: - Ticks
struct Ticks: Codable {
    let ticks: [Double]
    let sessionID: Int64
    let stepCount: Int

    enum CodingKeys: String, CodingKey {
        case ticks
        case sessionID = "session_id"
        case stepCount = "step_count"
    }
}

// MARK: - Completed
struct Completed: Codable {
    let sessionID: Int64
    let complete: String

    enum CodingKeys: String, CodingKey {
        case complete
        case sessionID = "session_id"
    }
}
