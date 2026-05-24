//
//  RichTextLabel.swift
//  Eulerity-interview-AI
//

import SwiftUI

struct RichTextLabel: View {
    let labelText: String
    let metadata: [String: String]?
    let clickableColor: Color
    let defaultTextColor: Color
    var onTextTap: (() -> Void)? = nil
    
    var body: some View {
        Text(attributedText)
            .font(.body)
            .foregroundColor(defaultTextColor)
            .environment(\.openURL, OpenURLAction { url in
                // Standard Link open behaviour (opens in Safari)
                UIApplication.shared.open(url)
                return .handled
            })
    }
    
    private var attributedText: AttributedString {
        var attrString = AttributedString(labelText)
        
        guard let metadata = metadata else {
            return attrString
        }
        
        for (key, urlString) in metadata {
            if let range = attrString.range(of: key) {
                if let url = URL(string: urlString) {
                    attrString[range].link = url
                    attrString[range].foregroundColor = clickableColor
                    attrString[range].underlineStyle = .single
                }
            }
        }
        
        return attrString
    }
}
