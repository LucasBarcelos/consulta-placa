//
//  TabelaFipeGenericCell.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import UIKit

class TabelaFipeGenericCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    // MARK: - Properties
    
    static let identifier: String = "TabelaFipeGenericCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 10
        mainView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        mainView.layer.shadowRadius = 2
        mainView.layer.shadowOffset = CGSize(width: 2, height: 3)
        mainView.layer.shadowOpacity = 0.30
        mainView.layer.masksToBounds = false
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func setupCell(data: GenericFipeModel) {
        self.typeLabel.text = data.label
    }

}
