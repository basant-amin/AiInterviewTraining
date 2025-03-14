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
    let onReset: (() -> Void)
    
    @State private var isLoading = true
    
    func getColor(for percentage: Double) -> Color {
        if percentage <= 30 {
            return Color("S2")
        } else if percentage >= 31 && percentage <= 74 {
            return Color("S3")
        } else {
            return Color("S1")
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Your Result")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 50, height: 50)
                    } else {
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(overallScore() / 100, 1.0)))
                            .stroke(getColor(for: overallScore()), lineWidth: 10)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(overallScore()))%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(getColor(for: overallScore()))
                    }
                }
                .frame(width: 120, height: 120)
                .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isLoading = false
                        print("✅ Report Loaded: \(report)")
                    }
                }
                
                VStack(spacing: 10) {
                    ResultRow(iconName: "speak", title: "Speak", value: "\(String(format: "%.2f", pitch * 100))%", color: Color("TBlue1"))
                    Divider().background(Color.white)
                    
                    ResultRow(iconName: "Speed", title: "Speed (\(speedCategory))", value: "\(String(format: "%.2f", speed * 100))%", color: Color("Yellow1"))
                    Divider().background(Color.white)
                    
                    ResultRow(iconName: "Data", title: "Confidence", value: confidence, color: Color("Purple1"))
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Request Details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    ZStack {
                        Color("DBlue1")
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 30, height: 30)
                            } else {
                                Text(report)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    onReset()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Restart Interview")
                            .font(.body)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color("Blue2"))
                    .cornerRadius(15)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color("DBlue4"))
        }
        .background(Color("DBlue4"))
        .navigationBarBackButtonHidden(true)
        
    }
    
    private func overallScore() -> Double {
        return (pitch * 100 + speed * 100) / 2
    }
}


#Preview {
    ResultsView(
        pitch: 0.5,
        speed: 0.4,
        speedCategory: "Medium",
        confidence: "High",
        report: "This is an example report showing your performance.",
        onReset: {}
    )
}
