//
//  FormFieldViews.swift
//  Eulerity-interview-AI
//

import SwiftUI

// MARK: - Text Component View
struct TextView: View {
    let model: TextFieldModel
    @Binding var text: String
    let errorMessage: String?
    let theme: Theme
    var focusId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label
            HStack {
                Text(model.label ?? "")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textColor)
                if model.required == true {
                    Text("*")
                        .foregroundColor(theme.errorColor)
                }
            }
            
            // Input Field container
            Group {
                switch model.subtype {
                case .multiline:
                    TextEditor(text: $text)
                        .frame(minHeight: 80, maxHeight: 120)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(8)
                case .secure:
                    SecureField(model.placeholder ?? "", text: $text)
                        .padding(10)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(8)
                case .number:
                    TextField(model.placeholder ?? "", text: $text)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(8)
                case .uri:
                    TextField(model.placeholder ?? "", text: $text)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(10)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(8)
                case .plain:
                    TextField(model.placeholder ?? "", text: $text)
                        .padding(10)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(8)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(errorMessage != nil ? theme.errorColor : theme.borderColor, lineWidth: 1)
            )
            
            // Bottom Info (Supporting text, character count, and error messages)
            HStack(alignment: .top) {
                if let err = errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(theme.errorColor)
                } else if let support = model.supportingText {
                    Text(support)
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
                
                Spacer()
                
                // Character limit counter
                if let maxLen = model.maxLength, maxLen > 0 {
                    Text("\(text.count)/\(maxLen)")
                        .font(.caption)
                        .foregroundColor(text.count >= maxLen ? theme.errorColor : theme.textColor.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - Dropdown Component View
struct DropdownView: View {
    let model: DropdownFieldModel
    let formValues: [String: FormValue]
    let errorMessage: String?
    let theme: Theme
    let onToggle: (String) -> Void
    
    @State private var isMenuExpanded = false
    
    private var isEnabled: Bool {
        model.options != nil && !(model.options?.isEmpty ?? true)
    }
    
    private var currentSelectionString: String {
        guard isEnabled else { return "No options available" }
        let val = formValues[model.id]
        
        switch val {
        case .dropdownSingle(let selectedId):
            if let selectedId = selectedId,
               let option = model.options?.first(where: { $0.id == selectedId }) {
                return option.label
            }
            return "Select option"
        case .dropdownMultiple(let selectedSet):
            if selectedSet.isEmpty {
                return "Select options"
            }
            let labels = selectedSet.compactMap { selId in
                model.options?.first(where: { $0.id == selId })?.label
            }
            return labels.joined(separator: ", ")
        default:
            return "Select option"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(model.label ?? "")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textColor)
                if model.required == true {
                    Text("*")
                        .foregroundColor(theme.errorColor)
                }
            }
            
            // Trigger Button
            Button(action: {
                if isEnabled {
                    isMenuExpanded.toggle()
                }
            }) {
                HStack {
                    Text(currentSelectionString)
                        .font(.body)
                        .foregroundColor(isEnabled ? theme.textColor : theme.textColor.opacity(0.4))
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundColor(theme.textColor.opacity(0.6))
                        .rotationEffect(.degrees(isMenuExpanded ? 180 : 0))
                }
                .padding(10)
                .background(Color(uiColor: isEnabled ? .secondarySystemGroupedBackground : .systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(errorMessage != nil ? theme.errorColor : theme.borderColor, lineWidth: 1)
                )
            }
            .disabled(!isEnabled)
            
            // Expandable Multi/Single Selection Menu
            if isMenuExpanded && isEnabled, let options = model.options {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options) { option in
                        Button(action: {
                            onToggle(option.id)
                            if model.allowMultiple != true {
                                isMenuExpanded = false
                            }
                        }) {
                            HStack {
                                Text(option.label)
                                    .font(.body)
                                    .foregroundColor(theme.textColor)
                                Spacer()
                                if isSelected(option.id) {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                        }
                        
                        if option.id != options.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            if let err = errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(theme.errorColor)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isMenuExpanded)
    }
    
    private func isSelected(_ optionId: String) -> Bool {
        let val = formValues[model.id]
        switch val {
        case .dropdownSingle(let selectedId):
            return selectedId == optionId
        case .dropdownMultiple(let selectedSet):
            return selectedSet.contains(optionId)
        default:
            return false
        }
    }
}

// MARK: - Toggle Component View
struct ToggleView: View {
    let model: ToggleFieldModel
    @Binding var isOn: Bool
    let errorMessage: String?
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $isOn) {
                HStack {
                    Text(model.label ?? "")
                        .font(.body)
                        .foregroundColor(theme.textColor)
                    if model.required == true {
                        Text("*")
                            .foregroundColor(theme.errorColor)
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            .padding(.vertical, 4)
            
            if let err = errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(theme.errorColor)
            }
        }
    }
}

// MARK: - Checkbox Component View
struct CheckboxView: View {
    let model: CheckboxFieldModel
    @Binding var isChecked: Bool
    let errorMessage: String?
    let theme: Theme
    
    private var clickableColor: Color {
        if let hexStr = model.clickableTextColor, let col = Color(hex: hexStr) {
            return col
        }
        return theme.textColor // fallback to theme color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Button(action: {
                    isChecked.toggle()
                }) {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(isChecked ? .accentColor : theme.textColor.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                
                RichTextLabel(
                    labelText: model.label ?? "",
                    metadata: model.metadata,
                    clickableColor: clickableColor,
                    defaultTextColor: theme.textColor
                )
                .onTapGesture {
                    isChecked.toggle()
                }
                
                if model.required == true {
                    Text("*")
                        .foregroundColor(theme.errorColor)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            if let err = errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(theme.errorColor)
            }
        }
    }
}
