//
//  InterviewReport.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 10/03/2025.
//


import Foundation
import SwiftData

@Model
class InterviewReport {
    @Attribute(.unique) var id: UUID
    var date: Date
    var report: String
    @Relationship(deleteRule: .cascade) var interviewResult: InterviewResult? 

    init(id: UUID = UUID(), date: Date = Date(), report: String, interviewResult: InterviewResult? = nil) {
        self.id = id
        self.date = date
        self.report = report
        self.interviewResult = interviewResult
    }
}
