//
//  LoadingScreen.swift
//  SS Book Store
//
//  Created by Soft Space User on 07/07/2021.
//

import Foundation
import Lottie

class LoadingScreen: NSObject {
    
    private var overlayView: UIView? = UIView()
    private var animationView = AnimationView()
    
    class var shared: LoadingScreen {
        struct Static {
            static let instance: LoadingScreen = LoadingScreen()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIViewController?, userInteract: Bool = false) {
       
        if(!animationView.isAnimationPlaying) {
            Util.runInMainThread {
                self.overlayView = UIView(frame: UIScreen.main.bounds)
                self.overlayView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                self.overlayView?.tag = 101

                self.animationView = AnimationView(name: "boxloading")
                let width = self.overlayView!.frame.width * 0.7
                self.animationView.frame = CGRect(x: 0.0, y: 0.0, width: width, height:  width)
                self.animationView.center = CGPoint(x: view!.view.bounds.width / 2.0, y: view!.view.bounds.height / 2.0)
                self.animationView.loopMode = .loop
                
                view?.view.addSubview(self.animationView)
                
                self.overlayView!.addSubview(self.animationView)
                
                view!.view.addSubview(self.overlayView!)
                self.animationView.play()
                
                if !userInteract {
                    print("User interact set to false")
                    view?.view.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    public func hideOverlay(view: UIViewController?) {
        Util.runInMainThread {
            self.overlayView!.isHidden = true
            if let subview = view?.view.viewWithTag(101) {
                subview.removeFromSuperview()
            } else {
                self.overlayView!.removeFromSuperview()
            }
            self.animationView.stop()
            view?.view.isUserInteractionEnabled = true
        }
    }
}
