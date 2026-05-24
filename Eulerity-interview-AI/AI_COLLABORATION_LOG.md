AI Prompt

Task: Build a Server-Driven UI (SDUI) iOS application using SwiftUI.
Platform:
- Swift + SwiftUI
- iOS 16+
- Offline only
- Load JSON from App Bundle
- No network calls

Architecture:=
- MVVM
- Separate layers:
  - Models
  - Parsing/Decoding
  - ViewModel
  - Dynamic Component Renderer
  - Validation Layer
  - Utilities

Parsing:
- Use Codable
- Support polymorphic JSON decoding
- Parse components using type field
- Defensive decoding:
  - Unknown component types should not crash
  - Ignore unsupported types safely
  - Missing arrays/optional properties handled gracefully

Theme:
Parse and apply:
- background_color
- text_color
- border_color
- error_color

Component Requirements:
TEXT:
Subtypes:
- PLAIN → TextField
- MULTILINE → TextEditor
- NUMBER → numeric keyboard
- URI → URL keyboard
- SECURE → SecureField

TEXT rules:
- Optional placeholder
- Optional supporting text
- Optional max_length
- Character counter
- Prevent typing beyond max length

DROPDOWN:
- Store id internally
- Display label
- Single select
- Multi-select when allow_multiple=true
- Default values support

TOGGLE:
- Standard Toggle
CHECKBOX:
- Standard checkbox with label
Ordering:
- Sort fields by order property
- Never rely on array indexes
State Management:
- Observable ViewModel
- Dynamic state dictionary:
  [String: Any]
- Preserve selected values
- Support multiple field types safely

Validation:
On Save:
- Validate required fields
- Show field-level error states
- Show clear validation messages
- If valid:
  - Print final key-value pairs
  - Show confirmation alert
Defensive Rules:
- Unknown type → ignore
- Missing options → disable dropdown
- Invalid constraints → fallback safely
- Invalid max_length → use sensible defaults
- Missing labels → fallback to empty string
- Corrupt JSON → show graceful error state

Enhancements:
1. Rich Text Links in Checkbox:
- Parse metadata object
- Keys inside metadata map to text fragments
- Convert matching label text to clickable AttributedString
- Open URLs in Safari
- Use clickable_text_color if available
- Fallback to theme color

2. Regex Validation:
- Support optional regex field in TEXT
- Validate client-side
  Examples:
- URL validation
- Email validation
- Custom patterns
- Show inline validation errors

3. Dynamic Focus Management:
- Use @FocusState
- Keyboard toolbar:
  - Next
  - Done
- Move focus automatically through dynamic text fields
- Skip non-text components

4. Unit Tests:
   Add XCTest coverage for:
- TEXT parsing
- DROPDOWN parsing
- CHECKBOX parsing
- Unknown types
- Missing properties
- Invalid JSON
- Defensive parsing behavior

Output:
1. Folder structure
2. Model definitions
3. Polymorphic decoder
4. ViewModel
5. Dynamic renderer
6. Validation implementation
7. Rich text implementation
8. Focus handling
9. Unit tests
10. README structure
11. Suggested demo flow
12. Product decisions and edge cases


sample json -

{
  "theme": {
    "background_color": "#FFFFFF",
    "text_color": "#111827",
    "border_color": "#D1D5DB",
    "error_color": "#B91C1C"
  },
  "form_title": "Campaign Setup",
  "fields": [
    {
      "id": "campaign_name",
      "order": 1,
      "type": "TEXT",
      "subtype": "PLAIN",
      "label": "Campaign Name",
      "placeholder": "e.g., Summer Sale",
      "max_length": 30,
      "error_message": "Name is required.",
      "required": true
    },
    {
      "id": "ad_networks",
      "order": 2,
      "type": "DROPDOWN",
      "label": "Ad Networks",
      "allow_multiple": true,
      "default_values": ["net_meta"],
      "required": true,
      "options": [
        {
          "id": "net_google",
          "label": "Google Search"
        },
        {
          "id": "net_meta",
          "label": "Meta Platforms"
        }
      ]
    },
    {
      "id": "daily_budget",
      "order": 3,
      "type": "TEXT",
      "subtype": "NUMBER",
      "label": "Daily Budget ($)",
      "required": true
    },
    {
      "id": "accept_legal",
      "order": 4,
      "type": "CHECKBOX",
      "label": "I agree to the Terms of Service.",
      "required": true,
      "metadata": {
        "Terms of Service": "https://example.com/terms"
      },
      "clickable_text_color": "#2563EB"
    }
  ]
}

