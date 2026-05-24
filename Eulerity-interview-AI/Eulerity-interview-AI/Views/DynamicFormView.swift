//
//  DynamicFormView.swift
//  Eulerity-interview-AI
//

import SwiftUI

struct DynamicFormView: View {
    @ObservedObject var viewModel: FormViewModel
    @FocusState private var focusedField: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(viewModel.formTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.theme.textColor)
                    .padding(.bottom, 8)
                
                // Form Fields
                ForEach(viewModel.fields) { field in
                    renderField(field)
                }
                
                // Submit Button
                Button(action: {
                    focusedField = nil
                    viewModel.saveForm()
                }) {
                    Text("Save Campaign")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 16)
            }
            .padding(20)
            .background(viewModel.theme.backgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .alert(isPresented: $viewModel.showConfirmation) {
            Alert(
                title: Text("Submission Success"),
                message: Text(viewModel.confirmationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Previous") {
                    moveFocus(forward: false)
                }
                .disabled(!hasPreviousField())
                
                Button("Next") {
                    moveFocus(forward: true)
                }
                .disabled(!hasNextField())
                
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderField(_ field: FormField) -> some View {
        let error = viewModel.validationErrors[field.id]
        
        switch field {
        case .text(let model):
            TextView(
                model: model,
                text: viewModel.bindingForText(id: model.id, maxLength: model.maxLength),
                errorMessage: error,
                theme: viewModel.theme,
                focusId: model.id
            )
            .focused($focusedField, equals: model.id)
            
        case .dropdown(let model):
            DropdownView(
                model: model,
                formValues: viewModel.formValues,
                errorMessage: error,
                theme: viewModel.theme,
                onToggle: { optionId in
                    viewModel.toggleDropdownSelection(
                        id: model.id,
                        optionId: optionId,
                        allowMultiple: model.allowMultiple ?? false
                    )
                }
            )
            
        case .toggle(let model):
            ToggleView(
                model: model,
                isOn: viewModel.bindingForToggle(id: model.id),
                errorMessage: error,
                theme: viewModel.theme
            )
            
        case .checkbox(let model):
            CheckboxView(
                model: model,
                isChecked: viewModel.bindingForCheckbox(id: model.id),
                errorMessage: error,
                theme: viewModel.theme
            )
        }
    }
    
    // MARK: - Focus Management
    
    private func moveFocus(forward: Bool) {
        guard let current = focusedField,
              let index = viewModel.textFieldsOrdered.firstIndex(of: current) else { return }
        
        let targetIndex = forward ? index + 1 : index - 1
        if targetIndex >= 0 && targetIndex < viewModel.textFieldsOrdered.count {
            focusedField = viewModel.textFieldsOrdered[targetIndex]
        }
    }
    
    private func hasNextField() -> Bool {
        guard let current = focusedField,
              let index = viewModel.textFieldsOrdered.firstIndex(of: current) else { return false }
        return index + 1 < viewModel.textFieldsOrdered.count
    }
    
    private func hasPreviousField() -> Bool {
        guard let current = focusedField,
              let index = viewModel.textFieldsOrdered.firstIndex(of: current) else { return false }
        return index - 1 >= 0
    }
}
