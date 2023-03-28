//
//  SplashVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 24/03/23.
//

import Foundation
import UIKit
import Lottie

class SplashVC: UIViewController {

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
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController
        let navigationController = UINavigationController(rootViewController: vc)
        self.view.window?.rootViewController = navigationController
        vc.navigationController?.isNavigationBarHidden = true
        self.view.window?.makeKeyAndVisible()
    }
}
