# Server-Driven UI (SDUI) iOS Application

A premium, server-driven form rendering application built in Swift and SwiftUI for iOS 16+. The app consumes JSON schemas dynamically, maps components into a structured form layout, applies custom theme properties, manages state reactively using MVVM, and performs real-time validation.

---

## 1. Folder Structure

The application codebase is organized into modular layers adhering to the **MVVM (Model-View-ViewModel)** architectural pattern:

```
Eulerity-interview-AI/
├── Eulerity-interview-AI.xcodeproj/  # Xcode Project configuration
├── Eulerity-interview-AI/            # App Source Files
│   ├── Models/
│   │   ├── ThemeModel.swift           # Color schema configuration and Theme builder
│   │   ├── FormField.swift            # Polymorphic FormField representation
│   │   ├── TextFieldModel.swift       # Sub-model for text input fields
│   │   ├── DropdownFieldModel.swift   # Sub-model for dropdown pickers (single/multi)
│   │   ├── ToggleFieldModel.swift     # Sub-model for toggles
│   │   ├── CheckboxFieldModel.swift   # Sub-model for checkboxes
│   │   └── FormContainer.swift        # Root schema container and defensive decoding wrapper
│   ├── Utilities/
│   │   ├── Color+Hex.swift            # Decodes hex color strings into SwiftUI Colors
│   │   └── JSONLoader.swift           # Reads and parses JSON schemas from the App Bundle
│   ├── ViewModels/
│   │   └── FormViewModel.swift        # Stores field state values, triggers validation, and coordinates saves
│   ├── Views/
│   │   ├── RichTextLabel.swift        # Checkbox label that supports clickable AttributedString links
│   │   ├── FormFieldViews.swift       # Specific subviews (TextView, DropdownView, ToggleView, CheckboxView)
│   │   └── DynamicFormView.swift      # Form orchestrator with FocusState transitions and toolbar
│   ├── Resources/
│   │   ├── schema_campaign.json       # Valid campaign JSON schema
│   │   ├── schema_defensive.json      # Schema showcasing defensive fallback boundaries
│   │   └── schema_corrupt.json        # Syntax-corrupted schema to test error boundary views
│   ├── ContentView.swift              # Main app container featuring a schema selector switcher and JSON viewer
│   ├── Eulerity_interview_AIApp.swift # Application entrypoint
│   └── Assets.xcassets/               # Standard app assets
├── Eulerity-interview-AITests/        # Unit Testing Target
│   └── Eulerity_interview_AITests.swift # 10 coverage cases for parsing, limits, regex, and VM states
├── configure_xcode_project.rb          # Ruby script to automate target configurations
└── README.md                          # Project documentation
```

---

## 2. Product Decisions & Edge Cases

To ensure a robust, production-grade application, the following system design decisions were implemented:

*   **Defensive Array Decoding (`SafeDecodableElement`)**: If a field within the schema array contains an unknown component type, a missing mandatory identifier, or syntax errors, the app isolates that element. It fails to parse that specific index, printing a log, but continues to decode the rest of the form successfully. The entire form does not crash or fail to load.
*   **Text Max Length Enforcement**: Instead of validating length after input, the ViewModel binding intercepts keyboard typing. If the input exceeds `max_length`, it is truncated before updating the state dictionary, preventing the user from entering invalid lengths.
*   **Sensible Bounds Fallbacks**: If `max_length` is provided as negative or zero, it is ignored (meaning no limit is applied), preventing runtime crashes.
*   **Disabled Dropdowns on Missing Options**: If a `DROPDOWN` field is missing options on disk, it enters a disabled state displaying "No options available", styled with a dimmed theme border and label to prevent illegal nil selection states.
*   **Required Toggles and Checkboxes**: When marked as `required: true`, toggles and checkboxes require the user to check them (`true`) to satisfy validation, ensuring consent agreements are respected.
*   **Dynamic Focus Handling**: Auto-focus navigation skips non-textual components (checkboxes, dropdowns, toggles) to prevent keyboard flickering. The keyboard toolbar dynamically enables/disables "Previous" and "Next" buttons based on the user's current cursor index in the text fields.

---

## 3. Suggested Demo Flow

When launching the application on a simulator or device, use the following verification workflow:

1.  **Campaign Setup Schema**:
    *   Observe the form rendering campaign name, ad networks, daily budget, and checkbox with custom link styling.
    *   Tap the "Terms of Service" blue link inside the checkbox. Observe that Safari opens the terms page immediately.
    *   Try entering text into the Campaign Name field; typing will block exactly at 30 characters.
    *   Click "Save Campaign" with missing fields. Note the inline error indicators. Complete all fields and tap save to view the success alert listing all key-value states in your console.
2.  **Defensive Testing Schema**:
    *   Observe that the unknown component type was ignored safely without crashing the screen.
    *   Check that "Text with negative max length" works normally without applying any character limit.
    *   Look at the "Disabled Dropdown" - it is greyed out and cannot be tapped.
    *   View "Checkbox missing label" - it renders a blank label space cleanly.
    *   Test "Email Address" field - enter `not-an-email` and note that regex validation catches it inline. Enter a valid address like `developer@google.com` to see the error clear immediately.
3.  **Corrupt JSON Schema**:
    *   Observe the app display a clean warning screen saying "Corrupt Schema Detected", accompanied by the exact syntax parsing error context, illustrating our boundary safety.

---

## 4. Verification and Testing

### Executing Unit Tests
To run the automated XCTest suite from the command line, boot an iOS Simulator (e.g., iPhone 16 Pro) and run:

```bash
xcodebuild test \
  -project Eulerity-interview-AI.xcodeproj \
  -scheme Eulerity-interview-AI \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO
```

### Compiling and Running the App
To build the application for simulator execution:

```bash
xcodebuild build \
  -project Eulerity-interview-AI.xcodeproj \
  -scheme Eulerity-interview-AI \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO
```
Alternatively, open `Eulerity-interview-AI.xcodeproj` in Xcode, select a simulator target, and press `Cmd + R` to run or `Cmd + U` to run tests.
