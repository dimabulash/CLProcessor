//
//  CLProcessor.swift
//
//
//  Created by Dima Bulash on 25/05/2023.
//

import Combine
import CoreML
import Lab
import UIKit

public struct ClProcessorService {
    public init() {}

    public struct LAB {
        public init(l: [NSNumber], a: [NSNumber], b: [NSNumber]) {
            self.l = l
            self.a = a
            self.b = b
        }
        public let l, a, b: [NSNumber]
    }

    public enum ClProcessorError: Swift.Error {
        case preprocessFailure
        case postprocessFailure
    }

    public enum Constants {
        public static let inputDimension = 256
        public static let inputSize = CGSize(width: inputDimension, height: inputDimension)
        public static let coremlInputShape = [1, 1, NSNumber(value: Constants.inputDimension), NSNumber(value: Constants.inputDimension)]
    }

    public static func preProcess(inputImg: UIImage) throws -> LAB {
        guard let lab = inputImg.resizedImage(with: Constants.inputSize)?.toLab() else {
            throw ClProcessorError.preprocessFailure
        }
        return LAB(l: lab[0], a: lab[1], b: lab[2])
    }

    public static func postProcess(outputLAB: LAB, inputImg: UIImage) throws -> UIImage {
        guard let resultImageLab = UIImage.image(from: [outputLAB.l, outputLAB.a, outputLAB.b], size: Constants.inputSize).resizedImage(with: inputImg.size)?.toLab(),
              let originalImageLab = inputImg.resizedImage(with: inputImg.size)?.toLab()
        else {
            throw ClProcessorError.postprocessFailure
        }
        return UIImage.image(from: [originalImageLab[0], resultImageLab[1], resultImageLab[2]], size: inputImg.size)
    }
}

private extension UIImage {
    func scaled(with dimension: CGFloat) -> UIImage {
        let width = self.size.width
        let height = self.size.height
        let aspectWidth = dimension / width
        let aspectHeight = dimension / height
        let scaleFactor = max(aspectWidth, aspectHeight)
        let size = CGSize(width: CGFloat(round(width * scaleFactor)), height: CGFloat(round(height * scaleFactor)))

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func resizedImage(with size: CGSize) -> UIImage? {
        guard let image = cgImage else { return nil }

        if image.colorSpace?.model == .rgb {
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * Int(size.width)
            let bitsPerComponent = 8
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: image.colorSpace!,
                                    bitmapInfo: 5)
            context?.interpolationQuality = .high
            context?.draw(image, in: CGRect(origin: .zero, size: size))

            guard let scaledImage = context?.makeImage() else { return nil }

            return UIImage(cgImage: scaledImage)
        } else if image.colorSpace?.model == .monochrome {
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: image.bitsPerComponent,
                                    bytesPerRow: Int(size.width),
                                    space: image.colorSpace!,
                                    bitmapInfo: 5)
            context?.interpolationQuality = .high
            context?.draw(image, in: CGRect(origin: .zero, size: size))

            guard let scaledImage = context?.makeImage() else { return nil }

            return UIImage(cgImage: scaledImage)
        } else {
            assertionFailure("The colorspace is not supported yet!")
            return nil
        }
    }
}
