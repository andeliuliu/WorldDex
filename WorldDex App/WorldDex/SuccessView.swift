//
//  SuccessView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI
import AVFoundation
import Speech

#if canImport(UIKit)
extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct SuccessView: View {
    var item: String
    var image: UIImage?
    var location: String
    var timestamp: String
    @State var recordingText: String = ""
    var callback: (() -> Void)?

    // Speech recognition properties
    @State private var isRecording = false
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    @State private var lastTranscriptionTime = Date()
    @State private var isTextFieldActive = false

    var body: some View {
        VStack(spacing: 20) {
            if !isTextFieldActive {
                Text("Congrats! You have captured \(item).")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .padding([.top, .leading, .trailing])
                
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Text("You had a XX% chance of capturing it!")
                    .foregroundColor(Color.black)
                HStack {
                    Text(location)
                        .foregroundColor(Color.black)
                        .font(.title)
                    Spacer()
                    Text(timestamp)
                        .font(.title)
                        .foregroundColor(Color.black)
                }
                .padding([.leading, .trailing])
                
                // Only show the mic button when not editing text
                if recordingText.isEmpty {
                    Spacer()
                    Button(action: startRecording) {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .frame(width: 50, height: 80)
                    }
                }
            }
            
            if isTextFieldActive || !recordingText.isEmpty {
                ScrollView {
                    UITextViewWrapper(text: $recordingText)
                        .frame(minHeight: 200)
                        .padding()
                        .onTapGesture {
                            self.isTextFieldActive = true
                        }
                }
            }
            
            Button("Done") {
                stopRecording()
                self.isTextFieldActive = false
                callback?()
            }
            .font(.title)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .onTapGesture {
            self.endEditing()
            self.isTextFieldActive = false
        }
    }
    
    func startRecording() {
        lastTranscriptionTime = Date()
        isRecording = true
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        guard let recognitionTask = try? speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            if let result = result {
                if Date().timeIntervalSince(self.lastTranscriptionTime) >= 3.0 {
                    print("STOP RECORDING")
                    self.stopRecording()
                } else {
                    self.recordingText = result.bestTranscription.formattedString
                    print(self.recordingText)
                    self.lastTranscriptionTime = Date()
                }
            }
        }) else { return }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecording() {
        if !isRecording { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle authorization status here. For simplicity, we're just printing it.
            print(authStatus)
        }
    }
}

