//
//  AnnotationView.swift
//  IOSAccessAssessment
//
//  Created by Kohei Matsushima on 2024/03/29.
//

import SwiftUI
struct AnnotationView: View {
    @ObservedObject var sharedImageData: SharedImageData
    @State private var index = 0
    @State private var selectedIndex: Int? = nil
    @State private var isShowingCameraView = false
//    private var objectLocation = ObjectLocation()
    private var objectLocation: ObjectLocation
    var selection: [Int]
    var classes: [String]
    let options = ["I agree with this class annotation", "Annotation is missing some instances of the class", "The class annotation is misidentified"]
    
    // Adding an initializer with internal access level
    init(sharedImageData: SharedImageData, selection: [Int], classes: [String], objectLocation: ObjectLocation) {
        self.sharedImageData = sharedImageData
        self.selection = selection
        self.classes = classes
        self.objectLocation = objectLocation
    }
    
    var body: some View {
        if (isShowingCameraView == true || index >= selection.count) {
            ContentView(selection: Array(selection), classes: classes)
        } else {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
//                        if (index > 0) {
                            HostedAnnotationCameraViewController(sharedImageData: sharedImageData)
//                        HostedAnnotationCameraViewController(cameraImage: sharedImageData.cameraImage!, segmentationImage: sharedImageData.objectSegmentation!)
//                        } else {
//                            HostedAnnotationCameraViewController(cameraImage: sharedImageData.cameraImage!, segmentationImage: sharedImageData.segmentationImage!)
//                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("Selected class: \(classes[selection[index]])")
                        Spacer()
                    }
                    
                    ProgressBar(value: calculateProgress())
                    
                    HStack {
                        Spacer()
                        VStack {
                            ForEach(0..<options.count) { index in
                                Button(action: {
                                    // Toggle selection
                                    if selectedIndex == index {
                                        selectedIndex = nil
                                    } else {
                                        selectedIndex = index
                                    }
                                }) {
                                    Text(options[index])
                                        .padding()
                                        .foregroundColor(selectedIndex == index ? .red : .blue) // Change color based on selection
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    Button(action: {
                        objectLocation.calcLocation(sharedImageData: sharedImageData)
                        self.nextSegment()
                        selectedIndex = nil
                    }) {
                        Text("Next")
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Annotation View", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                // This action depends on how you manage navigation
                // For demonstration, this simply dismisses the view, but you need a different mechanism to navigate to CameraView
                self.isShowingCameraView = true;
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Camera View")
            })
            .padding()
        }
    }
    
    func nextSegment() {
//        print(index)
        index += 1
        if index >= (selection.count) {
            // Handle completion, save responses, or navigate to the next screen
            ContentView(selection: Array(selection), classes: classes)
        }
    }

    func calculateProgress() -> Float {
        return Float(index) / Float(selection.count)
    }
}

struct ProgressBar: View {
    var value: Float


    var body: some View {
        ProgressView(value: value)
            .progressViewStyle(LinearProgressViewStyle())
            .padding()
    }
}


class AnnotationCameraViewController: UIViewController {
    var cameraImage: UIImage?
    var segmentationImage: CIImage?
    var sharedImageData: SharedImageData?
    var cameraView: UIImageView? = nil
    var segmentationView: UIImageView? = nil
    
    init(sharedImageData: SharedImageData) {
        self.cameraImage = sharedImageData.cameraImage
        self.segmentationImage = sharedImageData.objectSegmentation
//        self.segmentationImage = sharedImageData.segmentationImage
//        self.segmentationImage = sharedImageData.depthDataImage
        self.sharedImageData = sharedImageData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView = UIImageView(image: cameraImage)
        let centerX = (view.bounds.width - 256.0) / 2.0;
        cameraView!.frame = CGRect(x: centerX, y: 0.0, width: 256.0, height: 256.0)
        cameraView!.contentMode = .scaleAspectFill
        view.addSubview(cameraView!)
        
        segmentationView = UIImageView(image: UIImage(ciImage: segmentationImage!, scale: 1.0, orientation: .downMirrored))
//        segmentationView = UIImageView(image: segmentationImage)
        segmentationView!.frame = CGRect(x: centerX, y: 0.0, width: 256.0, height: 256.0)
//        segmentationView!.frame = CGRect(x: centerX, y: 200.0, width: 200.0, height: 200.0)
        segmentationView!.contentMode = .scaleAspectFill
        view.addSubview(segmentationView!)
        cameraView!.bringSubviewToFront(segmentationView!)
//        segmentationView!.bringSubviewToFront(cameraView!)
    }
}

struct HostedAnnotationCameraViewController: UIViewControllerRepresentable{
//    var cameraImage: UIImage
//    var segmentationImage: UIImage
    var sharedImageData: SharedImageData
    
    func makeUIViewController(context: Context) -> AnnotationCameraViewController {
        return AnnotationCameraViewController(sharedImageData: sharedImageData)
    }
    
    func updateUIViewController(_ uiView: AnnotationCameraViewController, context: Context) {
    }
}
