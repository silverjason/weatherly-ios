//
//  WeatherlyTests.swift
//  WeatherlyTests
//
//  Created by Jason Silver on 1/3/21.
//

import XCTest
import SwiftyJSON

class WeatherlyTests: XCTestCase {

    // MARK: - Test Data
    private var segmentTestItemJson: String {
        return
            """
                {
                    "dt": 1614675600,
                    "main": {
                        "temp": 292.44,
                    },
                    "weather": [{
                        "description": "scattered clouds",
                        "icon": "03n"
                    }],
                }
                """
    }

    
    func testInitForecastSegmenttEmptyJSONThrows() throws {
        
        let jsonItem = JSON(parseJSON: segmentTestItemJson)
        let dayForecast = try ForecastSegment(json: jsonItem)
        XCTAssertEqual(dayForecast.dayTime, "Tuesday 8:00 PM")
        XCTAssertEqual(dayForecast.description, "scattered clouds")
        XCTAssertEqual(dayForecast.date, "Mar 2, 2021")
        XCTAssertEqual(dayForecast.iconImageUrl?.absoluteString, "http://openweathermap.org/img/w/03n.png")
        XCTAssertEqual(dayForecast.temperature, 292)
    }

    func testForecastWithCityWithEmptyDayForecasts() throws {
        let city = "Sydney"
        let summary = ForecastSummary(segments: [], city: "Sydney")
        XCTAssertEqual(city, summary.city)
    }
    
    func testForecastWithCityWithDayForecasts() throws {
    
        let city = "Sydney"
        let jsonItem = JSON(parseJSON: segmentTestItemJson)
        let dayForecast = try ForecastSegment(json: jsonItem)
        let summary = ForecastSummary(segments: [dayForecast], city: city)
        XCTAssertEqual(city, summary.city)
        XCTAssertEqual(summary.segments.count, 1)
    }

}
