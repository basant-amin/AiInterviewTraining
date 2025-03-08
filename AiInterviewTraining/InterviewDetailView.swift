//
//  InterviewDetailView.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 07/03/2025.
//


import SwiftUI
import SwiftData

struct InterviewDetailView: View {
    let interview: InterviewResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📅 Interview Details")
                .font(.title)
                .bold()

            Text("🎤 Pitch: \(interview.pitch, specifier: "%.2f")")
            Text("⚡ Speed: \(interview.speed, specifier: "%.2f") (\(interview.speedCategory))")
            Text("✅ Confidence: \(interview.confidence)")

            Divider()

            Text("📝 Questions & Answers")
                .font(.headline)

            ForEach(interview.questions) { question in
                VStack(alignment: .leading) {
                    Text("💬 Question: \(question.question)")
                        .bold()
                    Text("✍️ Answer: \(question.answer)")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .navigationTitle("Interview Details")
    }
}
