//
//  AnimationLoading.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 18/01/23.
//

import UIKit
import Lottie

public class AnimationLoading: UIView {

    // MARK: - Enum
    public enum LoadingStatus: Int {
        case stopped = 0
        case running
    }

    // MARK: - Properties
    private var loadingStatus: LoadingStatus = .stopped
    public static let shared = AnimationLoading()
    private var timeoutTimer: Timer?
    private var presenterView: UIView?
    
    lazy var activity: LottieAnimationView = {
        let activity = LottieAnimationView(name: "loading_car_white")
        activity.contentMode = .scaleAspectFit
        activity.loopMode = .loop
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.clipsToBounds = true
        activity.layer.cornerRadius = 10
        activity.backgroundColor = .cpGrey4Aux
        return activity
    }()
    
    // MARK: - Inits
    public convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    public convenience init(in view: UIView) {
        self.init(frame: view.bounds)
        self.presenterView = view
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        self.init(frame: UIScreen.main.bounds)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.addSubview(self.activity)
        self.setUpConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAppTimeout), name: Notification.Name("AppTimeOut"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Constraints
    private func setUpConstraints() {
        var sizeAnimation: CGFloat = 0
        
        switch UIDevice().screenType {
        case .small:
            sizeAnimation = 200
        case .medium:
            sizeAnimation = 250
        case .large:
            sizeAnimation = 300
        }
        
        
        NSLayoutConstraint.activate([
            // animation
            self.activity.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            self.activity.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            self.activity.heightAnchor.constraint(equalToConstant: sizeAnimation),
            self.activity.widthAnchor.constraint(equalToConstant: sizeAnimation)
        ])
    }
            
    
    // MARK: - Methods
    @objc func onAppTimeout(notification: NSNotification) {
        self.closeTimeOut()
    }
    
    public func open() {
        scheduleTimeoutVerify()
        self.loadingStatus = .running
        self.activity.play()
        self.activity.center = self.center
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.addSubview(self)
    }
    
    public func close() {
        stopScheduledTimeoutVerify()
        
        self.loadingStatus = .stopped
        self.activity.stop()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        super.superview?.layer.add(transition, forKey: CATransitionType.fade.rawValue)
        self.removeFromSuperview()
    }
    
    public func closeTimeOut() {
        stopScheduledTimeoutVerify()
        
        self.loadingStatus = .stopped
        self.activity.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.fade
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            super.superview?.layer.add(transition, forKey: CATransitionType.fade.rawValue)
            self.removeFromSuperview()
            
            let alertController = UIAlertController(title: "Atenção", message: "Estamos enfrentando uma indisponibilidade do serviço no momento, por favor, tente novamente em alguns instantes!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            if let presenterView = self.presenterView {
                presenterView.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            } else {
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    public static func status() -> LoadingStatus {
        return self.shared.loadingStatus
    }
    
    public static func start() {
        self.shared.open()
    }
    
    public static func stop() {
        self.shared.close()
    }
    
    // MARK: - Timeout
    func scheduleTimeoutVerify() {
        timeoutTimer = Timer.scheduledTimer(timeInterval: 35,
                                            target: self,
                                            selector: #selector(timeoutVerify(_:)),
                                            userInfo: Int(Date().timeIntervalSince1970),
                                            repeats: false)
    }
    
    func stopScheduledTimeoutVerify() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    @objc func timeoutVerify(_ timer:Timer) {
        if loadingStatus == .running && isSameTimer(timer, to: timeoutTimer) {
            NotificationCenter.default.post(name: Notification.Name("AppTimeOut"), object: nil)
        }
    }
    
    func isSameTimer(_ timer: Timer?, to timer2:Timer?) -> Bool {
        guard let timer1 = timer, let timer2 = timer2 else { return false }
        guard let info1 = timer1.userInfo as? Int,
              let info2 = timer2.userInfo as? Int else { return false }
        return info1 == info2
    }
}
