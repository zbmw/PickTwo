//
//  MoviesService.swift
//  RequestApp
//
//  Created by Victor Catão on 18/02/22.
//

import Foundation

protocol CFBDataServiceable {
    func getRankings() async -> Result<Polls, RequestError>
    func getMovieDetail(id: Int) async -> Result<Movie, RequestError>
}

struct CFBDataService: HTTPClient, CFBDataServiceable {
    func getRankings() async -> Result<Polls, RequestError> {
        return await sendRequest(endpoint: CFBDataEndpoint.topRated, responseModel: Polls.self)
    }
    
    func getMovieDetail(id: Int) async -> Result<Movie, RequestError> {
        return await sendRequest(endpoint: MoviesEndpoint.movieDetail(id: id), responseModel: Movie.self)
    }
}
