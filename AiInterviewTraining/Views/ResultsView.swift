//
//  ResultsView.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 09/03/2025.
//

import SwiftUI

struct ResultsView: View {
    @Environment(\.presentationMode) var presentationMode
    let pitch: Double
    let speed: Double
    let speedCategory: String
    let confidence: String
    let report: String
    
    var body: some View {
        
        VStack {
            Text("📊 Your Result")
                .font(.title)
                .bold()
                .padding()

            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(overallScore() / 100, 1.0)))
                    .stroke(Color.green, lineWidth: 10)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(overallScore()))%")
                    .font(.title)
                    .bold()
                    .foregroundColor(.green)
            }
            .frame(width: 120, height: 120)
            .padding()

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundColor(.blue)
                    Text("Pitch")
                    Spacer()
                    Text("\(String(format: "%.2f", pitch))")
                }
                .padding()

                HStack {
                    Image(systemName: "speedometer")
                        .foregroundColor(.yellow)
                    Text("Speed (\(speedCategory))")
                    Spacer()
                    Text("\(String(format: "%.2f", speed))")
                }
                .padding()

                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.gray)
                    Text("Confidence")
                    Spacer()
                    Text(confidence)
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding()

            VStack(alignment: .leading) {
                Text("📝 Report Summary")
                    .font(.headline)
                    .padding(.bottom, 5)

                ScrollView {
                    Text(report)
                        .font(.body)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                }
                .frame(height: 200)
            }
            .padding()

            Button("🔄 Restart Interview") {
                restartInterview()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func overallScore() -> Double {
        return (pitch * 100 + speed * 100) / 2
    }

    private func restartInterview() {
        print("🔄 Restarting interview...")
        presentationMode.wrappedValue.dismiss() 
    }
}

#Preview {
    ResultsView(
        pitch: 0.5,
        speed: 0.4,
        speedCategory: "Medium",
        confidence: "High",
        report: """
        Overall, 
        """
    )
}
