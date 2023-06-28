//
//  ModelosFipeVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import UIKit
import Reachability

class ModelosFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectionLabel: UILabel!
    
    // MARK: - Properties
    var models: VehicleModelsModel?
    private let anoModeloFipeViewModel: AnoModeloFipeViewModel = AnoModeloFipeViewModel(serviceAPI: FipeYearModelAPI())
    var vehicleTypeSelected = 0
    var brandCodeSelected = 0
    var modelCodeSelected = 0
    var alert: AlertController?
    let reachability = try! Reachability()
    
    // Search Bar
    var filteredModels: VehicleModelsModel?
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.anoModeloFipeViewModel.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        configureSearch()
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
        print("Notification Removida - Consulta MODELOS FIPE")
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
    
    // MARK: - Methods
    private func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Pesquise um modelo..."
        searchController.searchBar.barTintColor = .white
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via WiFi - Consulta MODELOS FIPE")
        case .cellular:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via Cellular - Consulta MODELOS FIPE")
        case .unavailable:
            self.tableView.isUserInteractionEnabled = false
            self.connectionLabel.text = "Sem conexão"
            print("Sem conexão - Consulta MODELOS FIPE")
        }
    }
}

// MARK: - Extension
extension ModelosFipeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let filteredModel = filteredModels?.modelos,
              let model = models?.modelos else { return 0 }
        
        return isFiltering ? filteredModel.count : model.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:TabelaFipeGenericCell? = tableView.dequeueReusableCell(withIdentifier: TabelaFipeGenericCell.identifier, for: indexPath) as? TabelaFipeGenericCell
        
        let filteredModel = isFiltering ? filteredModels : models
        
        if let model = filteredModel {
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
        
        let modelFiltered = isFiltering ? filteredModels?.modelos[indexPath.section] : models?.modelos[indexPath.section]
        
        guard let model = modelFiltered else { return }
        
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

// MARK: - Extension - Search Results Updating
extension ModelosFipeVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        if let modelos = models?.modelos {
            filteredModels?.modelos = modelos.filter { character in
                character.label.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
