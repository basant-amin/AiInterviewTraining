//
//  Category.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 12/03/2025.
//

import Foundation 
import SwiftData

@Model
class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \InterviewResult.category)
    var interviewResults: [InterviewResult] = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
