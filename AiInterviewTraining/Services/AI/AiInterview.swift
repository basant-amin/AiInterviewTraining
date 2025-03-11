//
//  AiInterview.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 04/03/2025.
//

import Foundation
import CoreML

class AiInterview {
    static let shared = AiInterview()
    
    private var model: VoiceAnalysis?
    
    private init() {
        do {
            self.model = try VoiceAnalysis(configuration: MLModelConfiguration())
        } catch {
            print("❌ Model loading failed : \(error.localizedDescription)")
        }
    }
    
    func classifySpeed(_ speed: Float) -> String {
        let absSpeed = abs(speed)
        
        if absSpeed < 0.0002 {
            return "Slow"
        } else if absSpeed < 0.001 {
            return "Medium"
        } else {
            return "Fast"
        }
    }


    
    func analyzeVoice(audioData: [Float]) -> (pitch: Double, speed: Double, speedCategory: String, confidence: String)? {
        guard let model = self.model else {
            print("❌ model not uploaded")
            return nil
        }
        
        guard let mlMultiArray = try? MLMultiArray(shape: [1,1], dataType: .float32) else {
            print("❌ Error creating MultiArray")
            return nil
        }
        
        mlMultiArray[0] = NSNumber(value: audioData.first ?? 0.0)
        let input = VoiceAnalysisInput(input_1: mlMultiArray)
        
        guard let output = try? model.prediction(input: input) else {
            print("❌ error predicting voice")
            return nil
        }
        
        let pitch = output.Identity[0].doubleValue
        let speechSpeed = output.Identity_1[0].doubleValue
        let confidenceValue = output.Identity_2[0].doubleValue
        let correctedConfidence = max(0.0, min(1.0, confidenceValue))

        
        print("🔍 Confidence raw value: \(confidenceValue)")

        let confidenceLevel: String
        if correctedConfidence > 0.1 {
            confidenceLevel = "High"
        } else if correctedConfidence > 0.005 {  
            confidenceLevel = "Medium"
        } else {
            confidenceLevel = "Low"
        }



        print("🛠️ Corrected Confidence Value: \(correctedConfidence)")


        let speedCategory = classifySpeed(Float(speechSpeed))

        return (pitch, speechSpeed, speedCategory, confidenceLevel)
    }

}
