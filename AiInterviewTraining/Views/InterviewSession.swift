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
    
    let recorder = AudioRecorder()
    let processor = AudioProcessor()
    let gptService = GPTService()
    
    // ✅ استقبال التصنيف المختار من صفحة HomePage
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
                
                // ✅ زر بدء المقابلة
                Button("🚀 Start Interview") {
                    startInterview()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isInterviewCompleted)

                // ✅ زر بدء وإيقاف التسجيل
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

                // ✅ زر إنهاء المقابلة
                Button("❌ End Interview") {
                    endInterview()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!hasStarted)

                // ✅ الانتقال لصفحة النتيجة بعد انتهاء المقابلة
                NavigationLink(
                    destination: ResultsView(
                        pitch: finalPitch,
                        speed: finalSpeed,
                        speedCategory: finalSpeedCategory,
                        confidence: finalConfidence,
                        report: generatedReport
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
    
    // ✅ توليد الأسئلة بناءً على التصنيف
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
    
    // ✅ تحليل الملف الصوتي بعد انتهاء التسجيل
    private func processAudioFile(_ fileURL: URL) {
        if let audioData = processor.extractAudioData(from: fileURL) {
            if let result = AiInterview.shared.analyzeVoice(audioData: audioData) {
                saveInterviewResult(
                    pitch: result.pitch,
                    speed: result.speed,
                    speedCategory: result.speedCategory,
                    confidence: result.confidence
                )
            } else {
                print("❌ Failed to analyze voice data.")
            }
        } else {
            print("❌ Failed to extract audio data.")
        }
    }
    
    // ✅ إنهاء المقابلة وتوليد التقرير
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

        gptService.generateReport(
            pitch: finalPitch,
            speed: finalSpeed,
            speedCategory: finalSpeedCategory,
            confidence: finalConfidence
        ) { report in
            DispatchQueue.main.async {
                let finalReport = report ?? "No report available"
                self.generatedReport = finalReport
                self.showingResults = true
            }
        }
    }
    
    // ✅ تخزين نتيجة المقابلة في SwiftData
    private func saveInterviewResult(
        pitch: Double,
        speed: Double,
        speedCategory: String,
        confidence: String
    ) {
        let newInterview = InterviewResult(
            questions: questions.map { InterviewQuestion(question: $0, answer: "User's answer here") },
            pitch: pitch,
            speed: speed,
            speedCategory: speedCategory,
            confidence: confidence
        )
        
        modelContext.insert(newInterview)
        
        gptService.generateReport(
            pitch: pitch,
            speed: speed,
            speedCategory: speedCategory,
            confidence: confidence
        ) { report in
            DispatchQueue.main.async {
                let finalReport = report ?? "No report available"
                
                let newReport = InterviewReport(
                    report: finalReport,
                    interviewResult: newInterview
                )
                modelContext.insert(newReport)

                do {
                    try modelContext.save()
                    print("✅ Report saved successfully!")
                } catch {
                    print("❌ Failed to save report: \(error.localizedDescription)")
                }
                
                self.finalPitch = pitch
                self.finalSpeed = speed
                self.finalSpeedCategory = speedCategory
                self.finalConfidence = confidence
                self.generatedReport = finalReport
            }
        }
    }
    
    // ✅ إعادة ضبط حالة المقابلة
    private func resetInterview() {
        currentQuestionIndex = 0
        questions = []
        isRecording = false
        hasStarted = false
        isLoading = false
    }
}

#Preview {
    InterviewSession(selectedCategory: "Coding")
}
