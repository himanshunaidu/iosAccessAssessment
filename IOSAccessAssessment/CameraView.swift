//
//  CameraView.swift
//  IOSAccessAssessment
//
//  Created by Sai on 1/25/24.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML



let espnet_model = espnetv2_pascal_256()


// Assuming the file espnetv2_pascal_256.mlmodel exists in the same directory


struct CameraView: View {
    
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var isShowingCamera = false
    
    do {
        let espnet_model = try MLModel(contentsOf: modelURL)
        // Use the loaded model as needed
    } catch {
        fatalError("Failed to load espnetv2_pascal_256.mlmodel: \(error)")
    }
    
    do {
        let espnet_model = try MLModel(contentsOf: modelURL)
        // Use the loaded model as needed
    } catch {
        fatalError("Failed to load espnetv2_pascal_256.mlmodel: \(error)")
    }

    var body: some View {
        VStack {
            if isShowingCamera {
                CameraPreview(cameraViewModel: cameraViewModel)
            } else {
                Button("Show Camera") {
                    cameraViewModel.setupCamera()
                    isShowingCamera = true
                }
            }
        }
        .onDisappear {
            cameraViewModel.stopCaptureSession()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraViewModel: CameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraViewModel.getCaptureSession())
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var bufferSize: CGSize = .zero
    private var requests = [VNRequest]()
    private let captureSession = AVCaptureSession()

    override init() {
        super.init()
        setupVisionModel()
    }
    
    func getCaptureSession() -> AVCaptureSession {
            return captureSession
    }

    func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait

        captureSession.startRunning()
    }

    func stopCaptureSession() {
        captureSession.stopRunning()
    }

    func setupVisionModel() {
        guard let visionModel = try? VNCoreMLModel(for: espnet_model.model) else {
            fatalError("Can not load CNN model")
        }

        let segmentationRequest = VNCoreMLRequest(model: visionModel) { request, error in
            if let results = request.results as? [VNPixelBufferObservation], let firstResult = results.first {
                DispatchQueue.main.async {
                    self.processSegmentationRequest(firstResult)
                }
            }
        }
        segmentationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
        self.requests = [segmentationRequest]
    }

    func processSegmentationRequest(_ observation: VNPixelBufferObservation) {
        let outPixelBuffer = observation.pixelBuffer
        let segMaskGray = CIImage(cvPixelBuffer: outPixelBuffer)
        // Further processing of the segmentation results...
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            print("Error performing request: \(error)")
        }
    }
}

#Preview {
    CameraView()
}
