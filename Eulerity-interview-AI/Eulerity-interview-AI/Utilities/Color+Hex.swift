//
//  Color+Hex.swift
//  Eulerity-interview-AI
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension Color {
    init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&rgbValue) else {
            return nil
        }
        
        let r, g, b, a: Double
        switch cleanHex.count {
        case 3: // RGB Shorthand (e.g. "FFF")
            r = Double((rgbValue & 0xF00) >> 8) / 15.0
            g = Double((rgbValue & 0x0F0) >> 4) / 15.0
            b = Double(rgbValue & 0x00F) / 15.0
            a = 1.0
        case 6: // RGB Standard (e.g. "FFFFFF")
            r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            b = Double(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RGBA (e.g. "FFFFFFFF")
            r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = Double(rgbValue & 0x000000FF) / 255.0
        default:
            return nil
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
