//
//  CanvasView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/16/23.
//

import SwiftUI
import Vision
import Combine

struct Grid {
    public var points:CGPoint
    public var continuous:Bool
}

class Lines:ObservableObject {
    @Published public var coordinates:[Grid] = []
}

fileprivate extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        
        view?.bounds = CGRect(origin: CGPoint.zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct CanvasView: View {
    
    @ObservedObject private var line = Lines()
    @GestureState private var foo = CGPoint.zero
    @State private var image2G: Image = Image("256x256")
    @State private var newDigit: String = ""
    @State private var penDown = false
    @State private var requests = [VNRequest]()
    @State private var isOn = true
    
    var canvasView: some View {
        ZStack {
            Canvas { context, size in
                context.withCGContext { cgContext in
                    cgContext.setFillColor(UIColor.white.cgColor)
                    cgContext.fill(CGRect(origin: CGPoint.zero, size: size))
                    cgContext.setStrokeColor(UIColor.black.cgColor)
                    cgContext.setLineWidth(12)
                    if line.coordinates.count > 2 {
                        for p in 0..<line.coordinates.count {
                            if line.coordinates[p].continuous {
                                cgContext.move(to: line.coordinates[p-1].points)
                                cgContext.addLine(to: line.coordinates[p].points)
                                cgContext.addEllipse(in: CGRect(origin: line.coordinates[p].points, size: CGSize(width: 1, height: 1)))
                                cgContext.drawPath(using: .eoFillStroke)
                            } else {
                                cgContext.move(to: line.coordinates[p].points)
                            }
                        }
                    }
                }
            }
            .frame(width: 256, height: 256, alignment: .center)
            .ignoresSafeArea() // snapshot breaks if you don't include this tag
        }
    }
    
    fileprivate func showCanvas() -> some View {
        return canvasView
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .updating($foo) { value, state, transaction in
                    let rex = Grid(points: value.location, continuous: penDown)
                    line.coordinates.append(rex)
                    DispatchQueue.main.async {
                        penDown = true
                    }
                }
                .onEnded({ value in
                    let rex = Grid(points: value.location, continuous: true)
                    line.coordinates.append(rex)
                    DispatchQueue.main.async {
                        penDown = false
                    }
                }))
            .border(Color.blue)
    }
    
    fileprivate func clearCanvas() -> some View {
        return Text("clear")
            .font(.title)
            .onTapGesture {
                line.coordinates.removeAll()
                newDigit = ""
                isOn.toggle()
            }
    }
    
    fileprivate func showText() -> Text {
        return Text(newDigit)
            .font(.title)
    }
    
    fileprivate func showImage() -> some View {
        return image2G
            .resizable()
            .frame(width: 256, height: 256, alignment: .center)
            .border(Color.green)
    }
    
    var body: some View {
        VStack {
            clearCanvas()
            if isOn {
                showCanvas()
            } else {
                showImage()
            }
            processText()
            showText()
        }
    } // body
    
    fileprivate func handleClassification(request: VNRequest, error:Error?) {
        guard let observations = request.results else {print("nothing"); return}
        print(observations)
        let classification = observations
            .compactMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.8})
            .map({$0.identifier})
        
        if classification.first != nil {
            newDigit = "\(String(describing: classification.first!))"
        } else {
            newDigit = "?"
        }
    }
    
    fileprivate func processText() -> some View {
        return Text("recognize")
            .font(.title)
            .onTapGesture {
                let newImage = canvasView.snapshot()
                var uiImage:UIImage!
                
                (image2G,uiImage) = imageInNOut(image: newImage)
                //            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                isOn.toggle()
                
                guard let visionModel = try? VNCoreMLModel(for: MNISTClassifier().model) else {fatalError("failed")}
                let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassification)
                
                self.requests = [classificationRequest]
                                
                let formattedImage = uiImage.cgImage!
                let imageRequestHandler = VNImageRequestHandler(cgImage: formattedImage, options: [:])
                
                do {
                    try imageRequestHandler.perform(requests)
                } catch {
                    print("failed")
                }
            }
    }
    
    fileprivate func imageInNOut(image: UIImage) -> (Image,UIImage) {
        
        let height = Int((image.size.height))
        let width = Int((image.size.width))
        
        let bitsPerComponent = Int(8)
        let bytesPerRow = 4 * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: (width * height))
        
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        
        let CGPointZero = CGPoint(x: 0, y: 0)
        
        let rect = CGRect(origin: CGPointZero, size: (image.size))
        
        let imageContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        imageContext?.draw(image.cgImage!, in: rect)
        
        let pixels = UnsafeMutableBufferPointer<UInt32>(start: rawData, count: width * height)
        //       0xffff0000 = blue
        //       0xff00ff00 = green
        //       0xff0000ff = red
        
        var colors = [UInt32:UInt32]()
        var colors2 = [UInt32:UInt32]()
        
        for p in pixels.indices {
            let foo = pixels[p]
            if colors[foo] != nil {
                colors[foo]! += 1
            } else {
                colors[foo] = 0
            }
            
            //    pixels[p] = pixels[p] ^ 0x000000ff // Bitwise XOR
            // Swap black & white pixels
            pixels[p] = ~pixels[p] // Bitwise NOT [option n]
            pixels[p] = pixels[p] | 0xff000000 // Bitwise OR
            //    pixels[p] = pixels[p] & 0xff0000ff
            //    if pixels[p] < 0xff0000ff {
            //     pixels[p] = 0xffffffff // Change to white
            //      pixels[p] = 0xffff0000 // Change to blue
            //      pixels[p] = 0xff00ff00 // Change to green
            //    }
            let foo2 = pixels[p]
            if colors2[foo2] != nil {
                colors2[foo2]! += 1
            } else {
                colors2[foo2] = 0
            }
        }
        print("pixels ",pixels.count,colors.count,colors2.count)
        
        // draw a line across the center right to left
        //  for p in 32768..<32768 + 1024 {
        //    pixels[p] = 0xffffffff
        //  }
        //  // draw a line down the center top to bottom
        //  for q in stride(from: 128, to: 65536, by: 256) {
        //    for p in q..<q + 4 {
        //      pixels[p] = 0xffffffff
        //    }
        //  }
        
        let outContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent,bytesPerRow: bytesPerRow,space: colorSpace,bitmapInfo: bitmapInfo,releaseCallback: nil,releaseInfo: nil)
        
        let outImage = UIImage(cgImage: outContext!.makeImage()!)
        return (Image(uiImage: outImage),outImage)
    }
    
    
} // struct

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}
