//
//  ConsultaPlacaVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 26/03/23.
//

import UIKit

class ConsultaPlacaVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var plateSwitch: UISwitch!
    @IBOutlet weak var plateImage: UIImageView!
    @IBOutlet weak var plateTextField: UITextField!
    @IBOutlet weak var queryButton: UIButton!
    
    // MARK: - Properties
    private let consultaPlacaViewModel: ConsultaPlacaViewModel = ConsultaPlacaViewModel(serviceAPI: ConsultaPlacaServiceAPI())
    private var plate: String = ""
    var alert: AlertController?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alert = AlertController(controller: self)
        self.consultaPlacaViewModel.delegate(delegate: self)
        self.plateTextField.delegate = self
        configPlateTextField()
    }
    
    // MARK: - Methods
    func configPlateTextField() {
        self.plateTextField.adjustsFontSizeToFitDevice()
        self.plateTextField.adjustsFontSizeToFitWidth = true
        self.plateTextField.autocorrectionType = .no
        self.plateTextField.autocapitalizationType = .allCharacters
        self.plateTextField.tintColor = .clear
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
        if enable {
            self.queryButton.backgroundColor = .cpPrimaryMain
            self.queryButton.isEnabled = true
        } else {
            self.queryButton.backgroundColor = .cpGrey3Aux
            self.queryButton.isEnabled = false
        }
    }
    
    func resetTextFieldKeyboard() {
        self.plateTextField.keyboardType = UIKeyboardType.default
        self.plateTextField.text = ""
        self.plateTextField.reloadInputViews()
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
    func successGoToResult(resultado: ConsultaPlacaModel?) {
        DispatchQueue.main.async {
            AnimationLoading.stop()
//            let vc:ResultadoConsultaPlacaVC = ResultadoConsultaPlacaVC()
//            vc.consultaPlacaResultado = resultado
//            self.navigationController?.pushViewController(vc, animated: true)
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
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let switchMercosul = self.plateSwitch else { return }
        if self.plateTextField.text?.count == 0 {
            self.neededShowPlaceHolder(show: true, sender: switchMercosul, resetConfig: true)
        } else {
            self.neededShowPlaceHolder(show: false, sender: switchMercosul, resetConfig: false)
        }
        self.becomeFirstResponder()
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