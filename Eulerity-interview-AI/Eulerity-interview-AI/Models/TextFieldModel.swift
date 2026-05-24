//
//  TextFieldModel.swift
//  Eulerity-interview-AI
//

import Foundation

enum TextSubtype: String, Codable, CaseIterable {
    case plain = "PLAIN"
    case multiline = "MULTILINE"
    case number = "NUMBER"
    case uri = "URI"
    case secure = "SECURE"
}

struct TextFieldModel: Codable, Equatable, Identifiable {
    let id: String
    let order: Int
    let subtype: TextSubtype
    let label: String?
    let placeholder: String?
    let supportingText: String?
    let maxLength: Int?
    let errorMessage: String?
    let required: Bool?
    let regex: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case subtype
        case label
        case placeholder
        case supportingText = "supporting_text"
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case required
        case regex
    }
}
