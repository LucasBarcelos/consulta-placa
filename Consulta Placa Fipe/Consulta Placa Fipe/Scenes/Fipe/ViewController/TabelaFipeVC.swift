//
//  TabelaFipeVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import UIKit
import Reachability

class TabelaFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectionLabel: UILabel!
    
    // MARK: - Properties
    var vehicles:[VehicleTypeModel] = [VehicleTypeModel(type: "Carro", typeImage: "carIcon"),
                                  VehicleTypeModel(type: "Moto", typeImage: "motorbikeIcon"),
                                  VehicleTypeModel(type: "Caminhão", typeImage: "truckIcon")]
    private let tabelaFipeViewModel: TabelaFipeViewModel = TabelaFipeViewModel(serviceAPI: FipeBrandsAPI())
    var vehicleTypeSelected = 0
    var alert: AlertController?
    let reachability = try! Reachability()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alert = AlertController(controller: self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tabelaFipeViewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        GoogleAdsManager.shared.loadInterstitialAd()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        print("Notification Removida - Consulta FIPE")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MarcasFipeVC") {
            let vc = segue.destination as! MarcasFipeVC
            guard let result = sender as? [GenericFipeModel] else { return }
            vc.brands = result
            vc.vehicleTypeSelected = self.vehicleTypeSelected
        }
    }
    
    // MARK: - Methods
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via WiFi - Consulta FIPE")
        case .cellular:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via Cellular - Consulta FIPE")
        case .unavailable:
            self.tableView.isUserInteractionEnabled = false
            self.connectionLabel.text = "Sem conexão"
            print("Sem conexão - Consulta FIPE")
        }
    }
}

// MARK: - Extension
extension TabelaFipeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.vehicles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:TabelaFipeVeiculoCell? = tableView.dequeueReusableCell(withIdentifier: TabelaFipeVeiculoCell.identifier, for: indexPath) as? TabelaFipeVeiculoCell
        
        cell?.setupCell(data: self.vehicles[indexPath.section])
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 16))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tipo de veículo selecionado: \(indexPath.section + 1)")
        self.vehicleTypeSelected = indexPath.section + 1
        DispatchQueue.main.async {
            AnimationLoading.start()
            self.tabelaFipeViewModel.serviceAPI?.fetchBrands(vehicleType: indexPath.section + 1)
        }
    }
}

extension TabelaFipeVC: TabelaFipeViewModelProtocol {
    func successGoToResult(brands: [GenericFipeModel]?) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.performSegue(withIdentifier: "MarcasFipeVC", sender: brands)
        }
    }
    
    func erroFetch(message: String) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.alert?.alertInformation(title: "Atenção", message: "Estamos enfrentando uma indisponibilidade do serviço no momento, por favor, tente novamente em alguns instantes!")
        }
    }
}


