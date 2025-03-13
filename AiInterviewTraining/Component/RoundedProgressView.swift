//
//  RoundedProgressView.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 13/03/2025.
//


import SwiftUI

struct RoundedProgressView: View {
    var value: Double
    var isLoading: Bool
    var text: String
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
            } else {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(value, 1.0)))
                    .stroke(Color.dBlue4, lineWidth: 10)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: value)
                
                Text("\(Int(value * 100))%")
                    .font(.title)
                    .bold()
                    .foregroundColor(.S_33)
            }
        }
        .frame(width: 120, height: 120)
        .padding()
    }
}

#Preview {
    RoundedProgressView(value: 0.75, isLoading: false, text: "Loading...")
}
