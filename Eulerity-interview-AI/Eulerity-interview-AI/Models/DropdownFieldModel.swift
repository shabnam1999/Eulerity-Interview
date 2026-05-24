//
//  DropdownFieldModel.swift
//  Eulerity-interview-AI
//

import Foundation

struct DropdownOption: Codable, Equatable, Identifiable {
    let id: String
    let label: String
}

struct DropdownFieldModel: Codable, Equatable, Identifiable {
    let id: String
    let order: Int
    let label: String?
    let allowMultiple: Bool?
    let defaultValues: [String]?
    let required: Bool?
    let options: [DropdownOption]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case label
        case allowMultiple = "allow_multiple"
        case defaultValues = "default_values"
        case required
        case options
    }
}
