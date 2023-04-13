//
//  MarcasVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import UIKit
import Reachability

class MarcasFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectionLabel: UILabel!
    
    // MARK: - Properties
    var brands: [GenericFipeModel] = []
    private let marcasFipeViewModel: MarcasFipeViewModel = MarcasFipeViewModel(serviceAPI: FipeModelsAPI())
    var vehicleTypeSelected = 0
    var brandCodeSelected = 0
    var alert: AlertController?
    let reachability = try! Reachability()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.marcasFipeViewModel.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        print("Notification Removida - Consulta MARCAS FIPE")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ModelosFipeVC") {
            let vc = segue.destination as! ModelosFipeVC
            guard let result = sender as? VehicleModelsModel else { return }
            vc.models = result
            vc.vehicleTypeSelected = self.vehicleTypeSelected
            vc.brandCodeSelected = self.brandCodeSelected
        }
    }
    
    // MARK: - Methods
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via WiFi - Consulta MARCAS FIPE")
        case .cellular:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via Cellular - Consulta MARCAS FIPE")
        case .unavailable:
            self.tableView.isUserInteractionEnabled = false
            self.connectionLabel.text = "Sem conexão"
            print("Sem conexão - Consulta MARCAS FIPE")
        }
    }
}

// MARK: - Extension
extension MarcasFipeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.brands.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:TabelaFipeGenericCell? = tableView.dequeueReusableCell(withIdentifier: TabelaFipeGenericCell.identifier, for: indexPath) as? TabelaFipeGenericCell

        cell?.setupCell(data: self.brands[indexPath.section])
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
        print("Marca selecionado: \(brands[indexPath.section].label) - Código da Marca: \(brands[indexPath.section].value)")
        guard let brandCode = Int(brands[indexPath.section].value) else { return }
        self.brandCodeSelected = brandCode
        DispatchQueue.main.async {
            AnimationLoading.start()
            self.marcasFipeViewModel.serviceAPI?.fetchModels(vehicleType: self.vehicleTypeSelected, brandCode: brandCode)
        }
    }
}

extension MarcasFipeVC: MarcasFipeViewModelProtocol {
    func successGoToResult(models: VehicleModelsModel?) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.performSegue(withIdentifier: "ModelosFipeVC", sender: models)
        }
    }
    
    func erroFetch(message: String) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.alert?.alertInformation(title: "Atenção", message: message)
        }
    }
}
