//
//  Util.swift
//  SS Book Store
//
//  Created by Soft Space User on 30/06/2021.
//

import Foundation
import UIKit

public class Util {
    static func runInMainThread(execute: @escaping (() -> Void)) {
        if Thread.isMainThread {
            execute()
        }
        else {
            DispatchQueue.main.async(execute: {
                execute()
            })
        }
    }
    
    static func delayFunc(delaySec: Double = 0.5, execute: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec, execute: {
            execute()
        })
    }
    
    static func convertBase64StringToImage(imageBase64String: String) -> UIImage {
        if let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0)),
           let image = UIImage(data: imageData) {
            
            return image
        }
        return UIImage(systemName: "nosign")!
    }
    
    static func convertToDate(_ string: String, fromFormat stringFormat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = stringFormat
        let date = dateFormatter.date(from: string) ?? Date()
        return date
    }
    
    // MARK: - UI
    
    static func formAlertAction(title: String, style: UIAlertAction.Style, handlerAction: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handlerAction)
    }
}

// MARK: - CustomKeyboardDelegate

@objc public protocol CustomKeyboardDelegate {
    func keyboardWillShow(keyboardEndFrame: CGRect, scrollView: UIScrollView)
    func keyboardWillHide(keyboardEndFrame: CGRect, scrollView: UIScrollView)
}

// MARK: - Extension UIViewController

extension UIViewController {
    // MARK: - Keyboard related
    
    private static var keyboardRelatedScrollViewList = [String : UIScrollView]()
    private static var keyboardRelatedScrollViewContentInsetList = [String : UIEdgeInsets]()
    private static var keyboardRelatedScrollViewScrollIndicatorInsetsList = [String : UIEdgeInsets]()
    private static var keyboardDelegateList = [String : CustomKeyboardDelegate]()
    private var keyboardRelatedScrollView: UIScrollView? {
        get {
            return UIViewController.keyboardRelatedScrollViewList[self.description]
        }
        set {
            if let newScrollView = newValue {
                UIViewController.keyboardRelatedScrollViewList.updateValue(newScrollView, forKey: self.description)
            }
            else {
                UIViewController.keyboardRelatedScrollViewList.removeValue(forKey: self.description)
            }
        }
    }
    
    private var keyboardRelatedScrollViewContentInset: UIEdgeInsets? {
        get {
            return UIViewController.keyboardRelatedScrollViewContentInsetList["\(self.description)_contentinset"]
        }
        set {
            if let newContentInset = newValue {
                UIViewController.keyboardRelatedScrollViewContentInsetList.updateValue(newContentInset, forKey: "\(self.description)_contentinset")
            }
            else {
                UIViewController.keyboardRelatedScrollViewContentInsetList.removeValue(forKey: "\(self.description)_contentinset")
            }
        }
    }
    
    private var keyboardRelatedScrollViewScrollIndicatorInsets: UIEdgeInsets? {
        get {
            return UIViewController.keyboardRelatedScrollViewScrollIndicatorInsetsList["\(self.description)_scrollindicatorinsets"]
        }
        set {
            if let newScrollIndicatorInsets = newValue {
                UIViewController.keyboardRelatedScrollViewScrollIndicatorInsetsList.updateValue(newScrollIndicatorInsets, forKey: "\(self.description)_scrollindicatorinsets")
            }
            else {
                UIViewController.keyboardRelatedScrollViewScrollIndicatorInsetsList.removeValue(forKey: "\(self.description)_scrollindicatorinsets")
            }
        }
    }
    
    private weak var keyboardDelegate: CustomKeyboardDelegate? {
        get {
            return UIViewController.keyboardDelegateList["\(self.description)_keyboarddelegate"]
        }
        set {
            if let newScrollIndicatorInsets = newValue {
                UIViewController.keyboardDelegateList.updateValue(newScrollIndicatorInsets, forKey: "\(self.description)_keyboarddelegate")
            }
            else {
                UIViewController.keyboardDelegateList.removeValue(forKey: "\(self.description)_keyboarddelegate")
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardInfo = notification.userInfo,
            let keyboardFrameCGRect = (keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if #available(iOS 11.0, *) {
                if let krScrollView = keyboardRelatedScrollView,
                    krScrollView.contentInsetAdjustmentBehavior == .never {
                    
                    if (keyboardRelatedScrollViewContentInset == nil) {
                        keyboardRelatedScrollViewContentInset = krScrollView.contentInset
                    }
                    
                    if (keyboardRelatedScrollViewScrollIndicatorInsets == nil) {
                        keyboardRelatedScrollViewScrollIndicatorInsets = krScrollView.scrollIndicatorInsets
                    }
                    
                    krScrollView.contentInset.bottom = keyboardRelatedScrollViewContentInset!.bottom + keyboardFrameCGRect.height
                    krScrollView.scrollIndicatorInsets.bottom = keyboardRelatedScrollViewScrollIndicatorInsets!.bottom + keyboardFrameCGRect.height
                } else {
                    let safeAreaInsetsBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
                    
                    if (keyboardRelatedScrollViewContentInset == nil) {
                        keyboardRelatedScrollViewContentInset = additionalSafeAreaInsets
                    }
                    
                    additionalSafeAreaInsets.bottom = keyboardRelatedScrollViewContentInset!.bottom + keyboardFrameCGRect.height - safeAreaInsetsBottom
                }
            } else { // below iOS 11.0
                if let krScrollView = keyboardRelatedScrollView {
                    if (keyboardRelatedScrollViewContentInset == nil) {
                        keyboardRelatedScrollViewContentInset = krScrollView.contentInset
                    }
                    
                    if (keyboardRelatedScrollViewScrollIndicatorInsets == nil) {
                        keyboardRelatedScrollViewScrollIndicatorInsets = krScrollView.scrollIndicatorInsets
                    }
                    
                    krScrollView.contentInset.bottom = keyboardRelatedScrollViewContentInset!.bottom + keyboardFrameCGRect.height
                    krScrollView.scrollIndicatorInsets.bottom = keyboardRelatedScrollViewScrollIndicatorInsets!.bottom + keyboardFrameCGRect.height
                }
            }
            
            if let krScrollView = keyboardRelatedScrollView {
                keyboardDelegate?.keyboardWillShow(keyboardEndFrame: keyboardFrameCGRect, scrollView: krScrollView)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let previousContentInset = keyboardRelatedScrollViewContentInset {
            if #available(iOS 11.0, *) {
                if let krScrollView = keyboardRelatedScrollView,
                    krScrollView.contentInsetAdjustmentBehavior == .never {
                    krScrollView.contentInset = previousContentInset
                    
                    if let previousScrollIndicatorInsets = keyboardRelatedScrollViewScrollIndicatorInsets {
                        krScrollView.scrollIndicatorInsets = previousScrollIndicatorInsets
                    }
                }
                else {
                    additionalSafeAreaInsets = previousContentInset
                }
            } else { // below iOS 11.0
                if let krScrollView = keyboardRelatedScrollView {
                    krScrollView.contentInset = previousContentInset
                    
                    if let previousScrollIndicatorInsets = keyboardRelatedScrollViewScrollIndicatorInsets {
                        krScrollView.scrollIndicatorInsets = previousScrollIndicatorInsets
                    }
                }
            }
            
            keyboardRelatedScrollViewContentInset = nil
        }
        
        if let krScrollView = keyboardRelatedScrollView,
            let keyboardInfo: [AnyHashable : Any] = notification.userInfo,
            let keyboardFrameCGRect = (keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardDelegate?.keyboardWillHide(keyboardEndFrame: keyboardFrameCGRect, scrollView: krScrollView)
        }
    }
    
    @objc public func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
    public func enableHideKeyboardByTappingBackground(cancelsTouchesInView: Bool = true) {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tapGR.cancelsTouchesInView = cancelsTouchesInView
        self.view.addGestureRecognizer(tapGR)
    }
    
    public func addKeyboardDisplayNotifications(scrollView: UIScrollView, delegate: CustomKeyboardDelegate? = nil) {
        keyboardRelatedScrollView = scrollView
        keyboardDelegate = delegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Remove keyboardWillShowNotification & keyboardWillHideNotification
    public func removeKeyboardDisplayNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        keyboardRelatedScrollView = nil
        keyboardRelatedScrollViewContentInset = nil
        keyboardRelatedScrollViewScrollIndicatorInsets = nil
        keyboardDelegate = nil
    }
    
    // MARK: - Alert dialogue related
    
    public func showAlertDialog(style: UIAlertController.Style = .alert, title: String? = nil, message: String?, alertActions: [UIAlertAction]) {
        if Thread.isMainThread {
            showAlertController(style: style, title: title, message: message, alertActions: alertActions)
        }
        else {
            DispatchQueue.main.async {
                self.showAlertController(style: style, title: title, message: message, alertActions: alertActions)
            }
        }
    }
    
    public func showAlertController(style: UIAlertController.Style = .alert, title: String? = nil, message: String?, alertActions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for alertAction: UIAlertAction in alertActions {
            alertController.addAction(alertAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extension UIImage

public extension UIImage {
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

// MARK: - Extension UIBarButtonItem

extension UIBarButtonItem {

    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true

        return menuBarItem
    }
}
