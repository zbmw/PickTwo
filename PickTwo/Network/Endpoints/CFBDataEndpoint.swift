//
//  MoviesEndpoint.swift
//  RequestApp
//
//  Created by Victor Catão on 18/02/22.
//

enum CFBDataEndpoint {
    case rankings
    case movieDetail(id: Int)
}

extension CFBDataEndpoint: Endpoint {
    var path: String {
        switch self {
        case .rankings:
            return "/rankings?year=2021&week=1&seasonType=postseason"
        case .movieDetail(let id):
            return "/3/movie/\(id)"
        }
    }

    var method: RequestMethod {
        switch self {
        case .rankings, .movieDetail:
            return .get
        }
    }

    var header: [String: String]? {
        // Access Token to use in Bearer header
        let accessToken = "XCz8eADs8uHTXVfmqXtYdnovZPtv1i1W0tZg1bZcBFURaagoobJ9QoXaaWEjo9wG"
        switch self {
        case .rankings, .movieDetail:
            return [
                "Authorization": "Bearer \(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }
    
    var body: [String: String]? {
        switch self {
        case .rankings, .movieDetail:
            return nil
        }
    }
}