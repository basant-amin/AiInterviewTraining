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
    @State private var isManuallyEnded = false
    
    let recorder = AudioRecorder()
    let processor = AudioProcessor()
    let gptService = GPTService()
    
    let selectedCategory: String
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("🎙️ AI Interview: \(selectedCategory)")
                    .font(.title)
                    .padding()
                
                if isLoading {
                    ProgressView("Generating questions for \(selectedCategory)...")
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
                                processAudioFile(url) {
                                    print("✅ Finished processing audio")
                                }
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
                        confidence: finalConfidence,
                        report: generatedReport,
                        onReset: resetInterview
                    ),
                    isActive: $showingResults
                ) {
                    EmptyView()
                }


            }
            .padding()
            .toolbar {
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
    
    private func resetInterview() {
        print("🔄 Resetting interview...")
        currentQuestionIndex = 0
        questions = []
        isRecording = false
        hasStarted = false
        isLoading = false
        isInterviewCompleted = false
        finalPitch = 0.0
        finalSpeed = 0.0
        finalSpeedCategory = ""
        finalConfidence = ""
        generatedReport = ""
        showingResults = false
    }

    private func startInterview() {
        isLoading = true
        hasStarted = true
        isInterviewCompleted = false
        
        gptService.generateInterviewQuestions(for: selectedCategory) { newQuestions in
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

    private func processAudioFile(_ fileURL: URL, completion: @escaping () -> Void) {
        if let audioData = processor.extractAudioData(from: fileURL) {
            if let result = AiInterview.shared.analyzeVoice(audioData: audioData) {
                print("🔎 Detected speed: \(result.speed)")
                print("🔎 Speed Category: \(result.speedCategory)")
                
                do {
                    let existingCategory = try modelContext.fetch(FetchDescriptor<Category>())
                        .first(where: { $0.name == selectedCategory })

                    if let category = existingCategory {
                        saveInterviewResult(
                            pitch: result.pitch,
                            speed: result.speed,
                            speedCategory: result.speedCategory,
                            confidence: result.confidence,
                            category: category
                        )
                    } else {
                        let newCategory = Category(name: selectedCategory)
                        modelContext.insert(newCategory)

                        saveInterviewResult(
                            pitch: result.pitch,
                            speed: result.speed,
                            speedCategory: result.speedCategory,
                            confidence: result.confidence,
                            category: newCategory
                        )
                    }

                    self.finalPitch = result.pitch
                    self.finalSpeed = result.speed
                    self.finalSpeedCategory = result.speedCategory
                    self.finalConfidence = result.confidence

                    completion()
                    
                    if !self.isInterviewCompleted && !self.isManuallyEnded {
                        print("➡️ Moving to next question...")
                        self.startNextQuestion()
                    }
                    
                } catch {
                    print("❌ Failed to save result: \(error.localizedDescription)")
                    completion()
                }
            }
        } else {
            print("❌ Failed to extract audio data.")
            completion()
        }
    }
    

    private func endInterview() {
        isManuallyEnded = true
        isInterviewCompleted = true
        gptService.stopSpeaking()
        
        if isRecording {
            recorder.stopRecording { fileURL in
                if let url = fileURL {
                    processAudioFile(url) {
                        gptService.generateReport(
                            pitch: self.finalPitch,
                            speed: self.finalSpeed,
                            speedCategory: self.finalSpeedCategory,
                            confidence: self.finalConfidence
                        ) { report in
                            DispatchQueue.main.async {
                                let finalReport = report ?? "No report available"
                                self.generatedReport = finalReport
                                self.isLoading = false
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.showingResults = true
                                }
                            }
                        }
                    }
                }
            }
        } else {
            gptService.generateReport(
                pitch: self.finalPitch,
                speed: self.finalSpeed,
                speedCategory: self.finalSpeedCategory,
                confidence: self.finalConfidence
            ) { report in
                DispatchQueue.main.async {
                    let finalReport = report ?? "No report available"
                    self.generatedReport = finalReport
                    self.isLoading = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showingResults = true
                    }
                }
            }
        }
    }

    
    private func startNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !self.isInterviewCompleted && !self.isManuallyEnded {
                    self.gptService.speakText(nextQuestion)
                }
            }
        } else {
            print("✅ All questions completed!")
            DispatchQueue.main.async {
                self.showingResults = true
            }
        }
    }

    private func saveInterviewResult(
        pitch: Double,
        speed: Double,
        speedCategory: String,
        confidence: String,
        category: Category
    ) {
        let newInterview = InterviewResult(
            pitch: pitch,
            speed: speed,
            speedCategory: speedCategory,
            confidence: confidence,
            category: category
        )
        modelContext.insert(newInterview)

        do {
            try modelContext.save()
            print("✅ Saved interview result")
        } catch {
            print("❌ Error saving result: \(error.localizedDescription)")
        }
    }
}

#Preview {
    InterviewSession(selectedCategory: "Coding")
}
