//
//  Eulerity_interview_AITests.swift
//  Eulerity-interview-AITests
//

import XCTest
@testable import Eulerity_interview_AI

final class Eulerity_interview_AITests: XCTestCase {
    
    // MARK: - Helper to load JSON from Test Target Bundle
    private func loadJSONData(filename: String) throws -> Data {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw XCTSkip("Resource file '\(filename).json' not found in test bundle.")
        }
        return try Data(contentsOf: url)
    }
    
    // MARK: - 1. TEXT Parsing Tests
    func testTextParsing() throws {
        let json = """
        {
            "id": "name_field",
            "order": 1,
            "type": "TEXT",
            "subtype": "PLAIN",
            "label": "Name",
            "placeholder": "Enter name",
            "max_length": 15,
            "required": true,
            "regex": "^[A-Za-z]+$",
            "error_message": "Invalid name string"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let field = try decoder.decode(FormField.self, from: json)
        
        if case .text(let model) = field {
            XCTAssertEqual(model.id, "name_field")
            XCTAssertEqual(model.order, 1)
            XCTAssertEqual(model.subtype, .plain)
            XCTAssertEqual(model.label, "Name")
            XCTAssertEqual(model.placeholder, "Enter name")
            XCTAssertEqual(model.maxLength, 15)
            XCTAssertEqual(model.required, true)
            XCTAssertEqual(model.regex, "^[A-Za-z]+$")
            XCTAssertEqual(model.errorMessage, "Invalid name string")
        } else {
            XCTFail("Parsed field type mismatch: expected Text")
        }
    }
    
    // MARK: - 2. DROPDOWN Parsing Tests
    func testDropdownParsing() throws {
        let json = """
        {
            "id": "networks",
            "order": 2,
            "type": "DROPDOWN",
            "label": "Ad Networks",
            "allow_multiple": true,
            "default_values": ["net_meta"],
            "required": true,
            "options": [
                {"id": "net_google", "label": "Google Search"},
                {"id": "net_meta", "label": "Meta"}
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let field = try decoder.decode(FormField.self, from: json)
        
        if case .dropdown(let model) = field {
            XCTAssertEqual(model.id, "networks")
            XCTAssertEqual(model.order, 2)
            XCTAssertEqual(model.allowMultiple, true)
            XCTAssertEqual(model.defaultValues, ["net_meta"])
            XCTAssertEqual(model.required, true)
            XCTAssertNotNil(model.options)
            XCTAssertEqual(model.options?.count, 2)
            XCTAssertEqual(model.options?[0].id, "net_google")
            XCTAssertEqual(model.options?[1].label, "Meta")
        } else {
            XCTFail("Parsed field type mismatch: expected Dropdown")
        }
    }
    
    // MARK: - 3. CHECKBOX Parsing Tests
    func testCheckboxParsing() throws {
        let json = """
        {
            "id": "agree",
            "order": 5,
            "type": "CHECKBOX",
            "label": "I agree to Terms",
            "required": true,
            "metadata": {
                "Terms": "https://example.com/terms"
            },
            "clickable_text_color": "#2563EB"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let field = try decoder.decode(FormField.self, from: json)
        
        if case .checkbox(let model) = field {
            XCTAssertEqual(model.id, "agree")
            XCTAssertEqual(model.order, 5)
            XCTAssertEqual(model.label, "I agree to Terms")
            XCTAssertEqual(model.required, true)
            XCTAssertEqual(model.metadata?["Terms"], "https://example.com/terms")
            XCTAssertEqual(model.clickableTextColor, "#2563EB")
        } else {
            XCTFail("Parsed field type mismatch: expected Checkbox")
        }
    }
    
    // MARK: - 4. Unknown Types Defensive Parsing
    func testUnknownFieldTypeParsing() throws {
        // Unknown field type should throw error so SafeDecodableElement can capture it
        let json = """
        {
            "id": "custom_widget",
            "order": 3,
            "type": "CUSTOM_3D_VIEWER",
            "label": "My widget"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(FormField.self, from: json))
    }
    
    // MARK: - 5. Missing / Optional Properties Fallbacks
    func testMissingPropertiesFallbacks() throws {
        // Missing optional fields (subtype, label, error_message, required)
        let json = """
        {
            "id": "minimal_text",
            "order": 1,
            "type": "TEXT",
            "subtype": "PLAIN"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let field = try decoder.decode(FormField.self, from: json)
        
        if case .text(let model) = field {
            XCTAssertEqual(model.id, "minimal_text")
            XCTAssertEqual(model.order, 1)
            XCTAssertNil(model.label)
            XCTAssertNil(model.placeholder)
            XCTAssertNil(model.maxLength)
            XCTAssertNil(model.required)
            XCTAssertEqual(field.label, "") // FormField computed property empty string fallback
        } else {
            XCTFail("Expected Text field")
        }
    }
    
    // MARK: - 6. Invalid JSON Error Handling
    func testInvalidJSONThrows() {
        // Mismatched curly brace syntax
        let invalidJSON = "{ \"form_title\": \"Title\", \"fields\": [ ".data(using: .utf8)!
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(FormContainer.self, from: invalidJSON))
    }
    
    // MARK: - 7. Defensive Array Parsing (SafeDecodableElement)
    func testDefensiveFieldListDecoding() throws {
        let json = """
        {
            "form_title": "Mixed Form",
            "fields": [
                {
                    "id": "valid_text",
                    "order": 1,
                    "type": "TEXT",
                    "subtype": "PLAIN",
                    "label": "Valid Text"
                },
                {
                    "id": "invalid_unknown_type",
                    "order": 2,
                    "type": "UNKNOWN_RANDOM_COMPONENT",
                    "label": "Ignore Me"
                },
                {
                    "id": "valid_checkbox",
                    "order": 3,
                    "type": "CHECKBOX",
                    "label": "Valid Checkbox"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let container = try decoder.decode(FormContainer.self, from: json)
        
        // The invalid field must be ignored, parsing the other 2 fields successfully
        XCTAssertEqual(container.fields.count, 2)
        XCTAssertEqual(container.fields[0].id, "valid_text")
        XCTAssertEqual(container.fields[1].id, "valid_checkbox")
    }
    
    // MARK: - 8. ViewModel Logic and Character Limit Binding Enforcement
    func testViewModelCharacterLimitEnforcement() {
        let viewModel = FormViewModel()
        
        let textModel = TextFieldModel(
            id: "username",
            order: 1,
            subtype: .plain,
            label: "Username",
            placeholder: nil,
            supportingText: nil,
            maxLength: 5, // Strict limit of 5 characters
            errorMessage: nil,
            required: true,
            regex: nil
        )
        
        let container = FormContainer(theme: nil, formTitle: "Test", fields: [.text(textModel)])
        viewModel.container = container
        viewModel.formValues["username"] = .text("")
        
        let textBinding = viewModel.bindingForText(id: "username", maxLength: textModel.maxLength)
        
        // Edit text within the limit
        textBinding.wrappedValue = "ABC"
        XCTAssertEqual(viewModel.formValues["username"], .text("ABC"))
        
        // Exceed the limit: check that binding setter truncates the input string
        textBinding.wrappedValue = "ABCDEFGH"
        XCTAssertEqual(viewModel.formValues["username"], .text("ABCDE")) // Truncated to 5 chars
    }
    
    // MARK: - 9. Email and Regex Validations
    func testRegexValidationInViewModel() {
        let viewModel = FormViewModel()
        
        // Setup text field with email regex validation
        let emailModel = TextFieldModel(
            id: "email",
            order: 1,
            subtype: .plain,
            label: "Email",
            placeholder: nil,
            supportingText: nil,
            maxLength: nil,
            errorMessage: "Invalid Email Address",
            required: true,
            regex: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        )
        
        viewModel.container = FormContainer(theme: nil, formTitle: "Regex Test", fields: [.text(emailModel)])
        
        // 1. Empty and required -> Validation Fails
        viewModel.formValues["email"] = .text("")
        XCTAssertFalse(viewModel.validateForm())
        XCTAssertEqual(viewModel.validationErrors["email"], "Invalid Email Address")
        
        // 2. Mismatched format -> Validation Fails
        viewModel.formValues["email"] = .text("not-an-email")
        XCTAssertFalse(viewModel.validateForm())
        XCTAssertEqual(viewModel.validationErrors["email"], "Invalid Email Address")
        
        // 3. Proper format -> Validation Succeeds
        viewModel.formValues["email"] = .text("developer@google.com")
        XCTAssertTrue(viewModel.validateForm())
        XCTAssertNil(viewModel.validationErrors["email"])
    }
    
    // MARK: - 10. Required Field Validations (Dropdown, Toggle, Checkbox)
    func testRequiredFieldValidations() {
        let viewModel = FormViewModel()
        
        let dropdownModel = DropdownFieldModel(
            id: "dropdown",
            order: 1,
            label: "Option",
            allowMultiple: false,
            defaultValues: nil,
            required: true,
            options: [DropdownOption(id: "opt1", label: "Opt 1")]
        )
        
        let checkboxModel = CheckboxFieldModel(
            id: "checkbox",
            order: 2,
            label: "Accept",
            required: true,
            metadata: nil,
            clickableTextColor: nil
        )
        
        let fields: [FormField] = [.dropdown(dropdownModel), .checkbox(checkboxModel)]
        viewModel.container = FormContainer(theme: nil, formTitle: "Required Test", fields: fields)
        
        // Initial state: not completed -> validation fails
        viewModel.formValues["dropdown"] = .dropdownSingle(nil)
        viewModel.formValues["checkbox"] = .checkbox(false)
        
        XCTAssertFalse(viewModel.validateForm())
        XCTAssertNotNil(viewModel.validationErrors["dropdown"])
        XCTAssertNotNil(viewModel.validationErrors["checkbox"])
        
        // Complete single dropdown selection but not checkbox -> validation fails
        viewModel.formValues["dropdown"] = .dropdownSingle("opt1")
        XCTAssertFalse(viewModel.validateForm())
        XCTAssertNil(viewModel.validationErrors["dropdown"])
        XCTAssertNotNil(viewModel.validationErrors["checkbox"])
        
        // Complete checkbox selection -> validation succeeds
        viewModel.formValues["checkbox"] = .checkbox(true)
        XCTAssertTrue(viewModel.validateForm())
        XCTAssertNil(viewModel.validationErrors["dropdown"])
        XCTAssertNil(viewModel.validationErrors["checkbox"])
    }
}
