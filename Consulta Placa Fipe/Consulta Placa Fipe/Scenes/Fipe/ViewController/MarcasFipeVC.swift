//
//  MarcasVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import UIKit

class MarcasFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var brands: [GenericFipeModel] = []
    private let marcasFipeViewModel: MarcasFipeViewModel = MarcasFipeViewModel(serviceAPI: FipeModelsAPI())
    var vehicleTypeSelected = 0
    var brandCodeSelected = 0
    var alert: AlertController?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.marcasFipeViewModel.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
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
