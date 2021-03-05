//
//  ViewController.swift
//  Weatherly
//
//  Created by Jason Silver on 25/2/21.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Private Properties
    private var isCollectionViewShown = false // used to animate show on first load only
    private var forecastSummary: ForecastSummary? {
        didSet {
            collectionView?.reloadData()
            if !isCollectionViewShown {
                isCollectionViewShown = true
                UIView.animate(withDuration: 0.5) { [weak self] in
                    self?.collectionView?.alpha = 1
                }
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationTextField?.becomeFirstResponder()
        locationTextField?.text = UserDefaults.standard.string(forKey: UserDefaults.Keys.lastSearch.rawValue)
    }

    // MARK: - IBActions
    @IBAction func search(_ sender: UIButton) {

        guard let textfield = locationTextField, let searchText = textfield.text, !searchText.isEmpty else { return }

        if searchText.allSatisfy({ $0.isNumber }) {
            searchPostCode(searchText)
        } else {
            searchCity(searchText)
        }
    }

    @IBAction func useCurrentLocation(_ UIButton: UIButton) {
        LocationManager.getCurrent { [weak self] (placemark, errorDescription) in
            if let placemark = placemark {
                let searchText = placemark.locality ?? placemark.subLocality
                if let searchText = searchText {
                    self?.locationTextField?.text = searchText
                    self?.searchCity(searchText)
                }
            } else if let desc = errorDescription {
                self?.displayErrorAlert(desc)
            }
        }
    }

    // MARK: - Convenience
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = collectionView?.bounds.size ?? .zero
        collectionView?.collectionViewLayout = layout
        collectionView?.dataSource = self
        collectionView?.delegate = self

        let forecastNib = UINib(nibName: String(describing: ForecastCollectionViewCell.self), bundle: Bundle.main)
        collectionView?.register(forecastNib, forCellWithReuseIdentifier: ForecastCollectionViewCell.identifier)
    }

    private func searchCity(_ city: String) {
        loadSummary(searchText: city, type: .city)
    }

    private func searchPostCode(_ postCode: String) {
        loadSummary(searchText: "\(postCode)", type: .postCode)
    }

    private func loadSummary(searchText: String, type: SearchType) {

        ForecastSummary.load(searchText: searchText, type: type) { [weak self] (forecastSummary) in
            if let forecastSummary = forecastSummary {
                self?.view.endEditing(true)
                self?.forecastSummary = forecastSummary
            } else {
                self?.displayErrorAlert("Hmmm we couldn't find data for this location. Please try a different location")
            }
        }
    }

    private func configureCell(_ cell: ForecastCollectionViewCell,
                               summary: ForecastSummary,
                               index: Int) -> ForecastCollectionViewCell {

        let segment = summary.segments[index]
        cell.dayLabel?.text = segment.dayTime
        cell.dateLabel?.text = segment.date
        cell.descriptionLabel?.text = segment.description
        cell.temperatureLabel?.text = "\(segment.temperature)c"
        cell.iconImageView?.kf.setImage(with: segment.iconImageUrl)
        cell.cityLabel?.text = summary.city

        return cell
    }

}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        guard let summary = forecastSummary else { return 0 }
        return summary.segments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCollectionViewCell.identifier, for: indexPath) as! ForecastCollectionViewCell

        guard let summary = forecastSummary,
              indexPath.item < summary.segments.count else {
            return cell
        }

        return configureCell(cell,
                             summary: summary,
                             index: indexPath.item)
    }

}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = collectionView.bounds.size.height
        let width = collectionView.bounds.size.width - 30 // padding so other cards start to appear next to current card
        return CGSize(width: width, height: height)
    }

}
