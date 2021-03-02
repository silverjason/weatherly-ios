//
//  Forecast.swift
//  Weatherly
//
//  Created by Jason Silver on 25/2/21.
//

import Foundation
import SwiftyJSON
import Alamofire

struct ForecastSummary {

    // MARK: - Properties
    let segments: [ForecastSegment]
    let city: String
}

// MAKR: - API Calls

extension ForecastSummary {

    static func load(searchText: String, type: SearchType, completion: @escaping (ForecastSummary?) -> Void) {

        let countryCode = Locale.current.regionCode ?? "au"
        let appID = "b0c12f55341bce9611595adea62d480c"
        let units = "metric"

        let parameters: [String: String] = [
            "appid": appID,
            "units": units,
            "\(type.queryParam)": "\(searchText),\(countryCode)"
        ]

        UserDefaults.standard.setValue(searchText, forKey: UserDefaults.Keys.lastSearch.rawValue)

        AF.request("https://api.openweathermap.org/data/2.5/forecast", parameters: parameters)
            .validate()
            .response {(response) in

                switch response.result {

                case .success:
                    guard let data = response.data else {
                        print("Could not retrieve data from response")
                        return
                    }
                    do {
                        var segments = [ForecastSegment]()
                        let json = try JSON(data: data)

                        let city = json["city"]["name"].string ?? ""

                        for jsonSegment in json["list"].arrayValue {
                            let segment = try ForecastSegment(json: jsonSegment)
                            segments.append(segment)
                        }

                        let forecast = ForecastSummary(segments: segments, city: city)
                        completion(forecast)

                    } catch {
                        print("handle error \(error)")
                        completion(nil)
                    }

                case .failure(let error):
                    print("handle error \(error)")
                    completion(nil)
                }
        }
    }
}
