//
//  ToggleFieldModel.swift
//  Eulerity-interview-AI
//

import Foundation

struct ToggleFieldModel: Codable, Equatable, Identifiable {
    let id: String
    let order: Int
    let label: String?
    let required: Bool?
    let defaultValue: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case label
        case required
        case defaultValue = "default_value"
    }
}
