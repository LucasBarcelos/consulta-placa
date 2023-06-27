//
//  ConsultaPlacaVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 26/03/23.
//

import UIKit
import Reachability
import GoogleMobileAds

class ConsultaPlacaVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var plateSwitch: UISwitch!
    @IBOutlet weak var plateImage: UIImageView!
    @IBOutlet weak var plateTextField: UITextField!
    @IBOutlet weak var queryButton: UIButton!
    @IBOutlet weak var connectionLabel: UILabel!
    
    // MARK: - Properties
    private let consultaPlacaViewModel: ConsultaPlacaViewModel = ConsultaPlacaViewModel(serviceAPI: ConsultaPlacaServiceAPI())
    private var plate: String = ""
    var alert: AlertController?
    let reachability = try! Reachability()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alert = AlertController(controller: self)
        self.consultaPlacaViewModel.delegate(delegate: self)
        self.plateTextField.delegate = self
        configPlateTextField()
        
        print("UserDefault - Mês: \(UserDefaults.standard.getMonthReference())")
        print("UserDefault - Código: \(UserDefaults.standard.getCodeReference())")
        configButtonEnable(false)
        
        verifyScreenSizeToNotification()
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
        print("Notification Removida - Consulta Placa")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ResultadoPlacaVC") {
            let vc = segue.destination as! ResultadoConsultaPlacaVC
            guard let result = sender as? ConsultaPlacaModel else { return }
            vc.consultaPlacaResultado = result
            vc.plateIsMercosul = self.plateSwitch.isOn
            vc.plateTyped = self.plateTextField.text ?? ""
        }
    }
    
    // MARK: - Methods
    func configPlateTextField() {
        self.plateTextField.adjustsFontSizeToFitDevice()
        self.plateTextField.adjustsFontSizeToFitWidth = true
        self.plateTextField.autocorrectionType = .no
        self.plateTextField.autocapitalizationType = .allCharacters
        self.plateTextField.tintColor = .clear
    }
    
    // Register Notification to move screen when keyboard is
    func verifyScreenSizeToNotification() {
        if UIDevice().screenType == .small {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    func checkPlate(string: String?, str: String?) -> Bool{
        guard let str = str else { return Bool() }
        let plateSwitch = self.plateSwitch.isOn
        
        if string == "" { //BackSpace
            return true
        } else if str.count == 4 {
            self.plateTextField.text = (self.plateTextField.text ?? "") + "-"
        } else if str.count > 8 { return false }
        
        if plateSwitch {
            if str.count == 3 || str.count > 4 {
                self.plateTextField.keyboardType = UIKeyboardType.numberPad
                self.plateTextField.reloadInputViews()
            } else {
                self.plateTextField.keyboardType = UIKeyboardType.default
                self.plateTextField.reloadInputViews()
            }
        } else {
            if str.count > 2 {
                self.plateTextField.keyboardType = UIKeyboardType.numberPad
                self.plateTextField.reloadInputViews()
            }
        }
        
        if (str.count == 8) {
            let plateSwitch = self.plateSwitch.isOn
            if plateSwitch {
                let mySet = CharacterSet(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"])
                let index = str.index(str.startIndex, offsetBy: 5)
                let auxIndex = String(str[index])
                if (auxIndex.rangeOfCharacter(from: mySet) != nil) {
                    self.configButtonEnable(true)
                } else {
                    // TODO: ALERT
                    // print("Placa Inválida")
                    self.configButtonEnable(false)
                }
            } else {
                self.configButtonEnable(true)
            }
        }
        self.plate = str
        return true
    }
    
    func neededShowPlaceHolder(show: Bool, sender: UISwitch, resetConfig: Bool) {
        if show && sender.isOn {
            self.plateImage.image = UIImage(named: "mercosulPlatePlaceholder")
        } else if show && !sender.isOn {
            self.plateImage.image = UIImage(named: "oldPlatePlaceholder")
        } else if !show && sender.isOn {
            self.plateImage.image = UIImage(named: "mercosulPlate")
        } else {
            self.plateImage.image = UIImage(named: "oldPlate")
        }
        
        if resetConfig {
            self.resetTextFieldKeyboard()
            self.configButtonEnable(false)
        }
    }
    
    func configButtonEnable(_ enable:Bool) {
        if enable && (reachability.connection == .cellular || reachability.connection == .wifi) {
            self.queryButton.backgroundColor = .cpPrimaryMain
            self.queryButton.isEnabled = true
        } else {
            self.queryButton.backgroundColor = .cpGrey3Aux
            self.queryButton.isEnabled = false
        }
    }
    
    func validateLengthPlate() {
        if plate.count == 8 {
            configButtonEnable(true)
        } else {
            configButtonEnable(false)
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            connectionLabel.isHidden = true
            validateLengthPlate()
            print("Conexão via WiFi - Consulta Placa")
        case .cellular:
            connectionLabel.isHidden = true
            validateLengthPlate()
            print("Conexão via Cellular - Consulta Placa")
        case .unavailable:
            connectionLabel.isHidden = false
            validateLengthPlate()
            print("Sem conexão - Consulta Placa")
        }
    }
    
    func resetTextFieldKeyboard() {
        self.plateTextField.keyboardType = UIKeyboardType.default
        self.plateTextField.text = ""
        self.plateTextField.reloadInputViews()
    }
    
    func resetImagePlateDismissKeyboard() {
        guard let switchMercosul = self.plateSwitch else { return }
        if self.plateTextField.text?.count == 0 {
            self.neededShowPlaceHolder(show: true, sender: switchMercosul, resetConfig: true)
        } else {
            self.neededShowPlaceHolder(show: false, sender: switchMercosul, resetConfig: false)
        }
        self.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 100
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Actions
    @IBAction func plateSwitch(_ sender: UISwitch) {
        neededShowPlaceHolder(show: true, sender: sender, resetConfig: true)
        self.becomeFirstResponder()
    }

    @IBAction func queryButton(_ sender: UIButton) {
        self.becomeFirstResponder()
        AnimationLoading.start()
        self.consultaPlacaViewModel.serviceAPI?.fetchPlate(plate: self.plate)
    }
}

extension ConsultaPlacaVC: ConsultaPlacaViewModelProtocol {
    func successGoToResult(result: ConsultaPlacaModel?) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            GoogleAdsManager.successCounter += 1
            self.performSegue(withIdentifier: "ResultadoPlacaVC", sender: result)
        }
    }
    
    func erroFetch(message: String) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
            self.alert?.alertInformation(title: "Atenção", message: message)
        }
    }
}

extension ConsultaPlacaVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let switchMercosul = self.plateSwitch else { return }
        self.neededShowPlaceHolder(show: false, sender: switchMercosul, resetConfig: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetImagePlateDismissKeyboard()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetImagePlateDismissKeyboard()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) { return false }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location + range.length < (textField.text?.count)! {
            return false
        }
        else {
            let str = (self.plateTextField.text as? NSString)?.replacingCharacters(in: range, with: string)
            let plateSwitch = self.plateSwitch.isOn
            
            // Rastreia o toque no backspace para poder trocar de teclado
            let char = string.cString(using: String.Encoding.utf8)
            let isBackspace = strcmp(char, "\\b")
            
            if (isBackspace == -92) {
                print("Backspace pressionado!")
                
                let newPosition = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                
                if plateSwitch && str?.count == 5 {
                    self.plateTextField.keyboardType = UIKeyboardType.default
                    self.plateTextField.reloadInputViews()
                }
                
                if str?.count ?? 0 < 4 {
                    self.plateTextField.keyboardType = UIKeyboardType.default
                    self.plateTextField.reloadInputViews()
                }
                
                if str?.count ?? 0 == 4 {
                    self.plateTextField.text = self.plateTextField.text?.replacingOccurrences(of: "-", with: "")
                    self.plateTextField.keyboardType = UIKeyboardType.numberPad
                    self.plateTextField.reloadInputViews()
                }
                
                if str?.count ?? 0 < 8 {
                    self.configButtonEnable(false)
                }
                
                if str?.count == 0 {
                    //
                }
            }
            return checkPlate(string: string, str: str)
        }
    }
}
