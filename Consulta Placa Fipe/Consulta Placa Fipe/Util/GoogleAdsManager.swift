//
//  GoogleAdsManager.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 23/05/23.
//

import Foundation
import GoogleMobileAds

public class GoogleAdsManager: NSObject, GADFullScreenContentDelegate {
    
    // MARK: - Properties
    public static var successCounter = 0
    public static let shared = GoogleAdsManager()
    var interstitial: GADInterstitialAd?
    
    private override init() {}
    
    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-9923132255263690/4537020851", request: request) { (ad, error) in
            if let error = error {
                print("Erro ao carregar anúncio intersticial: \(error.localizedDescription)")
            } else {
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                print("Anúncio intersticial carregado com sucesso!")
            }
        }
    }
    
    // Implemente os métodos do GADFullScreenContentDelegate
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad did fail to present full screen content.")
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }

    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
    }
}
