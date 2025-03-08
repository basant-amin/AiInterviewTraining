//
//  AiInterviewTrainingApp.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 04/03/2025.
//

import SwiftUI

@main
struct AiInterviewTrainingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: InterviewResult.self)
        }
    }
}
