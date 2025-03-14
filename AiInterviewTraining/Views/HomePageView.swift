//
//  HomePage.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 12/03/2025.
//

import SwiftUI

struct HomePageView: View {
    @State private var searchText = ""
    let categories: [(name: String, icon: String, color: Color)] = [
        ("Coding", "desktopcomputer", Color.purple2),
        ("UI/UX design", "paintbrush", Color.blue2),
        ("Business", "briefcase", Color.orange2)
    ]
    let learningItems = [
        ("Before the Interview", "book.fill"),
        ("During the Interview", "mic.fill"),
        ("After the Interview", "checkmark.circle.fill")
    ]
    var filteredLearningItems: [(String, String)] {
        if searchText.isEmpty {
            return learningItems
        } else {
            return learningItems.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    var body: some View {
        NavigationView {
            ZStack {
                Color.dBlue4
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        Text("Hello, Good Morning")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        NavigationLink(destination: HistoryView()) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("", text: $searchText, prompt: Text("Search").foregroundColor(.white.opacity(0.5)))
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .background(
                        Color.dBlue1
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Text("Categories")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top,20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(categories, id: \.name) { category in
                                NavigationLink(destination: InterviewSession(selectedCategory: category.name)) {
                                    VStack {
                                        Image(systemName: category.icon)
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                            .padding()
                                        
                                        Text(category.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 150, height: 200)
                                    .background(category.color)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Learning & Practice")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top,20)
                    
                    VStack(spacing: 12) {
                        LearningItem(title: "Befor the Interview", icon: "book.fill")
                        LearningItem(title: "During the Interview", icon: "mic.fill")
                        LearningItem(title: "After the Interview", icon: "checkmark.circle.fill")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}



#Preview {
    HomePageView()
}
