//
//  ModelosFipeVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import UIKit

class ModelosFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var models: VehicleModelsModel?
    private let anoModeloFipeViewModel: AnoModeloFipeViewModel = AnoModeloFipeViewModel(serviceAPI: FipeYearModelAPI())
    var vehicleTypeSelected = 0
    var brandCodeSelected = 0
    var modelCodeSelected = 0
    var alert: AlertController?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.anoModeloFipeViewModel.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AnoFipeVC") {
            let vc = segue.destination as! AnoFipeVC
            guard let result = sender as? [GenericFipeModel] else { return }
            vc.yearModel = result
            vc.vehicleTypeSelected = self.vehicleTypeSelected
            vc.brandCodeSelected = self.brandCodeSelected
            vc.modelCodeSelected = self.modelCodeSelected
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
}

// MARK: - Extension
extension ModelosFipeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.models?.modelos.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:TabelaFipeGenericCell? = tableView.dequeueReusableCell(withIdentifier: TabelaFipeGenericCell.identifier, for: indexPath) as? TabelaFipeGenericCell
        
        if let model = models {
            cell?.setupCellVehicleModels(data: model, index: indexPath.section)
        }
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
        guard let model = models?.modelos[indexPath.section] else { return }
        self.modelCodeSelected = model.value
        DispatchQueue.main.async {
            AnimationLoading.start()
            self.anoModeloFipeViewModel.serviceAPI?.fetchYearModel(vehicleType: self.vehicleTypeSelected, brandCode: self.brandCodeSelected, modelCode: model.value)
        }
    }
}

extension ModelosFipeVC: AnoModeloFipeViewModelProtocol {
    func successGoToResult(yearModel: [GenericFipeModel]?) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.performSegue(withIdentifier: "AnoFipeVC", sender: yearModel)
        }
    }
    
    func erroFetch(message: String) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.alert?.alertInformation(title: "Atenção", message: message)
        }
    }
}

