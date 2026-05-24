//
//  JSONLoader.swift
//  Eulerity-interview-AI
//

import Foundation

enum JSONLoaderError: LocalizedError {
    case fileNotFound(String)
    case dataLoadingFailed(URL, Error)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "JSON file '\(name)' could not be found in the main app bundle."
        case .dataLoadingFailed(let url, let error):
            return "Failed to load data from URL '\(url.path)': \(error.localizedDescription)"
        case .decodingFailed(let error):
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    return "Type mismatch for type \(type) in context: \(context.debugDescription) at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .valueNotFound(let type, let context):
                    return "Value not found for type \(type) in context: \(context.debugDescription) at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .keyNotFound(let key, let context):
                    return "Key '\(key.stringValue)' not found in context: \(context.debugDescription) at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .dataCorrupted(let context):
                    return "Data corrupted in context: \(context.debugDescription) at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                @unknown default:
                    return "Decoding error: \(error.localizedDescription)"
                }
            }
            return "Failed to parse JSON schema: \(error.localizedDescription)"
        }
    }
}

struct JSONLoader {
    static func loadSchema(filename: String) throws -> FormContainer {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw JSONLoaderError.fileNotFound(filename)
        }
        
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw JSONLoaderError.dataLoadingFailed(url, error)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(FormContainer.self, from: data)
        } catch {
            throw JSONLoaderError.decodingFailed(error)
        }
    }
}
