//
//  FormContainer.swift
//  Eulerity-interview-AI
//

import Foundation

struct SafeDecodableElement: Decodable {
    let field: FormField?
    
    init(from decoder: Decoder) throws {
        do {
            self.field = try FormField(from: decoder)
        } catch {
            // Log error and assign nil to ignore this field element
            print("Defensive parsing: Ignored field due to error: \(error.localizedDescription)")
            self.field = nil
        }
    }
}

struct FormContainer: Decodable, Equatable {
    let theme: ThemeModel?
    let formTitle: String
    let fields: [FormField]
    
    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
    
    init(theme: ThemeModel?, formTitle: String, fields: [FormField]) {
        self.theme = theme
        self.formTitle = formTitle
        self.fields = fields
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.theme = try container.decodeIfPresent(ThemeModel.self, forKey: .theme)
        self.formTitle = try container.decodeIfPresent(String.self, forKey: .formTitle) ?? ""
        
        // Decode fields dynamically and skip invalid/unknown types
        let rawElements = try container.decodeIfPresent([SafeDecodableElement].self, forKey: .fields) ?? []
        self.fields = rawElements.compactMap { $0.field }
    }
}
