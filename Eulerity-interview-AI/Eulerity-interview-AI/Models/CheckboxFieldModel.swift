//
//  CheckboxFieldModel.swift
//  Eulerity-interview-AI
//

import Foundation

struct CheckboxFieldModel: Codable, Equatable, Identifiable {
    let id: String
    let order: Int
    let label: String?
    let required: Bool?
    let metadata: [String: String]?
    let clickableTextColor: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case label
        case required
        case metadata
        case clickableTextColor = "clickable_text_color"
    }
}
