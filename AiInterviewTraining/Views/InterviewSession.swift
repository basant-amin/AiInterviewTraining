//
//  ContentView.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 04/03/2025.
//

import SwiftUI
import SwiftData

struct InterviewSession: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isRecording = false
    @State private var questions: [String] = []
    @State private var currentQuestionIndex = 0
    @State private var isLoading = false
    @State private var hasStarted = false
    @State private var isInterviewCompleted = false
    @State private var finalPitch: Double = 0.0
    @State private var finalSpeed: Double = 0.0
    @State private var finalSpeedCategory: String = ""
    @State private var finalConfidence: String = ""
    @State private var generatedReport: String = ""
    @State private var showingResults = false
    @State private var hasSavedResult = false
    
    
    let recorder = AudioRecorder()
    let processor = AudioProcessor()
    let gptService = GPTService()
    
    let selectedCategory: String
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("🎙️AI Interview: \(selectedCategory)")
                    .font(.title)
                    .padding()
                
                NavigationLink(destination: ResultsView(
                    pitch: finalPitch,
                    speed: finalSpeed,
                    speedCategory: finalSpeedCategory,
                    confidence: finalConfidence,
                    report: generatedReport,
                    onReset: {
                        print("No reset needed in HistoryView")
                    }
                    
                )
                    .onDisappear {
                        resetInterview()
                    }, isActive: $showingResults) {
                        EmptyView()
                    }
                
                if isLoading {
                    ProgressView("Generating questions...")
                } else if currentQuestionIndex < questions.count {
                    Text("💬 Question: \(questions[currentQuestionIndex])")
                        .font(.headline)
                        .padding()
                } else {
                    Text("🔹 Press 'Start Interview' to begin.")
                        .padding()
                }
                
                Button("🚀 Start Interview") {
                    startInterview()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isInterviewCompleted)
                
                Button(isRecording ? "⏹ Stop Recording" : "🎤 Start Recording") {
                    if isRecording {
                        recorder.stopRecording { fileURL in
                            if let url = fileURL {
                                processAudioFile(url)
                            }
                        }
                    } else {
                        recorder.startRecording()
                    }
                    isRecording.toggle()
                }
                .padding()
                .background(isRecording ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(questions.isEmpty)
                
                Button("❌ End Interview") {
                    endInterview()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!hasStarted)
                
                NavigationLink(
                    destination: ResultsView(
                        pitch: finalPitch,
                        speed: finalSpeed,
                        speedCategory: finalSpeedCategory,
                        confidence: finalConfidence, report: generatedReport, onReset: resetInterview
                        
                    ),
                    
                    isActive: $showingResults
                ) {
                    EmptyView()
                }
                
            }
            .padding()
            
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private func startInterview() {
        isLoading = true
        hasStarted = true
        isInterviewCompleted = false
        
        gptService.generateInterviewQuestions (for: selectedCategory){ newQuestions in
            DispatchQueue.main.async {
                isLoading = false
                if let newQuestions = newQuestions, !newQuestions.isEmpty {
                    self.questions = newQuestions
                    self.currentQuestionIndex = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if !self.isInterviewCompleted {
                            self.gptService.speakText(self.questions[self.currentQuestionIndex])
                        }
                    }
                } else {
                    self.questions = ["❌ Failed to generate questions."]
                }
            }
        }
    }
    
        
    private func processAudioFile(_ fileURL: URL) {
        let audioProcessor = AudioProcessor()
        
        if let audioData = audioProcessor.extractAudioData(from: fileURL) {
            if let result = AiInterview.shared.analyzeVoice(audioData: audioData) {
                
                let existingResult = try? modelContext.fetch(FetchDescriptor<InterviewResult>())
                    .first(where: {
                        $0.pitch == result.pitch &&
                        $0.speed == result.speed &&
                        $0.confidence == result.confidence &&
                        $0.category?.name == selectedCategory
                    })
                
                if existingResult == nil && !hasSavedResult {
                    let existingCategory = try? modelContext.fetch(FetchDescriptor<Category>())
                        .first(where: { $0.name == selectedCategory })
                    
                    let category = existingCategory ?? Category(name: selectedCategory)
                    if existingCategory == nil {
                        modelContext.insert(category)
                    }
                    
                    let newInterview = InterviewResult(
                        questions: questions.map { InterviewQuestion(question: $0, answer: "User's answer here") },
                        pitch: result.pitch,
                        speed: result.speed,
                        speedCategory: result.speedCategory,
                        confidence: result.confidence,
                        category: category
                    )
                    modelContext.insert(newInterview)
                    
                    gptService.generateReport(
                        pitch: result.pitch,
                        speed: result.speed,
                        speedCategory: result.speedCategory,
                        confidence: result.confidence
                    ) { report in
                        DispatchQueue.main.async {
                            let finalReport = report ?? "No report available"
                            let newReport = InterviewReport(
                                report: finalReport,
                                interviewResult: newInterview
                            )
                            modelContext.insert(newReport)
                            newInterview.report = newReport
                            
                            do {
                                try modelContext.save()
                                print("✅ Report saved successfully!")
                            } catch {
                                print("❌ Failed to save report: \(error)")
                            }
                            
                            self.finalPitch = result.pitch
                            self.finalSpeed = result.speed
                            self.finalSpeedCategory = result.speedCategory
                            self.finalConfidence = result.confidence
                            self.generatedReport = finalReport
                            
                            self.hasSavedResult = true
                            
                            if self.currentQuestionIndex < self.questions.count - 1 {
                                self.currentQuestionIndex += 1
                                self.gptService.speakText(self.questions[self.currentQuestionIndex])
                            } else {
                                self.isInterviewCompleted = true
                            }
                        }
                    }
                } else {
                    print("⚠️ Result already exists — Skipping insert.")
                }
            } else {
                print("❌ Failed to analyze voice data.")
            }
        } else {
            print("❌ Failed to extract audio data.")
        }
    }
    
        
    private func endInterview() {
        if isRecording {
            recorder.stopRecording { fileURL in
                if let url = fileURL {
                    processAudioFile(url)
                }
            }
        }
        
        isRecording = false
        hasStarted = false
        gptService.stopSpeaking()
        isInterviewCompleted = true
        
        if hasSavedResult {
            print("⚠️ Result already saved — Skipping save in endInterview.")
            self.showingResults = true
            return
        }
        
        let existingCategory = try? modelContext.fetch(FetchDescriptor<Category>())
            .first(where: { $0.name == selectedCategory })
        
        let category = existingCategory ?? Category(name: selectedCategory)
        if existingCategory == nil {
            modelContext.insert(category)
        }
        
        let newInterview = InterviewResult(
            questions: questions.map { InterviewQuestion(question: $0, answer: "User's answer here") },
            pitch: finalPitch,
            speed: finalSpeed,
            speedCategory: finalSpeedCategory,
            confidence: finalConfidence,
            category: category
        )
        
        modelContext.insert(newInterview)
        
        gptService.generateReport(
            pitch: finalPitch,
            speed: finalSpeed,
            speedCategory: finalSpeedCategory,
            confidence: finalConfidence
        ) { report in
            DispatchQueue.main.async {
                let finalReport = report ?? "No report available"
                let newReport = InterviewReport(
                    report: finalReport,
                    interviewResult: newInterview
                )
                modelContext.insert(newReport)
                newInterview.report = newReport
                
                do {
                    try modelContext.save()
                    print("✅ Report saved successfully!")
                } catch {
                    print("❌ Failed to save report: \(error)")
                }
                
                self.finalPitch = newInterview.pitch
                self.finalSpeed = newInterview.speed
                self.finalSpeedCategory = newInterview.speedCategory
                self.finalConfidence = newInterview.confidence
                self.generatedReport = newReport.report
                
                self.showingResults = true
                self.hasSavedResult = true
            }
        }
    }
    
    
    private func resetInterview() {
        currentQuestionIndex = 0
        questions = []
        isRecording = false
        hasStarted = false
        isLoading = false
    }
    
    private func saveInterviewResult(
        pitch: Double,
        speed: Double,
        speedCategory: String,
        confidence: String,
        report: String? = nil
    ) -> InterviewResult {
        let questionsData = questions.map { InterviewQuestion(question: $0, answer: "User's answer here") }
        
        let newInterview = InterviewResult(
            questions: questionsData,
            pitch: pitch,
            speed: speed,
            speedCategory: speedCategory,
            confidence: confidence
        )
        
        modelContext.insert(newInterview)
        do {
            try modelContext.save()
            print("✅ Interview data saved successfully.")
        } catch {
            print("❌ Failed to save interview: \(error.localizedDescription)")
        }
        
        if let report = report {
            let newReport = InterviewReport(
                report: report,
                interviewResult: newInterview
            )
            modelContext.insert(newReport)
            do {
                try modelContext.save()
                print("✅ Report saved successfully.")
            } catch {
                print("❌ Failed to save report: \(error.localizedDescription)")
            }
        }
        
        return newInterview
    }
    
}

//#Preview {
//    InterviewSession()
//}
