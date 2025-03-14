//
//  AudioRecorder.swift
//  AiInterviewTraining
//
//  Created by basant amin bakir on 04/03/2025.
//


import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    var audioFileURL: URL?
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Error setting up audio session: \(error.localizedDescription)")
            return
        }
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        audioFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("recordedAudio.m4a")
        
        if let fileURL = audioFileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            print("🎤 Start Recording...")
            print("📁 File path: \(audioFileURL!.path)")
        } catch {
            print("❌ Error starting recording: \(error.localizedDescription)")
        }
    }
    
    //    func stopRecording(completion: @escaping (URL?) -> Void) {
    //        guard let recorder = audioRecorder, recorder.isRecording else {
    //            print("❌ No active recording to stop.")
    //            completion(nil)
    //            return
    //        }
    //
    //        recorder.stop()
    //
    //        // ✅ تأكيد أن الملف المسجل موجود
    //        let recordedFileURL = recorder.url
    //        print("✅ Recording stopped. File saved at: \(recordedFileURL)")
    //
    //        // ✅ تأخير بسيط قبل تنفيذ completion (إعطاء وقت للنظام لمعالجة الملف)
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    //            completion(recordedFileURL)
    //        }
    //    }
    
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard let recorder = audioRecorder, recorder.isRecording else {
            print("❌ No active recording to stop.")
            completion(nil)
            return
        }

        recorder.stop()
        
        let recordedFileURL = recorder.url
        print("✅ Recording stopped. File saved at: \(recordedFileURL)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(recordedFileURL)
        }
    }

    
}
