//
//  CurrencyValueFormatter.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 05/07/23.
//

import Foundation
import UIKit
import DGCharts
import Charts

class CurrencyValueFormatter: IndexAxisValueFormatter {
    private let numberFormatter: NumberFormatter

    override init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "pt_BR")
        numberFormatter.maximumFractionDigits = 0

        super.init()
    }

    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return formatValueAsCurrency(value)
    }

    private func formatValueAsCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let abbreviatedValue: String

        if absValue >= 1_000_000 {
            abbreviatedValue = String(format: "R$%.1fM", absValue / 1_000_000)
        } else if absValue >= 1_000 {
            abbreviatedValue = String(format: "R$%.1fK", absValue / 1_000)
        } else {
            abbreviatedValue = numberFormatter.string(from: NSNumber(value: value)) ?? ""
        }

        return abbreviatedValue
    }
}
