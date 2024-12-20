//
//  ResultadoConsultaPlacaVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 29/03/23.
//

import UIKit
import GoogleMobileAds

class ResultadoConsultaPlacaVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var situationlabel: UILabel?
    @IBOutlet weak var situationView: UIView?
    @IBOutlet weak var plateImage: UIImageView?
    @IBOutlet weak var plateLabel: UITextField?
    @IBOutlet weak var brandLabel: UILabel?
    @IBOutlet weak var modelLabel: UILabel?
    @IBOutlet weak var yearAndYearModelLabel: UILabel?
    @IBOutlet weak var chassiLabel: UILabel?
    @IBOutlet weak var colorLabel: UILabel?
    @IBOutlet weak var countyLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // Properties
    var consultaPlacaResultado: ConsultaPlacaModel?
    var plateIsMercosul = false
    var plateTyped = ""
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        validatePlateImage()
        validateSituationMessage()
        setupData()
        self.navigationItem.hidesBackButton = true
        
        DispatchQueue.main.async {
            if GoogleAdsManager.successCounter >= 2 {
                if let interstitial = GoogleAdsManager.shared.interstitial {
                    GoogleAdsManager.successCounter = 0
                    interstitial.present(fromRootViewController: self)
                    print("Anúncio PLACA - intersticial exibido com sucesso!")
                } else {
                    print("Anúncio PLACA - intersticial não está pronto ainda.")
                }
            }
        }
        
    }
    
    // MARK: - Methods
    func setupData() {
        guard let carro = consultaPlacaResultado else { return }
        self.plateLabel?.text = plateTyped
        self.plateLabel?.isUserInteractionEnabled = false
        self.situationlabel?.text = "\(carro.situacao)"
        self.brandLabel?.attributedText = NSMutableAttributedString().bold("Marca: ").normal("\(carro.marca)")
        self.modelLabel?.attributedText = NSMutableAttributedString().bold("Modelo: ").normal("\(carro.modelo)")
        self.yearAndYearModelLabel?.attributedText = NSMutableAttributedString().bold("Ano/Modelo: ").normal("\(carro.ano)/\(carro.anoModelo)")
        self.chassiLabel?.attributedText = NSMutableAttributedString().bold("Chassi: ").normal("\(carro.chassi)")
        self.colorLabel?.attributedText = NSMutableAttributedString().bold("Cor: ").normal("\(carro.cor)")
        self.countyLabel?.attributedText = NSMutableAttributedString().bold("Cidade: ").normal("\(carro.municipio) - \(carro.uf)")
        self.dateLabel?.attributedText = NSMutableAttributedString().bold("Data da consulta: ").normal("\(carro.data)")
    }
    
    func validatePlateImage() {
        if plateIsMercosul {
            self.plateImage?.image = UIImage(named: "mercosulPlate")
        } else {
            self.plateImage?.image = UIImage(named: "oldPlate")
        }
    }
    
    func validateSituationMessage() {
        guard let carro = consultaPlacaResultado else { return }
        
        if carro.situacao.contains("Roubo") || carro.situacao.contains("Furto") {
            self.situationView?.backgroundColor = .cpRedHelper
        } else {
            self.situationView?.backgroundColor = .cpPrimaryMain
        }
    }
    
    // MARK: - Actions
    @IBAction func newQuery(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        guard let scrollView = scrollView,
              let contentView = scrollView.subviews.first,
              let startFrame = situationlabel?.frame,
              let endFrame = dateLabel?.frame else { return }
        
        let startPoint = CGPoint(x: 0, y: contentView.frame.origin.y + startFrame.origin.y)
        let endPoint = CGPoint(x: scrollView.frame.size.width, y: contentView.frame.origin.y + endFrame.maxY + 20)
        
        let printWidth = scrollView.frame.size.width
        let printHeight = endPoint.y - startPoint.y
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: printWidth, height: printHeight), false, 0.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: -startPoint.x, y: -startPoint.y)
            contentView.layer.render(in: context)
            
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let image = capturedImage {
                let objectsToShare = [image] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}
