//
//  NetworkUtils.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import Foundation
import Alamofire
import CoreLocation

class NetworkUtils {
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
    
    
    
    class func searchNearby(searchText: String, location: String, completion:@escaping (Result<SearchResponse,AFError>)->Void, networkIssue: @escaping (_ error: Error) -> Void) {
        let requestURL = WebService.baseURL + WebService.nearbyURL
        let parameters: Parameters = [WebServiceParameters.searchTextParameterKey: searchText, WebServiceParameters.currentLocationParameterKey: location, WebServiceParameters.placesAppIdParameterKey: WebService.placesAppId, WebServiceParameters.placesAppCodeParameterKey: WebService.placesAppCode, WebServiceParameters.resultSizeParameterKey: WebService.searchSizeLimit]
        let headers: HTTPHeaders = [:]
        NetworkUtils.sendRequest(requestURL: requestURL, method: .get, encoding: URLEncoding.default, parameters: parameters, headers: headers, completion: completion, networkIssue: networkIssue)
    }
    
}
