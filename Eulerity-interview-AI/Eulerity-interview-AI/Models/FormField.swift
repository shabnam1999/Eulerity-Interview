//
//  FormField.swift
//  Eulerity-interview-AI
//

import Foundation

enum FormField: Decodable, Identifiable, Equatable {
    case text(TextFieldModel)
    case dropdown(DropdownFieldModel)
    case toggle(ToggleFieldModel)
    case checkbox(CheckboxFieldModel)
    
    var id: String {
        switch self {
        case .text(let model): return model.id
        case .dropdown(let model): return model.id
        case .toggle(let model): return model.id
        case .checkbox(let model): return model.id
        }
    }
    
    var order: Int {
        switch self {
        case .text(let model): return model.order
        case .dropdown(let model): return model.order
        case .toggle(let model): return model.order
        case .checkbox(let model): return model.order
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .text(let model): return model.required ?? false
        case .dropdown(let model): return model.required ?? false
        case .toggle(let model): return model.required ?? false
        case .checkbox(let model): return model.required ?? false
        }
    }
    
    var label: String {
        switch self {
        case .text(let model): return model.label ?? ""
        case .dropdown(let model): return model.label ?? ""
        case .toggle(let model): return model.label ?? ""
        case .checkbox(let model): return model.label ?? ""
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let typeStr = try container.decodeIfPresent(String.self, forKey: .type) else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Field type is missing."
            )
        }
        
        switch typeStr {
        case "TEXT":
            let model = try TextFieldModel(from: decoder)
            self = .text(model)
        case "DROPDOWN":
            let model = try DropdownFieldModel(from: decoder)
            self = .dropdown(model)
        case "TOGGLE":
            let model = try ToggleFieldModel(from: decoder)
            self = .toggle(model)
        case "CHECKBOX":
            let model = try CheckboxFieldModel(from: decoder)
            self = .checkbox(model)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported field type: \(typeStr)"
            )
        }
    }
}
