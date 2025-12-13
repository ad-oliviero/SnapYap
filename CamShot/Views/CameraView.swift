//
//  CameraView.swift
//  CamShot
//
//  Created by Elizbar Kheladze on 08/12/25.
//

import SwiftUI
import AVFoundation
import Combine

// MARK:  Camera Logic
class CameraModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage?
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var isFrontCamera = false
    
    private var output = AVCapturePhotoOutput()
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status { self.setUp() }
            }
        default:
            return
        }
    }
    
    func setUp() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.configureSession(deviceType: .builtInWideAngleCamera, position: .back)
        }
    }
    
    private func configureSession(deviceType: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position) {
        session.beginConfiguration()
        
        if let currentInput = session.inputs.first {
            session.removeInput(currentInput)
        }
        
        let device = AVCaptureDevice.default(deviceType, for: .video, position: position)
                     ?? AVCaptureDevice.default(for: .video)
        
        if let device = device,
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }
        
        if !session.outputs.contains(output) {
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        }
        
        session.commitConfiguration()
        
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            let settings = AVCapturePhotoSettings()
            settings.flashMode = self.flashMode
            self.output.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func toggleFlash() {
        flashMode = (flashMode == .on) ? .off : .on
    }
    
    func flipCamera() {
        isFrontCamera.toggle()
        let position: AVCaptureDevice.Position = isFrontCamera ? .front : .back
        configureSession(deviceType: .builtInWideAngleCamera, position: position)
    }
    
    func setZoom(factor: CGFloat) {
        guard !isFrontCamera else { return }
        
        let deviceType: AVCaptureDevice.DeviceType = (factor < 1.0) ? .builtInUltraWideCamera : .builtInWideAngleCamera
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.configureSession(deviceType: deviceType, position: .back)
        }
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil { return }
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async {
            if self.isFrontCamera {
                self.capturedImage = UIImage(cgImage: uiImage.cgImage!, scale: uiImage.scale, orientation: .leftMirrored)
            } else {
                self.capturedImage = uiImage
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> AutoSizingCameraView {
        let view = AutoSizingCameraView()
        view.previewLayer.session = camera.session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: AutoSizingCameraView, context: Context) {}
    
    class AutoSizingCameraView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// MARK:  UI Layout
struct CameraView: View {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var camera = CameraModel()
    @State private var zoomLevel: Int = 1
    
    let bgOrange = Color(red: 231/255, green: 111/255, blue: 95/255)
    let panelRed = Color(red: 180/255, green: 85/255, blue: 85/255)
    let buttonCream = Color(red: 255/255, green: 248/255, blue: 220/255)
    let switchBlue = Color(red: 40/255, green: 90/255, blue: 140/255)
    let headerColor = Color(red: 120/255, green: 50/255, blue: 50/255)
    
    var body: some View {
        ZStack {
            bgOrange.ignoresSafeArea()
            
            VStack {
                Text("Camera")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(headerColor)
                    .padding(.top, 30)
                
                Spacer()
                
                ZStack {
                    if let captured = camera.capturedImage {
                        Image(uiImage: captured)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 350, height: 350)
                            .clipped()
                    } else {
                        CameraPreview(camera: camera)
                            .frame(width: 350, height: 350)
                            .onAppear { camera.checkPermissions() }
                    }
                }
                .border(Color.blue, width: 4)
                .background(Color.black)
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(panelRed)
                        .ignoresSafeArea(edges: .bottom)
                    
                    VStack(spacing: 30) {
                        HStack(spacing: 0) {
                            Text("1x").font(.headline)
                                .frame(width: 60, height: 40)
                                .background(zoomLevel == 0 ? Color.white.opacity(0.3) : Color.clear)
                            Text("0.5x").font(.headline)
                                .frame(width: 60, height: 40)
                                .background(zoomLevel == 1 ? Color.white.opacity(0.3) : Color.clear)
                        }
                        .background(switchBlue)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                        .onTapGesture {
                            withAnimation {
                                zoomLevel = (zoomLevel == 0 ? 1 : 0)
                                camera.setZoom(factor: zoomLevel == 0 ? 0.5 : 1.0)
                            }
                        }
                        
                        HStack(spacing: 50) {
                            Button(action: { camera.toggleFlash() }) {
                                Circle().fill(buttonCream).frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: camera.flashMode == .on ? "bolt.fill" : "bolt.slash.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(camera.flashMode == .on ? .orange : .gray)
                                    )
                            }
                            
                            Button(action: { camera.takePic() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 90, height: 90)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 80, height: 80)
                                }
                            }
                            
                            Button(action: { camera.flipCamera() }) {
                                Circle().fill(buttonCream).frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 30))
                                            .foregroundColor(.blue)
                                            .rotationEffect(.degrees(camera.isFrontCamera ? 180 : 0))
                                            .animation(.spring(), value: camera.isFrontCamera)
                                    )
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .padding(.top, 20)
                }
                .frame(height: 320)
            }
        }
        .onChange(of: camera.capturedImage) { newImage in
            if let availableImage = newImage {
                self.image = availableImage
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
