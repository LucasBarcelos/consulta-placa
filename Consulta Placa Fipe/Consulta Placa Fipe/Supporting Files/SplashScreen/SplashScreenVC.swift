//
//  SplashScreenVC.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 17/01/23.
//

import Foundation
import UIKit
import Lottie

class SplashScreenVC: UIViewController {

    // Properties
    private let animationView: LottieAnimationView = {
        let lottieAnimationView = LottieAnimationView(name: "splashScreen")
        return lottieAnimationView
    }()
    
    // View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(animationView)
        
        animationView.contentMode = .scaleAspectFit
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = view.center
        animationView.alpha = 1
        animationView.backgroundColor = .cpBlackText
        
        animationView.play { _ in
            UIView.animate(withDuration: 0.4, animations: {
                self.animationView.alpha = 0
            }, completion: { _ in
                self.animationView.isHidden = true
                self.animationView.removeFromSuperview()
                self.startApp()
            })
        }
    }
    
    // Methods
    func startApp() {
        let vc:MenuTabBarController = MenuTabBarController()
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
}
