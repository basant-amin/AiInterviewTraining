//
//  AudioProcessor.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 04/03/2025.
//


import AVFoundation

class AudioProcessor {
    func extractAudioData(from fileURL: URL) -> [Float]? {
        do {
            print("🔍 Extracting audio data from file: \(fileURL.path)")
            let file = try AVAudioFile(forReading: fileURL)
            let format = file.processingFormat
            let frameCount = UInt32(file.length)
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
            
            try file.read(into: buffer!)

            if let floatChannelData = buffer?.floatChannelData {
                let frameLength = Int(buffer!.frameLength)
                let audioSamples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))
                
                print("🔍 First 10 Values: \(audioSamples.prefix(10))") 
                return audioSamples
            }
        } catch {
            print("❌ Error extracting audio data: \(error.localizedDescription)")
        }
        return nil
    }
}
