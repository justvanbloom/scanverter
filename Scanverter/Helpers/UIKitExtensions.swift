import Foundation
import UIKit
import AVFoundation
import CoreGraphics
import PDFKit


extension Date {
    var toString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    var toFileNameString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: self)
    }
    
    var toHumanReadableTimeAgo: String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
//        let year = month * 12
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
}

extension CameraService {
    enum LivePhotoMode {
        case on
        case off
    }
    
    enum DepthDataDeliveryMode {
        case on
        case off
    }
    
    enum PortraitEffectsMatteDeliveryMode {
        case on
        case off
    }
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions = [AVCaptureDevice.Position]()
        
        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        
        return uniqueDevicePositions.count
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func themeColor() -> UIColor {
        return rgb(red: 96, green: 111, blue: 199)
    }
    static func themeLightPurple() -> UIColor {
        return rgb(red: 227, green: 208, blue: 255)
    }
    static func themePurple() -> UIColor {
        return rgb(red: 156, green: 106, blue: 222)
    }
    static func themePurpleDark() -> UIColor {
        return rgb(red: 80, green: 36, blue: 143)
    }
    static func themePurpleDarker() -> UIColor {
        return rgb(red: 35, green: 0, blue: 81)
    }
    static func themeLightIndigo() -> UIColor {
        return rgb(red: 179, green: 188, blue: 245)
    }
    static func themeIndigo() -> UIColor {
        return rgb(red: 92, green: 106, blue: 196)
    }
    static func themeIndigoDark() -> UIColor {
        return rgb(red: 32, green: 46, blue: 120)
    }
    static func themeIndigoDarker() -> UIColor {
        return rgb(red: 0, green: 6, blue: 57)
    }
    static func seperatorColor() -> UIColor {
        return rgb(red: 240, green: 240, blue: 240)
    }
    static func dividerLineColor() -> UIColor {
        return rgb(red: 204, green: 204, blue: 204)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}

extension Array where Element: UIImage {
      func makePDF()-> PDFDocument? {
        let pdfDocument = PDFDocument()
        for (index,image) in self.enumerated() {
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: index)
        }
        return pdfDocument
    }
}

extension UIImage{
    func resize(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

extension UIDevice {
    static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}

public struct Safe<Base: Decodable>: Decodable {
    public let value: Base?
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
            self.value = nil
        }
    }
}

extension KeyedDecodingContainer {
    public func decodeSafely<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        return self.decodeSafely(T.self, forKey: key)
    }
    
    public func decodeSafely<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        let decoded = try? decode(Safe<T>.self, forKey: key)
        return decoded?.value
    }
    
    public func decodeSafelyIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        return self.decodeSafelyIfPresent(T.self, forKey: key)
    }
    
    public func decodeSafelyIfPresent<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        let decoded = try? decodeIfPresent(Safe<T>.self, forKey: key)
        return decoded?.value
    }
    
    public func decodeSafelyArray<T: Decodable>(of type: T.Type, forKey key: KeyedDecodingContainer.Key) -> [T] {
        let array = decodeSafely([Safe<T>].self, forKey: key)
        return array?.compactMap { $0.value } ?? []
    }
}

