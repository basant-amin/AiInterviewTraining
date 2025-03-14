//
//  ResultRow.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 14/03/2025.
//

import SwiftUI
struct ResultRow: View {
    var iconName: String
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(color)
                
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18))
                .foregroundColor(color)
        }
        .padding(.vertical, 8)
    }
}
