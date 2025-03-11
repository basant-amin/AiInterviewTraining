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
    @Query(sort: \InterviewResult.date, order: .reverse) private var interviews: [InterviewResult]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("📜 Interview History")
                    .font(.title)
                    .bold()
                    .padding()

                if interviews.isEmpty {
                    Text("🗃️ No previous interviews found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(interviews) { interview in
                        NavigationLink(destination: ResultsView(
                            pitch: interview.pitch,
                            speed: interview.speed,
                            speedCategory: interview.speedCategory,
                            confidence: interview.confidence,
                            report: interview.report?.report ?? "No report available"

                         
                        )) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("🗓️ \(formatDate(interview.date))")
                                        .font(.headline)
                                    Text("Pitch: \(String(format: "%.2f", interview.pitch)) | Speed: \(String(format: "%.2f", interview.speed))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("History")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
