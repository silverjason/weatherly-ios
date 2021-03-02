//
//  ForecastCollectionViewCell.swift
//  Weatherly
//
//  Created by Jason Silver on 26/2/21.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {

    // MARK: - Static Properties
    static let identifier = "ForecastCollectionViewCellID"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
}
