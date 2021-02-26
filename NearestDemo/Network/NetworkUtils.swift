//
//  NetworkUtils.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import Foundation
import Alamofire
import CoreLocation

/**
 This class is a utility class which has all network functions.
 This utility uses Alamofire library as the networking layer.
 */
class NetworkUtils {
    /**This function is the base function to send network requests to the backend.
     - Parameters:
        - requestURL: `String` URL to send request to
        - method: `HTTPMethod` request method (.get, .post , etc.)
        - encoding: `ParameterEncoding` the encoding of the parameters
        - parameters: `Parameters` a dictionary that contains all the parameters of the request
        - headers: `HTTPHeaders` a dictionary that contains all the headers of the request
        - completion: `((Result<T,AFError>)->Void)` the completion handler that will be called in success case - T is the decodable response class type-
        - networkIssue: `(_ error: Error) -> Void` the callback that will be called in case of errors
     */
    class func sendRequest<T:Decodable>(requestURL: String, method: HTTPMethod, encoding: ParameterEncoding = URLEncoding.default, parameters: Parameters, headers: HTTPHeaders, decoder: JSONDecoder = JSONDecoder(), completion:@escaping ((Result<T,AFError>)->Void), networkIssue: @escaping (_ error: Error) -> Void) -> Void  {
        
        AF.request(requestURL, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseDecodable { (dataResponse: DataResponse<T, AFError>) in
                if let data = dataResponse.data {
                    
                    let stringResponse = String(decoding: data, as: UTF8.self)
                    print(stringResponse)
                }
                let statusCode = dataResponse.response?.statusCode
                print(statusCode)
                completion(dataResponse.result)
            }
    }
    
    /**This function is used to send a search request that will fetch places near the user location
     - Parameters:
        - searchText: `String` text to search for
        - location: `String` the coordinates of the user in the format (latitude,longitude) eg: (32.227970,35.217105 )
        - completion: `((Result<SearchResponse,AFError>)->Void)` the completion handler that will be called in success case
        - networkIssue: `(_ error: Error) -> Void` the callback that will be called in case of errors
     */
    
    class func searchNearby(searchText: String, location: String, completion:@escaping (Result<SearchResponse,AFError>)->Void, networkIssue: @escaping (_ error: Error) -> Void) {
        let requestURL = WebService.baseURL + WebService.nearbyURL
        let parameters: Parameters = [WebServiceParameters.searchTextParameterKey: searchText, WebServiceParameters.currentLocationParameterKey: location, WebServiceParameters.placesAppIdParameterKey: WebService.placesAppId, WebServiceParameters.placesAppCodeParameterKey: WebService.placesAppCode, WebServiceParameters.resultSizeParameterKey: WebService.searchSizeLimit]
        let headers: HTTPHeaders = [:]
        NetworkUtils.sendRequest(requestURL: requestURL, method: .get, encoding: URLEncoding.default, parameters: parameters, headers: headers, completion: completion, networkIssue: networkIssue)
    }
    
}
