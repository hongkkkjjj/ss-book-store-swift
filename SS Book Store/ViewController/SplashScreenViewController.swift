//
//  SplashScreenViewController.swift
//  SS Book Store
//
//  Created by Soft Space User on 29/06/2021.
//

import UIKit
import Lottie

class SplashScreenViewController: UIViewController {
    
    @IBOutlet private weak var animationContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Util.delayFunc(delaySec: 3.0, execute: {
            if UserDefaultUtil.isUserLogin {
                self.goToMainScreen()
            } else {
                self.goToLoginScreen()
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        setupLottieAnimation()
    }

    private func setupLottieAnimation() {
        var animationView = AnimationView()
        animationContainerView.layer.cornerRadius = 10
        
        if(!animationView.isAnimationPlaying) {
            Util.runInMainThread {

                animationView = AnimationView(name: "boxloading")
                animationView.frame = self.animationContainerView.frame
                animationView.frame = CGRect(x: 0.0, y: 0.0, width: animationView.frame.width, height:  animationView.frame.height)
                animationView.loopMode = .loop
                
                self.animationContainerView.addSubview(animationView)
                animationView.play()
            }
        }
    }
    
    private func goToLoginScreen() {
        self.performSegue(withIdentifier: StoryboardSegue.splashToLogin, sender: nil)
    }
    
    private func goToMainScreen() {
        self.performSegue(withIdentifier: StoryboardSegue.splashToMain, sender: nil)
    }
}
