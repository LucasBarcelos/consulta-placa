//
//  AnoFipeVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 05/07/23.
//

import UIKit
import Reachability

class AnoFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectionLabel: UILabel!
    
    // MARK: - Properties
    var yearModel: [GenericFipeModel] = []
    private let completeFipeViewModel: CompleteFipeViewModel = CompleteFipeViewModel(serviceAPI: FipeCompleteAPI())
    var vehicleTypeSelected = 0
    var brandCodeSelected = 0
    var modelCodeSelected = 0
    var yearSelected = ""
    var alert: AlertController?
    var aux = 0
    let reachability = try! Reachability()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completeFipeViewModel.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        validateYearList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
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
        print("Notification Removida - Consulta ANO FIPE")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ResultadoFipeVC") {
            let vc = segue.destination as! ResultadoFipeVC
            guard let result = sender as? [CompleteFipeModel] else { return }
            vc.resultFipe = result
        }
    }
    
    // MARK: - Methods
    func validateYearList() {
        for data in yearModel {
            if data.label == "32000" || data.label == "32000 Gasolina" || data.label == "32000 Diesel" {
                yearModel.remove(at: aux)
            }
        }
        aux = aux + 1
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via WiFi - Consulta ANO FIPE")
        case .cellular:
            self.tableView.isUserInteractionEnabled = true
            self.connectionLabel.text = ""
            print("Conexão via Cellular - Consulta ANO FIPE")
        case .unavailable:
            self.tableView.isUserInteractionEnabled = false
            self.connectionLabel.text = "Sem conexão"
            print("Sem conexão - Consulta ANO FIPE")
        }
    }
}

// MARK: - Extension
extension AnoFipeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.yearModel.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:TabelaFipeGenericCell? = tableView.dequeueReusableCell(withIdentifier: TabelaFipeGenericCell.identifier, for: indexPath) as? TabelaFipeGenericCell
        if yearModel[indexPath.section].label != "32000" {
            cell?.setupCell(data: yearModel[indexPath.section])
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
        self.yearSelected = yearModel[indexPath.section].value
        DispatchQueue.main.async {
            AnimationLoading.start()
            
            let listaMesesHistorico = UserDefaults.standard.getHistoricReference()
            let ultimosMeses = Array(listaMesesHistorico.prefix(12))
            
            self.completeFipeViewModel.serviceAPI?.fetchLastMonths(months: ultimosMeses,
                                                                   vehicleType: self.vehicleTypeSelected,
                                                                   brandCode: self.brandCodeSelected,
                                                                   modelCode: self.modelCodeSelected,
                                                                   yearFuel: self.yearSelected) {
                (results: [CompleteFipeModel], error: Error?) in
                print("Request final FIPE realizada!")
            }
        }
    }
}

extension AnoFipeVC: CompleteFipeViewModelProtocol {
    func successGoToResult(result: [CompleteFipeModel]?) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            GoogleAdsManager.successCounter += 1
            
            self.performSegue(withIdentifier: "ResultadoFipeVC", sender: result)
        }
    }
    
    func erroFetch(message: String) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.alert?.alertInformation(title: "Atenção", message: message)
        }
    }
}
