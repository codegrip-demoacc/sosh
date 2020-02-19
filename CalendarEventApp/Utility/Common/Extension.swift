//
//  Extension.swift
//  CalendarEventApp
//
//  Created by Sun Pooh on 4/25/19.
//  Copyright © 2019 Sun Pooh. All rights reserved.
//

import Foundation 
import UIKit

public let kShapeDashed : String = "kShapeDashed"

extension Notification.Name {
    static let send_email = Notification.Name("send_email")
    static let add_activity = Notification.Name("add_activity")
    static let update_activity = Notification.Name("update_activity")
    static let delete_activity = Notification.Name("delete_activity")
    static let invite_list = Notification.Name("invite_list")
    static let add_logistic = Notification.Name("add_logistic")
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

public extension UIWindow {
    
    struct TransitionOptions {
        public enum Curve {
            case linear
            case easeIn
            case easeOut
            case easeInOut
            
            internal var function: CAMediaTimingFunction {
                let key: String!
                switch self {
                case .linear:        key = CAMediaTimingFunctionName.linear.rawValue
                case .easeIn:        key = CAMediaTimingFunctionName.easeIn.rawValue
                case .easeOut:        key = CAMediaTimingFunctionName.easeOut.rawValue
                case .easeInOut:    key = CAMediaTimingFunctionName.easeInEaseOut.rawValue
                }
                return CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: key!))
            }
        }
        public enum Direction {
            case fade
            case toTop
            case toBottom
            case toLeft
            case toRight
            
            internal func transition() -> CATransition {
                let transition = CATransition()
                transition.type = CATransitionType.push
                switch self {
                case .fade:
                    transition.type = CATransitionType.fade
                    transition.subtype = nil
                case .toLeft:
                    transition.subtype = CATransitionSubtype.fromLeft
                case .toRight:
                    transition.subtype = CATransitionSubtype.fromRight
                case .toTop:
                    transition.subtype = CATransitionSubtype.fromTop
                case .toBottom:
                    transition.subtype = CATransitionSubtype.fromBottom
                }
                return transition
            }
        }
        public enum Background {
            case solidColor(_: UIColor)
            case customView(_: UIView)
        }
        public var duration: TimeInterval = 0.20
        public var direction: TransitionOptions.Direction = .toRight
        public var style: TransitionOptions.Curve = .easeInOut
        public var background: TransitionOptions.Background? = nil
        public init(direction: TransitionOptions.Direction = .toRight, style: TransitionOptions.Curve = .linear) {
            self.direction = direction
            self.style = style
        }
        
        public init() { }
        internal var animation: CATransition {
            let transition = self.direction.transition()
            transition.duration = self.duration
            transition.timingFunction = self.style.function
            return transition
        }
    }
    
    func setRootViewController(_ controller: UIViewController, options: TransitionOptions = TransitionOptions()) -> UIViewController {
        
        var transitionWnd: UIWindow? = nil
        if let background = options.background {
            transitionWnd = UIWindow(frame: UIScreen.main.bounds)
            switch background {
            case .customView(let view):
                transitionWnd?.rootViewController = UIViewController.newController(withView: view, frame: transitionWnd!.bounds)
            case .solidColor(let color):
                transitionWnd?.backgroundColor = color
            }
            transitionWnd?.makeKeyAndVisible()
        }
        
        // Make animation
        self.layer.add(options.animation, forKey: kCATransition)
        
        let navigationController = UINavigationController.init(rootViewController: controller)
        navigationController.navigationBar.isTranslucent = false
        
        self.rootViewController = navigationController
        self.makeKeyAndVisible()
        
        if let wnd = transitionWnd {
            DispatchQueue.main.asyncAfter(deadline: (.now() + 0.3 + options.duration), execute: {
                wnd.removeFromSuperview()
            })
        }
        
        return controller
    }
}

internal extension UIViewController { 
    
    static func newController(withView view: UIView, frame: CGRect) -> UIViewController {
        view.frame = frame
        let controller = UIViewController()
        controller.view = view
        return controller
    }
}

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint: CGPoint {
        return points.startPoint
    }
    
    var endPoint: CGPoint {
        return points.endPoint
    }
    
    var points: GradientPoints {
        switch self {
        case .topRightBottomLeft:
            return (CGPoint.init(x: 0.0, y: 1.0), CGPoint.init(x: 1.0, y: 0.0))
        case .topLeftBottomRight:
            return (CGPoint.init(x: 0.0, y: 0.0), CGPoint.init(x: 1, y: 1))
        case .horizontal:
            return (CGPoint.init(x: 0.0, y: 0.5), CGPoint.init(x: 1.0, y: 0.5))
        case .vertical:
            return (CGPoint.init(x: 0.0, y: 0.0), CGPoint.init(x: 0.0, y: 1.0))
        }
    }
}

extension UIView {
    
    func applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.masksToBounds = false
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addGrdient (_ mainColor :[CGColor]){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = mainColor
        
        self.layer.addSublayer(gradientLayer)
    }
    
    func removeDashedBorder(_ view: UIView) {
        view.layer.sublayers?.forEach {
            if kShapeDashed == $0.name {
                $0.removeFromSuperlayer()
            }
        }
    }
    
    func addDashedBorder(width: CGFloat? = nil, height: CGFloat? = nil, lineWidth: CGFloat = 2, lineDashPattern:[NSNumber]? = [6,3], strokeColor: UIColor = UIColor.red, fillColor: UIColor = UIColor.clear) {
        
        
        var fWidth: CGFloat? = width
        var fHeight: CGFloat? = height
        
        if fWidth == nil {
            fWidth = self.frame.width
        }
        
        if fHeight == nil {
            fHeight = self.frame.height
        }
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        
        let shapeRect = CGRect(x: 0, y: 0, width: fWidth!, height: fHeight!)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: fWidth!/2, y: fHeight!/2)
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = lineDashPattern
        shapeLayer.name = kShapeDashed
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func setBottomCurve(_ height: Float) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        //        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: 0), radius: self.frame.size.width/2, startAngle: .pi, endAngle: 0, clockwise: false)
        path.addCurve(to: CGPoint(x: self.frame.width, y: 0), controlPoint1: CGPoint(x: self.frame.width/2, y: CGFloat(height)), controlPoint2: CGPoint(x: self.frame.width/2, y: CGFloat(height)))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.height))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        self.backgroundColor = UIColor.white
        self.layer.mask = shapeLayer
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    @IBInspectable var localizedPlaceholder: String {
        get {
            return ""
        }
        set {
            self.placeholder = newValue
        }
    }
    
    @IBInspectable var localizedText: String {
        get {
            return ""
        }
        set {
            self.text = newValue
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func cropImage(width: CGFloat, height: CGFloat) -> UIImage {
        let cgimage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
    func resizeImage(width: CGFloat, height: CGFloat) -> UIImage {
        let size = self.size
        
        let widthRatio  = width  / size.width
        let heightRatio = height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x:0, y:0, width:size.width, height:size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension CALayer {
    func addGradientBorder(colors:[UIColor],width:CGFloat = 1) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = colors.map({$0.cgColor})
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(rect: self.bounds).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        self.addSublayer(gradientLayer)
    }
}

extension String {
    func isValidEmailAddress() -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0 {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func widthOfString(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    //right is the first encountered string after left
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
            , leftRange.upperBound <= rightRange.lowerBound
            else { return nil }
        
        let sub = self[leftRange.upperBound...]
        let closestToLeftRange = sub.range(of: right)!
        return String(sub[..<closestToLeftRange.lowerBound])
    }
    
    var length: Int {
        get {
            return self.count
        }
    }
    
    func substring(to : Int) -> String {
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[...toIndex])
    }
    
    func substring(from : Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
        return String(self[indexRange])
    }
    
    func character(_ at: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: at)]
    }
    
    func lastIndexOfCharacter(_ c: Character) -> Int? {
        return range(of: String(c), options: .backwards)?.lowerBound.encodedOffset
    }
    
    func sum(_ str: String, under: Int) -> String {
        let float1: Float = Float(self)!
        let float2: Float = Float(str)!
        
        let sum = "\(float1 + float2)" as NSString
        let index = sum.range(of: ".").location
        
        return sum.substring(to: (index + under + 1))
    }

    //full month name and year
    func monthAndyear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: self)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: date)
        let year = self.substring(from: self.count-4)
        return month + " " + year
    }
    
    //short month and day
    func monthAndDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: self)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)
        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "dd"
        let day = formatterDay.string(from: date)
        return month + " " + day
    }
    
    
    //day, month, year
    func fullFormat() -> String {
        let monthAndDay = self.monthAndDay()
        let year = self.substring(from: self.count-4)
        return monthAndDay + " " + year
    }
    
    //get weekday
    func weekDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: self)!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let weekday = formatter.string(from: date)
        return weekday
    }
    
    //full weekday and short day
    func fullWeekday_month_day() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: self)!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)
        let monthAndDay = self.monthAndDay()
        return weekday + ", " + monthAndDay
    }
    
    //chatting history time
    
    func chatHistoryTime(_ format: String) -> String {
        let currentTime = Date()
        let formater = DateFormatter()
        formater.dateFormat = format
        let historyTime = formater.date(from: self)
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let diff_time = Calendar.current.dateComponents(components, from: historyTime!, to: currentTime)
        
        var str = ""
        if diff_time.year! == 0 {
            if diff_time.month! == 0 {
                if diff_time.day! == 0 {
                    if diff_time.hour! == 0 {
                        if diff_time.minute! == 0  {
                            if diff_time.second == 0 {
                                str = "just ago"
                            } else {
                                str = "less than a minute"
                            }
                        } else {
                            str = (diff_time.minute! == 1) ? "\(diff_time.minute!) minute ago" : "\(diff_time.minute!) minutes ago"
                        }
                    } else {
                        str = (diff_time.hour! == 1) ? "\(diff_time.hour!) hour ago" : "\(diff_time.hour!) hours ago"
                    }
                } else {
                    str = (diff_time.day! == 1) ? "\(diff_time.day!) day ago" : "\(diff_time.day!) days ago"
                }
            } else {
                str = (diff_time.month! == 1) ? "\(diff_time.month!) month ago" : "\(diff_time.month!) months ago"
            }
        } else {
            str = (diff_time.year! == 1) ? "\(diff_time.year!) year ago" : "\(diff_time.year!) years ago"
        }
        
        return str
    }
}

extension Date {
    func calculateDaysBetweenDates(date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: self) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: date) else {
            return 0
        }
        return end - start
    }
}

extension UIButton {
    func underlineMyText() {
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    func removeUnderLine() {
        let attrStr = self.attributedTitle(for: .normal) as? NSMutableAttributedString //or whatever the state you want
        attrStr?.enumerateAttributes(in: NSRange(location: 0, length: attrStr?.length ?? 0), options: .longestEffectiveRangeNotRequired, using: { attributes, range, stop in
            var mutableAttributes = attributes
            
            mutableAttributes.removeValue(forKey: .underlineStyle)
            attrStr?.setAttributes(mutableAttributes as? [NSAttributedString.Key : Any], range: range)
        })
    }
}

extension UICollectionView {
    
    func scrollToLast() {
        guard numberOfSections > 0 else {
            return
        }
        let lastSection = numberOfSections - 1
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: false)
    }
    
    func scrollToFirst() {
        
        guard numberOfSections > 0 else {
            return
        }
        let lastSection = numberOfSections - 1
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        let firstItemIndexPath = IndexPath(item: 0, section: lastSection)
        scrollToItem(at: firstItemIndexPath, at: .bottom, animated: true)
    }
    
    func scrollToIndex(index: Int) {
        
        guard numberOfSections > 0 else {
            return
        }
        let lastSection = numberOfSections - 1
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        let firstItemIndexPath = IndexPath(item: index, section: lastSection)
        scrollToItem(at: firstItemIndexPath, at: .left, animated: false)
    }
}

