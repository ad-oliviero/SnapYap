import AVFoundation
import SwiftUI

struct CameraView: View {
    @State private var session = AVCaptureSession()

    var body: some View {
        VStack {
            CameraPreview(session: session)
                .task {
                    await setupCamera()
                }
                .border(.blue)
            CameraInterfaceView()
        }
    }

    private func setupCamera() async {
        guard await checkPermissions() else { return }
        session.beginConfiguration()

        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)
        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func checkPermissions() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

        override func layoutSubviews() {
            super.layoutSubviews()
            if let connection = videoPreviewLayer.connection {
                if #available(iOS 17.0, *) {
                    if connection.isVideoRotationAngleSupported(90) {
                        connection.videoRotationAngle = 90
                    }
                } else {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                }
            }
        }
    }
}
