//
//  InterviewData.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 07/03/2025.
//

import Foundation
import SwiftData

@Model
class InterviewResult {
    @Attribute(.unique) var id: UUID
    var date: Date
    var pitch: Double
    var speed: Double
    var speedCategory: String
    var confidence: String
    
    @Relationship(deleteRule: .nullify) var category: Category? // ✅ ربط مع Category
    
    @Relationship(deleteRule: .cascade) var questions: [InterviewQuestion] = []
    @Relationship(deleteRule: .cascade) var report: InterviewReport?

    init(id: UUID = UUID(), date: Date = Date(), questions: [InterviewQuestion] = [], pitch: Double, speed: Double, speedCategory: String, confidence: String, category: Category?) {
        self.id = id
        self.date = date
        self.questions = questions
        self.pitch = pitch
        self.speed = speed
        self.speedCategory = speedCategory
        self.confidence = confidence
        self.category = category
    }
}

@Model
class InterviewQuestion {
    var question: String
    var answer: String
    
    init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
}
