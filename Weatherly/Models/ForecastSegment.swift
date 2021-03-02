//
//  DailyForecast.swift
//  Weatherly
//
//  Created by Jason Silver on 26/2/21.
//

import Foundation
import SwiftyJSON

struct ForecastSegment {

    // MARK: - Properties
    let dateTs: TimeInterval
    let description: String
    let temperature: Int
    let iconCode: String

    private var dateFormatter = DateFormatter()

    // MARK: - Computed Properties
    var dayTime: String {
        dateFormatter.dateFormat = "EEEE H:mm a"
        return dateFormatter.string(from: Date(timeIntervalSince1970: dateTs))
    }

    var date: String {
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: dateTs))
    }

    var iconImageUrl: URL? {
        return URL(string: "http://openweathermap.org/img/w/\(iconCode).png")
    }

    // MARK: - Initialisers
    init(json: JSON) throws {

        guard let date = json["dt"].double,
              let description = json["weather"][0]["description"].string,
              let temperature = json["main"]["temp"].int,
              let iconCode = json["weather"][0]["icon"].string else {
            throw InvalidJSONObject.forecast
        }
        self.dateTs = TimeInterval(date)
        self.description = description
        self.temperature = temperature
        self.iconCode = iconCode
    }

}
