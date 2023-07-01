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
    
    // Outlet - FIPE
    @IBOutlet weak var fipeMarcaLabel: UILabel!
    @IBOutlet weak var fipeModeloLabel: UILabel!
    @IBOutlet weak var fipeAnoLabel: UILabel!
    @IBOutlet weak var fipeCombustivelLabel: UILabel!
    @IBOutlet weak var fipeReferenciaLabel: UILabel!
    @IBOutlet weak var fipeCodigoLabel: UILabel!
    @IBOutlet weak var fipeValorLabel: UILabel!
    @IBOutlet weak var infoFipeView: UIView!
    
    // Properties
    var consultaPlacaResultado: ConsultaPlacaModel?
    var plateIsMercosul = false
    var plateTyped = ""
    var containFipe = false
    
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
        
        // FIPE View
        if carro.fipe?.dados.count == 0 {
            self.infoFipeView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.containFipe = false
        } else {
            guard let fipe = carro.fipe?.dados[0] else {
                self.infoFipeView.heightAnchor.constraint(equalToConstant: 0).isActive = true
                self.containFipe = false
                return
            }
            
            self.containFipe = true
            
            self.fipeMarcaLabel.attributedText = NSMutableAttributedString().boldCustom("Marca: ").normalCustom("\(fipe.texto_marca)")
            self.fipeModeloLabel.attributedText = NSMutableAttributedString().boldCustom("Modelo: ").normalCustom("\(fipe.texto_modelo)")
            self.fipeAnoLabel.attributedText = NSMutableAttributedString().boldCustom("Ano: ").normalCustom("\(fipe.ano_modelo)")
            self.fipeCombustivelLabel.attributedText = NSMutableAttributedString().boldCustom("Combustível: ").normalCustom("\(fipe.combustivel)")
            self.fipeReferenciaLabel.attributedText = NSMutableAttributedString().boldCustom("Referência: ").normalCustom("\(fipe.mes_referencia)")
            self.fipeCodigoLabel.attributedText = NSMutableAttributedString().boldCustom("Codigo: ").normalCustom("\(fipe.codigo_fipe)")
            self.fipeValorLabel.text = "\(fipe.texto_valor)"
            
            infoFipeView.clipsToBounds = true
            infoFipeView.layer.cornerRadius = 10
            infoFipeView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
            infoFipeView.layer.shadowRadius = 4
            infoFipeView.layer.shadowOffset = CGSize(width: 4, height: 6)
            infoFipeView.layer.shadowOpacity = 0.30
            infoFipeView.layer.masksToBounds = false
        }
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
              let endFrameWithoutFipe = dateLabel?.frame,
              let endFrameWithFipe = infoFipeView?.frame else { return }
        
        var endPoint = CGPoint()
        var printHeight: CGFloat = 0.0
        
        let startPoint = CGPoint(x: 0, y: contentView.frame.origin.y + startFrame.origin.y)
        let printWidth = scrollView.frame.size.width
        
        if self.containFipe {
            endPoint = CGPoint(x: scrollView.frame.size.width, y: contentView.frame.origin.y + endFrameWithFipe.maxY + 20)
            printHeight = endPoint.y - startPoint.y
        } else {
            endPoint = CGPoint(x: scrollView.frame.size.width, y: contentView.frame.origin.y + endFrameWithoutFipe.maxY + 20)
            printHeight = endPoint.y - startPoint.y
        }
         
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
