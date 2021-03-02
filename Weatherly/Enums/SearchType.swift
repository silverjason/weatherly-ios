//
//  SearchType.swift
//  Weatherly
//
//  Created by Jason Silver on 26/2/21.
//

enum SearchType {
    case city
    case postCode
    
    var queryParam: String {
        switch self {
        case .city:
           return "q"
        default:
           return "zip"
        }
    }
}
