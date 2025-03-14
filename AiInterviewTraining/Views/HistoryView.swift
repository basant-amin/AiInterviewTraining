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
        NavigationView {
            ZStack {
                Color.dBlue4
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    if interviews.isEmpty {
                        emptyStateView()
                    } else {
                        interviewsListView()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("History")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }


    @ViewBuilder
    private func emptyStateView() -> some View {
        VStack {
            Image("NoData")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            Text("There are no results")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, -40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("DBlue4"))
    }

    @ViewBuilder
    private func interviewsListView() -> some View {
        VStack(spacing: 20) {
            ForEach(interviews) { interview in
                navigationLink(for: interview)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func navigationLink(for interview: InterviewResult) -> some View {
        NavigationLink(
            destination: ResultsView(
                pitch: interview.pitch,
                speed: interview.speed,
                speedCategory: interview.speedCategory,
                confidence: interview.confidence,
                report: interview.report?.report ?? "No report available",
                onReset: {
                    print("No reset needed in HistoryView")
                }
              
            )
        ) {
            RectangleView(
                percentage: (
                    interview.pitch * 100 + interview.speed * 100
                ) / 2,
                categoryName: interview.category?.name ?? "No Category",
                              pronunciationHealth: interview.pitch * 100,
                soundLevel: interview.speed * 100,
                dataAccuracy: interview.confidence,
                date: formatDate(interview.date)
            )
        }
    }

    private var navigationBar: some View {
        HStack {
            Button(action: {
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            Text("History")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
