//
//  ThemeModel.swift
//  Eulerity-interview-AI
//

import SwiftUI

struct ThemeModel: Codable, Equatable {
    let backgroundColor: String?
    let textColor: String?
    let borderColor: String?
    let errorColor: String?
    
    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }
}

struct Theme: Equatable {
    let backgroundColor: Color
    let textColor: Color
    let borderColor: Color
    let errorColor: Color
    
    static let `default` = Theme(
        backgroundColor: Color(uiColor: .systemBackground),
        textColor: Color(uiColor: .label),
        borderColor: Color(uiColor: .separator),
        errorColor: Color(uiColor: .systemRed)
    )
    
    init(from model: ThemeModel?) {
        self.backgroundColor = model?.backgroundColor.flatMap { Color(hex: $0) } ?? Color(uiColor: .systemBackground)
        self.textColor = model?.textColor.flatMap { Color(hex: $0) } ?? Color(uiColor: .label)
        self.borderColor = model?.borderColor.flatMap { Color(hex: $0) } ?? Color(uiColor: .separator)
        self.errorColor = model?.errorColor.flatMap { Color(hex: $0) } ?? Color(uiColor: .systemRed)
    }
    
    init(backgroundColor: Color, textColor: Color, borderColor: Color, errorColor: Color) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.borderColor = borderColor
        self.errorColor = errorColor
    }
}
