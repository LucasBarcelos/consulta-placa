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
    @IBOutlet weak var infoFipeCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // Properties
    var consultaPlacaResultado: ConsultaPlacaModel?
    var plateIsMercosul = false
    var plateTyped = ""
    var containFipe = false
    let cellPercentWidth: CGFloat = 0.8
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        validatePlateImage()
        validateSituationMessage()
        setupData()
        incrementAppRuns()
        
        // Delegates
        infoFipeCollectionView.delegate = self
        infoFipeCollectionView.dataSource = self
        
        self.navigationItem.hidesBackButton = true
        
        //Google Ads Mobile
        DispatchQueue.main.async {
            if GoogleAdsManager.successCounter >= 2 {
                if let interstitial = GoogleAdsManager.shared.interstitial {
                    GoogleAdsManager.successCounter = 0
                    interstitial.present(from: self)
                    print("Anúncio PLACA - intersticial exibido com sucesso!")
                } else {
                    print("Anúncio PLACA - intersticial não está pronto ainda.")
                }
            } else {
                showReview()
            }
        }
    }
    
    // MARK: - Methods
    func setupCollectionView() {
        // Configurar o Page Control
        pageControl.numberOfPages = consultaPlacaResultado?.fipe?.dados.count ?? 0
        
        // Get the reference to the CenteredCollectionViewFlowLayout (REQURED)
        centeredCollectionViewFlowLayout = (infoFipeCollectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)

        // Modify the collectionView's decelerationRate (REQURED)
        infoFipeCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        // Configure the required item size (REQURED)
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * cellPercentWidth,
            height: 230
        )

        // Configure the optional inter item spacing (OPTIONAL)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 16
    }
    
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
            self.infoFipeCollectionView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.pageControl.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.pageControl.isHidden = true
            self.containFipe = false
        } else {
            self.containFipe = true
            setupCollectionView()
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
              let endFrameWithFipe = infoFipeCollectionView?.frame else { return }
        
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

extension ResultadoConsultaPlacaVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return consultaPlacaResultado?.fipe?.dados.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlacaFipeCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        
        guard let item = consultaPlacaResultado?.fipe?.dados[indexPath.row] else { return cell }
        
        
        cell.displayInformations(marca: item.texto_modelo, modelo: item.texto_marca, ano: item.ano_modelo, combustivel: item.combustivel, referencia: item.mes_referencia, codigo: item.codigo_fipe, valor: item.texto_valor)
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        guard let index = centeredCollectionViewFlowLayout.currentCenteredPage else { return }
        
        print("Current centered index: \(index)")
        
        self.pageControl.currentPage = index
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let index = centeredCollectionViewFlowLayout.currentCenteredPage else { return }
        
        print("Current centered index: \(index)")
    }
}
