//
//  ResultadoFipeVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import UIKit
import Charts
import DGCharts

class ResultadoFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var fuelLabel: UILabel!
    @IBOutlet weak var fipeCodeLabel: UILabel!
    @IBOutlet weak var dateQueryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var refereceMonthLabel: UILabel!
    @IBOutlet weak var newQueryButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //Chart
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewChart: UIView!
    @IBOutlet weak var valorMesLabel: UILabel!
    
    // MARK: - Properties
    var resultFipe: [CompleteFipeModel]?
    var listaResumida: [FipeResumidaModel] = []
    let formatter = NumberFormatter()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            if GoogleAdsManager.successCounter >= 2 {
                if let interstitial = GoogleAdsManager.shared.interstitial {
                    GoogleAdsManager.successCounter = 0
                    interstitial.present(fromRootViewController: self)
                    print("Anúncio FIPE - intersticial exibido com sucesso!")
                } else {
                    print("Anúncio FIPE - intersticial não está pronto ainda.")
                }
            } else {
                showReview()
            }
        }

        incrementAppRuns()
        setupFipe()
        setupViewChart()
        setupChart()
        
        // Exibir o valor e o mês concatenados na nova label
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
    }
    
    // MARK: - Methods
    func setupFipe() {
        guard let resultado = resultFipe else { return }
        let mesAtual = UserDefaults.standard.getMonthReference()
        let dateFormat = "MMMM/yyyy"  // Define o formato esperado das datas

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")  // Define o local para "pt_BR" para tratar o mês em português
        dateFormatter.dateFormat = dateFormat
        
        for item in resultado {
            let dataA = item.MesReferencia.replacingOccurrences(of: " de ", with: "").replacingOccurrences(of: " ", with: "")
            let dataB = mesAtual.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")
                
            if dataA == dataB {
                print("As variáveis representam o mesmo mês e ano.")
                self.brandLabel.attributedText = NSMutableAttributedString().bold("Marca: ").normal("\(item.Marca)")
                self.modelLabel.attributedText = NSMutableAttributedString().bold("Modelo: ").normal("\(item.Modelo)")
                self.yearLabel.attributedText = NSMutableAttributedString().bold("Ano/Modelo: ").normal("\(item.AnoModelo)")
                self.fuelLabel.attributedText = NSMutableAttributedString().bold("Combustível: ").normal("\(item.Combustivel)")
                self.fipeCodeLabel.attributedText = NSMutableAttributedString().bold("Código FIPE: ").normal("\(item.CodigoFipe)")
                self.refereceMonthLabel.attributedText = NSMutableAttributedString().bold("Mês de Referência: ").normal("\(item.MesReferencia)")
                self.dateQueryLabel.attributedText = NSMutableAttributedString().bold(item.DataConsulta)
                self.priceLabel.text = item.Valor
                return
            } else {
                print("As variáveis representam meses e/ou anos diferentes.")
            }
        }
    }
    
    func setupViewChart() {
        self.viewChart.clipsToBounds = true
        self.viewChart.layer.cornerRadius = 10
        self.viewChart.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        self.viewChart.layer.shadowRadius = 4
        self.viewChart.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.viewChart.layer.shadowOpacity = 0.30
        self.viewChart.layer.masksToBounds = false
    }
    
    func setupChart() {
        let chartView = LineChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false

        // Criando lista de valores já em Double
        guard let resultado = resultFipe else { return }
        
        // Percorra os itens da lista original
        for item in resultado {
            let valorString = item.Valor
            let mesReferenciaString = item.MesReferencia
            
            // Remova o prefixo "R$ " e o separador de milhares "."
            let valorCleaned = valorString.replacingOccurrences(of: "R$ ", with: "").replacingOccurrences(of: ".", with: "")
            
            // Remova a vírgula decimal e converta para Double
            if let valor = Double(valorCleaned.replacingOccurrences(of: ",", with: ".")) {
                // Formate o MesReferencia
                let mesReferenciaFormatted = formatMesReferencia(mesReferenciaString).replacingOccurrences(of: ".", with: "")
                
                // Adicione o item à lista resumida
                let carItem = FipeResumidaModel(valor: valor, mesReferencia: mesReferenciaFormatted)
                listaResumida.append(carItem)
            }
        }
        
        listaResumida = sortDataByMonth(data: listaResumida)
        
        var dataEntries: [ChartDataEntry] = []

        for (index, model) in listaResumida.enumerated() {
            let xValue = Double(index)
            let yValue = model.valor
            let dataEntry = ChartDataEntry(x: xValue, y: yValue)
            dataEntries.append(dataEntry)
        }
        
        let dataSet = LineChartDataSet(entries: dataEntries, label: "")
        dataSet.colors = [NSUIColor.cpSecondaryMain]
        dataSet.lineWidth = 2
        dataSet.circleRadius = 6
        dataSet.circleHoleRadius = 4
        dataSet.drawCircleHoleEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.circleColors = [NSUIColor.cpPrimaryMain]
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        dataSet.drawValuesEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true

        let months = listaResumida.map { $0.mesReferencia }

        xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        xAxis.labelCount = months.count
        xAxis.granularity = 1
        xAxis.granularityEnabled = true
        xAxis.setLabelCount(months.count, force: true)
        xAxis.labelRotationAngle = -45

        let lineChartData = LineChartData(dataSet: dataSet)
        chartView.data = lineChartData
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.legend.form = .none
        chartView.delegate = self
        chartView.leftAxis.enabled = true
        
        let leftAxis = chartView.leftAxis
        leftAxis.valueFormatter = CurrencyValueFormatter()
        leftAxis.drawAxisLineEnabled = true // Exibir linha do eixo
        leftAxis.drawLabelsEnabled = true // Exibir legendas
        
        chartView.rightAxis.enabled = false
        
        self.viewChart.addSubview(chartView)
        
        // Configurar restrições
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: self.viewChart.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: self.viewChart.trailingAnchor),
            chartView.topAnchor.constraint(equalTo: self.viewChart.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: self.viewChart.bottomAnchor)
        ])
    }

    func formatMesReferencia(_ mesReferencia: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale(identifier: "pt_BR")
        dateFormatterGet.dateFormat = "MMMM 'de' yyyy"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.locale = Locale(identifier: "pt_BR")
        dateFormatterPrint.dateFormat = "MMM/yy"
        
        if let date = dateFormatterGet.date(from: mesReferencia) {
            return dateFormatterPrint.string(from: date)
        } else {
            return ""
        }
    }
    
    func sortDataByMonth(data: [FipeResumidaModel]) -> [FipeResumidaModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "MMM/yy"

        let sortedData = data.sorted { (item1, item2) -> Bool in
            if let date1 = dateFormatter.date(from: item1.mesReferencia),
               let date2 = dateFormatter.date(from: item2.mesReferencia) {
                return date1 < date2
            }
            return false
        }

        return sortedData
    }

    // MARK: - Actions
    @IBAction func newQueryButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {

        guard let scrollView = scrollView,
              let contentView = scrollView.subviews.first,
              let startFrame = brandLabel?.frame,
              let endFrame = viewChart?.frame else { return }
        
        var endPoint = CGPoint()
        var printHeight: CGFloat = 0.0
        
        let startPoint = CGPoint(x: 0, y: contentView.frame.origin.y + startFrame.origin.y - 20)
        let printWidth = scrollView.frame.size.width
        
        endPoint = CGPoint(x: scrollView.frame.size.width, y: contentView.frame.origin.y + endFrame.maxY + 20)
        printHeight = endPoint.y - startPoint.y
         
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

extension ResultadoFipeVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(entry.x)
        
        guard index >= 0 && index < listaResumida.count else {
            return
        }
        
        let selectedData = listaResumida[index]
        let month = selectedData.mesReferencia
        let value = selectedData.valor
        
        if let valorFormatado = formatter.string(from: NSNumber(value: value)) {
            valorMesLabel.text = "\(month) - \(valorFormatado)"
        } else {
            valorMesLabel.text = "\(month)"
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        // Quando nenhum ponto estiver selecionado
        valorMesLabel.text = ""
    }
}
