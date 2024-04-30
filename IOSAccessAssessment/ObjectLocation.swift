import SwiftUI
import UIKit

struct ObjectLocation {
    @State private var image: UIImage? = nil

    func loadImage(with image: UIImage) {
        self.image = image
//        print("A")
        if let cgImage = self.image?.cgImage {
//            print("B")
            let width = cgImage.width
            let height = cgImage.height
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            let bitsPerComponent = 8

            // change pixel value
            let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//            print("C")
            if let data = context?.data?.assumingMemoryBound(to: UInt8.self) {
//                print("D")
                for i in stride(from: 0, to: width * height * bytesPerPixel, by: bytesPerPixel) {
                   // print the red pixel value
                    print("Red value of pixel \(i/bytesPerPixel): \(data[i])")
                }
            }
        } else {
            print("cgImage is nil")
        }
    }
}
