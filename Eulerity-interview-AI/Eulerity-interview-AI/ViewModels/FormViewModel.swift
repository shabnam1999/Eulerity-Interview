//
//  FormViewModel.swift
//  Eulerity-interview-AI
//

import SwiftUI
import Combine

enum FormValue: Equatable {
    case text(String)
    case dropdownSingle(String?)
    case dropdownMultiple(Set<String>)
    case toggle(Bool)
    case checkbox(Bool)
    
    var rawValue: Any {
        switch self {
        case .text(let val): return val
        case .dropdownSingle(let val): return val as Any
        case .dropdownMultiple(let val): return Array(val)
        case .toggle(let val): return val
        case .checkbox(let val): return val
        }
    }
}

class FormViewModel: ObservableObject {
    @Published var container: FormContainer? = nil
    @Published var formValues: [String: FormValue] = [:]
    @Published var validationErrors: [String: String] = [:]
    @Published var schemaLoadError: String? = nil
    
    // Alert state
    @Published var showConfirmation: Bool = false
    @Published var confirmationMessage: String = ""
    
    var fields: [FormField] {
        container?.fields.sorted(by: { $0.order < $1.order }) ?? []
    }
    
    var theme: Theme {
        Theme(from: container?.theme)
    }
    
    var formTitle: String {
        container?.formTitle ?? "Form"
    }
    
    // Filtered text field IDs in layout order for focus movement
    var textFieldsOrdered: [String] {
        fields.compactMap { field -> String? in
            if case .text = field {
                return field.id
            }
            return nil
        }
    }
    
    func loadSchema(filename: String) {
        do {
            let loaded = try JSONLoader.loadSchema(filename: filename)
            self.container = loaded
            self.schemaLoadError = nil
            self.validationErrors.removeAll()
            
            // Populate values defensively, preserving existing keys where appropriate
            var newValues: [String: FormValue] = [:]
            for field in loaded.fields {
                let id = field.id
                
                switch field {
                case .text(let model):
                    newValues[id] = .text("")
                    
                case .dropdown(let model):
                    let defaults = model.defaultValues ?? []
                    if model.allowMultiple == true {
                        newValues[id] = .dropdownMultiple(Set(defaults))
                    } else {
                        newValues[id] = .dropdownSingle(defaults.first)
                    }
                    
                case .toggle(let model):
                    newValues[id] = .toggle(model.defaultValue ?? false)
                    
                case .checkbox:
                    newValues[id] = .checkbox(false)
                }
            }
            self.formValues = newValues
        } catch {
            self.container = nil
            self.schemaLoadError = error.localizedDescription
            self.formValues.removeAll()
            self.validationErrors.removeAll()
        }
    }
    
    // MARK: - Dynamic State Bindings
    
    func bindingForText(id: String, maxLength: Int?) -> Binding<String> {
        Binding(
            get: {
                if case .text(let val) = self.formValues[id] {
                    return val
                }
                return ""
            },
            set: { newValue in
                // Enforce max length safely (fallback if negative/invalid)
                let limit = maxLength ?? -1
                let updated: String
                if limit > 0 {
                    updated = String(newValue.prefix(limit))
                } else {
                    updated = newValue
                }
                
                self.formValues[id] = .text(updated)
                self.validationErrors[id] = nil
            }
        )
    }
    
    func bindingForToggle(id: String) -> Binding<Bool> {
        Binding(
            get: {
                if case .toggle(let val) = self.formValues[id] {
                    return val
                }
                return false
            },
            set: { newValue in
                self.formValues[id] = .toggle(newValue)
                self.validationErrors[id] = nil
            }
        )
    }
    
    func bindingForCheckbox(id: String) -> Binding<Bool> {
        Binding(
            get: {
                if case .checkbox(let val) = self.formValues[id] {
                    return val
                }
                return false
            },
            set: { newValue in
                self.formValues[id] = .checkbox(newValue)
                self.validationErrors[id] = nil
            }
        )
    }
    
    func toggleDropdownSelection(id: String, optionId: String, allowMultiple: Bool) {
        if allowMultiple {
            if case .dropdownMultiple(var selection) = formValues[id] {
                if selection.contains(optionId) {
                    selection.remove(optionId)
                } else {
                    selection.insert(optionId)
                }
                formValues[id] = .dropdownMultiple(selection)
            } else {
                formValues[id] = .dropdownMultiple([optionId])
            }
        } else {
            formValues[id] = .dropdownSingle(optionId)
        }
        validationErrors[id] = nil
    }
    
    // MARK: - Validation
    
    func validateForm() -> Bool {
        var errors: [String: String] = [:]
        
        for field in fields {
            let id = field.id
            let isRequired = field.isRequired
            let val = formValues[id]
            
            switch field {
            case .text(let model):
                let textStr: String
                if case .text(let v) = val {
                    textStr = v.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    textStr = ""
                }
                
                if isRequired && textStr.isEmpty {
                    errors[id] = model.errorMessage ?? "This field is required."
                } else if !textStr.isEmpty, let regexPattern = model.regex {
                    do {
                        let regex = try NSRegularExpression(pattern: regexPattern)
                        let range = NSRange(location: 0, length: textStr.utf16.count)
                        let match = regex.firstMatch(in: textStr, options: [], range: range)
                        if match == nil {
                            errors[id] = model.errorMessage ?? "Invalid input format."
                        }
                    } catch {
                        // Fall back gracefully in case of invalid regex patterns
                        print("Validation regex error for field \(id): \(error.localizedDescription)")
                    }
                }
                
            case .dropdown(let model):
                if isRequired {
                    switch val {
                    case .dropdownSingle(let selectedId):
                        if selectedId == nil || selectedId?.isEmpty == true {
                            errors[id] = "Selection is required."
                        }
                    case .dropdownMultiple(let selectedSet):
                        if selectedSet.isEmpty {
                            errors[id] = "At least one selection is required."
                        }
                    default:
                        errors[id] = "Selection is required."
                    }
                }
                
            case .toggle:
                if isRequired {
                    if case .toggle(let isTrue) = val, !isTrue {
                        errors[id] = "Must be enabled."
                    }
                }
                
            case .checkbox:
                if isRequired {
                    if case .checkbox(let isTrue) = val, !isTrue {
                        errors[id] = "You must agree to continue."
                    }
                }
            }
        }
        
        self.validationErrors = errors
        return errors.isEmpty
    }
    
    func saveForm() {
        if validateForm() {
            // Print key-value pairs
            print("--- Submitting Form: \(formTitle) ---")
            var exported: [String: Any] = [:]
            for (key, val) in formValues {
                exported[key] = val.rawValue
                print("\(key): \(val.rawValue)")
            }
            print("---------------------------------------")
            
            // Format confirmation message
            let formattedValues = exported.map { "\($0.key): \($0.value)" }
                .sorted()
                .joined(separator: "\n")
            
            self.confirmationMessage = "Form values submitted successfully:\n\n\(formattedValues)"
            self.showConfirmation = true
        }
    }
}
