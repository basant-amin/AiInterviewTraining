//
//  ContentView.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 04/03/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isRecording = false
    @State private var questions: [String] = []
    @State private var currentQuestionIndex = 0
    @State private var isLoading = false
    @State private var hasStarted = false

    let recorder = AudioRecorder()
    let processor = AudioProcessor()
    let gptService = GPTService()

    var body: some View {
        NavigationStack {
            VStack {
                Text("🎙️ AI Interview Training")
                    .font(.title)
                    .bold()
                    .padding()

                NavigationLink(destination: HistoryView()) {
                    Text("📜 View Interview Results")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
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
            }
            .padding()
        }
    }

    private func startInterview() {
        isLoading = true
        hasStarted = false

        gptService.generateInterviewQuestions { newQuestions in
            DispatchQueue.main.async {
                isLoading = false
                if let newQuestions = newQuestions, !newQuestions.isEmpty {
                    self.questions = newQuestions
                    self.currentQuestionIndex = 0

                    if !self.hasStarted {
                        self.hasStarted = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
            print("📂 File path: \(fileURL.path)")
            print("🔍 First 10 values: \(audioData.prefix(10))")

            print("🔍 Passing audio data for analysis...")
            if let result = AiInterview.shared.analyzeVoice(audioData: audioData) {
                print("🎤 Pitch: \(result.pitch)")
                print("⚡ Speed: \(result.speed) (\(result.speedCategory))")
                print("✅ Confidence: \(result.confidence)")

                saveInterviewResult(
                    pitch: result.pitch,
                    speed: result.speed,
                    speedCategory: result.speedCategory,
                    confidence: result.confidence
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if self.currentQuestionIndex < self.questions.count - 1 {
                        self.currentQuestionIndex += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.gptService.speakText(self.questions[self.currentQuestionIndex])
                        }
                    } else {
                        print("🎉 Interview Completed!")
                    }
                }
            } else {
                print("❌ Failed to analyze voice data.")
            }
        } else {
            print("❌ Failed to extract audio data")
        }
    }

    private func saveInterviewResult(pitch: Double, speed: Double, speedCategory: String, confidence: String) {
        let questionsData = questions.map { InterviewQuestion(question: $0, answer: "User's answer here") }

        let newInterview = InterviewResult(
            questions: questionsData,
            pitch: pitch,
            speed: speed,
            speedCategory: speedCategory,
            confidence: confidence
        )

        do {
            modelContext.insert(newInterview)
            try modelContext.save()
            print("✅ Interview data saved successfully.")
        } catch {
            print("❌ Failed to save interview: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
