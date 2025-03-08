//
//  HistoryView.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 07/03/2025.
//


import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var interviewResults: [InterviewResult] 

    var body: some View {
        List(interviewResults) { interview in
            NavigationLink(destination: InterviewDetailView(interview: interview)) {
                VStack(alignment: .leading) {
                    Text("📅 Interview")
                        .font(.headline)
                    Text("⚡ Speed: \(interview.speedCategory)")
                    Text("✅ Confidence: \(interview.confidence)")
                }
            }
        }
        .navigationTitle("📜 Interview History")
    }
}
