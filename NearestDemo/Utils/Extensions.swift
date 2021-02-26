//
//  Extensions.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import Foundation
import UIKit
extension String {
    ///this attribute return a localized version of the string based on the key
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UIView {
    ///this function sets rounded corners for the view
    /// - Parameters:
    /// - cornerRadius: `CGFloat` the radius in which the view's corners should be curved
    func setRoundedCorners(cornerRadius:CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
    
    ///this function sets circled corners for the view
    func setCircledCorners() {
        setRoundedCorners(cornerRadius: self.frame.size.width * 0.5)
    }
    
    ///this function shakes the view horizontally for 0.6 seconds
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.0, 2.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension UITextField {
    ///this function shakes the view horizontally and shows a red place holder inside the text field
    func showRedAlertAndShake() {
        self.text = ""
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "D0021B")!])
        shake()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Your code with delay
            generator.impactOccurred()
        }
    }
    ///this function checks if the text inside the text field is empty or not
    func isTextFieldEmptyWithNoWhiteSpaces()->Bool {
        if let text = self.text {
            return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }
}
extension Dictionary where Key == String {
    ///this function checks if the dictionary has a certain key in it or not
    /// - Parameters:
    /// - key: `String` the key to check for
    func hasKey(key:String)-> Bool{
        return self[key] != nil
    }
}

extension UIColor {
    ///this attribute returns the hex value of the color as a String
    var toHex: String? {
        // Extract Components
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        // Helpers
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        // Create Hex String
        let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        
        return hex
    }
    
    ///this init function takes the color value as a hex String and initializes a UIColor object with its value
    /// - Parameters:
    /// - hex: `String` the color value in Hexadecimal String. eg: #FFFFFF
    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")
        
        // Helpers
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.count
        
        // Create Scanner
        Scanner(string: hexNormalized).scanHexInt64(&rgb)
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
