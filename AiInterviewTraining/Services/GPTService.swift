//
//  GPTService.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 06/03/2025.
//


import AVFoundation

class GPTService {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let synthesizer = AVSpeechSynthesizer()

    init() {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("❌ API Key is missing in Config.xcconfig")
        }
        self.apiKey = key
    }

    func generateInterviewQuestions(for category: String, completion: @escaping ([String]?) -> Void) {
        let prompt = """
        Generate 5 job interview questions related to \(category). 
        Make sure they are structured and relevant.
        Output only the questions in a numbered list.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 300
        ]
        
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Error preparing request: \(error)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ API Request Failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    let questions = content.components(separatedBy: "\n").filter { !$0.isEmpty }
                    completion(questions)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ Error parsing response: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }



    func speakText(_ text: String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Error configuring audio session: \(error.localizedDescription)")
        }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.5
        utterance.postUtteranceDelay = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.synthesizer.speak(utterance)
        }
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            print("🛑 Speech stopped.")
        }
    }

    
    
    // Function to generate an interview performance report using GPT
    func generateReport(pitch: Double, speed: Double, speedCategory: String, confidence: String, completion: @escaping (String?) -> Void) {
        let prompt = """
        Analyze the following voice interview performance metrics and provide a structured feedback report:

        - 🎤 Pitch: \(pitch)
        - ⚡ Speed: \(speed) (\(speedCategory))
        - ✅ Confidence: \(confidence)

        Provide feedback on the candidate's fluency, articulation, and confidence.
        Offer practical suggestions for improvement and highlight strengths.
        Keep the response structured and concise.
        """

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 250
        ]

        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ Error preparing request: \(error)")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ API Request Failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let report = message["content"] as? String {
                    completion(report)
                } else {
                    completion(nil)
                }
            } catch {
                print("❌ Error parsing response: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }


}
