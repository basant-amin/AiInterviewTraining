//
//  LearningItem.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 12/03/2025.
//
import SwiftUI

struct LearningItem: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding()
                .background(Color.dBlue4)
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            
            Spacer()
        }
        .padding()
        .background(Color.dBlue1)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
