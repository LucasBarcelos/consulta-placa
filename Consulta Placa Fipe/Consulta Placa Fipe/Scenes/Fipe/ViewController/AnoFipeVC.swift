//
//  AnoFipeVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import UIKit

class AnoFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var yearModel: [GenericFipeModel] = []
    private let completeFipeViewModel: CompleteFipeViewModel = CompleteFipeViewModel(serviceAPI: FipeCompleteAPI())
    var vehicleTypeSelected = 0
    var brandCodeSelected = 0
    var modelCodeSelected = 0
    var yearSelected = ""
    var alert: AlertController?
    var aux = 0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completeFipeViewModel.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        validateYearList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ResultadoFipeVC") {
            let vc = segue.destination as! ResultadoFipeVC
            guard let result = sender as? CompleteFipeModel else { return }
            vc.resultFipe = result
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    // MARK: - Methods
    func validateYearList() {
        for data in yearModel {
            if data.label == "32000" || data.label == "32000 Gasolina" {
                yearModel.remove(at: aux)
            }
        }
        aux = aux + 1
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
            self.completeFipeViewModel.serviceAPI?.fetchComplete(vehicleType: self.vehicleTypeSelected,
                                                                 brandCode: self.brandCodeSelected,
                                                                 modelCode: self.modelCodeSelected,
                                                                 yearFuel: self.yearSelected)
        }
    }
}

extension AnoFipeVC: CompleteFipeViewModelProtocol {
    func successGoToResult(result: CompleteFipeModel?) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
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
