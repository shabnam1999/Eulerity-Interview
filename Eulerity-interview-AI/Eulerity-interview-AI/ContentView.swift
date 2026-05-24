//
//  ContentView.swift
//  Eulerity-interview-AI
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FormViewModel()
    @State private var selectedSchema = "schema_campaign"
    @State private var isShowingJSONInspector = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Schema Selection Header
                VStack(spacing: 12) {
                    Picker("Select Schema", selection: $selectedSchema) {
                        Text("Campaign").tag("schema_campaign")
                        Text("Defensive").tag("schema_defensive")
                        Text("Corrupt").tag("schema_corrupt")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedSchema) { newValue in
                        viewModel.loadSchema(filename: newValue)
                    }
                    
                    HStack {
                        Button(action: {
                            isShowingJSONInspector = true
                        }) {
                            Label("View Schema JSON", systemImage: "doc.text.magnifyingglass")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.secondary)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                
                // Form rendering / Error state area
                Group {
                    if let errorMsg = viewModel.schemaLoadError {
                        // Graceful Error State
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.red)
                                .padding(.top, 40)
                            
                            Text("Corrupt Schema Detected")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(errorMsg)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(uiColor: .systemGroupedBackground))
                    } else if viewModel.container != nil {
                        // Dynamic Form
                        DynamicFormView(viewModel: viewModel)
                    } else {
                        // Loading/Empty
                        ProgressView("Loading schema...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle("Server-Driven UI")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadSchema(filename: selectedSchema)
            }
            .sheet(isPresented: $isShowingJSONInspector) {
                JSONInspectorView(filename: selectedSchema)
            }
        }
    }
}

// MARK: - JSON Inspector Sheet
struct JSONInspectorView: View {
    let filename: String
    @Environment(\.dismiss) var dismiss
    
    @State private var jsonText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(jsonText)
                        .font(.system(.footnote, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .navigationTitle("\(filename).json")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
                   let data = try? Data(contentsOf: url),
                   let rawString = String(data: data, encoding: .utf8) {
                    self.jsonText = rawString
                } else {
                    self.jsonText = "Could not load file source."
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
