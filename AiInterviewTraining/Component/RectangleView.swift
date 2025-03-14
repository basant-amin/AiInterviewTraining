//
//  RectangleView.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 13/03/2025.
//

import SwiftUI

struct RectangleView: View {
    var percentage: Double
    var categoryName: String
    var pronunciationHealth: Double
    var soundLevel: Double
    var dataAccuracy: String
    var date: String
    
    func getColor(for percentage: Double) -> (Color, Color) {
        if percentage <= 30 {
            return (Color("S2"), Color("S2"))
        } else if percentage >= 31 && percentage <= 74 {
            return (Color("S3"), Color("S3"))
        } else {
            return (Color("S1"), Color("S1"))
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 7)
                        .foregroundColor(percentage <= 30 ? Color("S22") : (percentage >= 31 && percentage <= 74 ? Color("S33") : Color("S11")))
                    
                    let colors = getColor(for: percentage)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(percentage / 100))
                        .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .foregroundColor(colors.0)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(percentage))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(colors.1)
                }
                .frame(width: 50, height: 50)
                .offset(x: 20)
            }
            
            VStack(alignment: .leading) {
                Text(categoryName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                    .offset(y: 18)
                    .offset(x: 8)
                
                HStack {
                    Spacer()
                    Text(" \(date)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                        .offset(y: 30)
                        .offset(x: -10)
                }
                
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .frame(width: 23, height: 23)
                                .foregroundColor(Color("TBlue1"))
                                .offset(x: 8)
                                .offset(y: -17)
                            Image("speak")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 15, height: 15)
                                .offset(x: 8)
                                .offset(y: -17)
                        }
                        Text(" \(Int(pronunciationHealth))%")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TBlue1"))
                            .offset(x: 8)
                            .offset(y: -17)
                    }
                    
                    HStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .frame(width: 23, height: 23)
                                .foregroundColor(Color("Yellow1"))
                                .offset(x: 16)
                                .offset(y: -17)
                            Image("Speed")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 15, height: 15)
                                .offset(x: 16)
                                .offset(y: -17)
                        }
                        Text(" \(Int(soundLevel))%")
                            .font(.system(size: 12))
                            .foregroundColor(Color("Yellow1"))
                            .offset(x: 16)
                            .offset(y: -17)
                    }

                    HStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .frame(width: 23, height: 23)
                                .foregroundColor(Color("Purple1"))
                                .offset(x: 24)
                                .offset(y: -17)
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .offset(x: 24)
                                .offset(y: -17)
                        }
                        Text(" \(dataAccuracy)")
                            .font(.system(size: 12))
                            .foregroundColor(Color("Purple1"))
                            .offset(x: 24)
                            .offset(y: -17)
                    }
                }
            }
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 360, height: 85)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color("DBlue3")))
        .padding(.horizontal)
    }
}
