//
//  CaptureFlowView.swift
//  CamShot
//
//  Created by Elizbar Kheladze on 08/12/25.
//

import SwiftData
import SwiftUI

struct CaptureFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var capturedImage: UIImage?
    @State private var showCamera = true
    @State private var isRecording = false
    @State private var currentBlur: CGFloat = 30.0
    
    @StateObject private var audioManager = AudioManager()
    
    private var canStopRecording: Bool {
        return audioManager.currentTime >= 8.0
    }
    
    var body: some View {
        VStack {
            if let image = capturedImage {
                Spacer()
                
                PolaroidFrame(
                    image: image,
                    audioData: nil,
                    blurAmount: currentBlur,
                    showAudioControls: false
                )
                .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 24) {
                    
                    if isRecording {
                        Text("\(String(format: "%.1f", audioManager.currentTime)) / 30.0")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    } else {
                        Text("Hold to Record & Reveal")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.8))
                            .transition(.opacity)
                    }
                    
                    Button {
                        if !isRecording {
                            startRecordingProcess()
                        } else {
                            if canStopRecording {
                                let data = audioManager.stopRecording()
                                finishRecordingAndSave(audioData: data)
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .strokeBorder(isRecording ? Color.white : Color.black, lineWidth: 3)
                                .frame(width: 74, height: 74)
                            
                            Circle()
                                .fill(isRecording ? (canStopRecording ? Color.red : Color.gray) : Color.black)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Group {
                                        if isRecording {
                                            if canStopRecording {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.white)
                                                    .frame(width: 28, height: 28)
                                            } else {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.white)
                                                    .font(.title2)
                                            }
                                        } else {
                                            Image(systemName: "mic.fill")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                        }
                                    }
                                )
                        }
                    }
                    .disabled(isRecording && !canStopRecording)
                    .animation(.easeInOut, value: canStopRecording)
                }
                .padding(.bottom, 50)
            } else {
                Color(red: 231/255, green: 111/255, blue: 95/255).ignoresSafeArea()
            }
        }
        .background(Color(red: 231/255, green: 111/255, blue: 95/255))
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $capturedImage)
        }
        .onChange(of: showCamera) { _, isOpen in
            if !isOpen && capturedImage == nil {
                dismiss()
            }
        }
        .onAppear {
            audioManager.onRecordingFinished = { audioData in
                finishRecordingAndSave(audioData: audioData)
            }
        }
    }
    
    private func startRecordingProcess() {
        isRecording = true
        audioManager.startRecording()
        
        withAnimation(.linear(duration: 8.0)) {
            currentBlur = 0
        }
    }
    
    private func finishRecordingAndSave(audioData: Data?) {
        guard let image = capturedImage,
              let audioData = audioData,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let newItem = Item(imageData: imageData, audioData: audioData)
        modelContext.insert(newItem)
        
        isRecording = false
        dismiss()
    }
}
