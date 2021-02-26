//
//  NearstDemoTests.swift
//  NearstDemoTests
//
//  Created by Amjad on 2/24/21.
//

import XCTest
import Alamofire
@testable import NearestDemo

class NearstDemoTests: XCTestCase {
    
    var sut: URLSession!
    var mapViewModel: MapViewModel!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = URLSession(configuration: .default)
        mapViewModel = MapViewModel()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mapViewModel = nil
    }
    
    
    func testNumberOfPlacesInResponseNoMoreThan10() {
        let searchText = mapViewModel.predictedCommonSearches.randomElement()
        
        mapViewModel.fetchPlacesFromServer(searchText: searchText ?? "") { (items) in
            XCTAssertLessThanOrEqual(items.count, 10, "number of places per search should be equal or less than 10")
        } networkIssue: { error in
            XCTFail("network error")
        }
    }
    
    func testValidCallToPlacesAPIWithLibraryCall() {
        let requestURL = WebService.baseURL + WebService.nearbyURL
        let mapViewModel = MapViewModel()
        let searchText = mapViewModel.predictedCommonSearches.randomElement()
        let location = "42.356403,-71.058857"
        
        let parameters: Parameters = [WebServiceParameters.searchTextParameterKey: searchText ?? "", WebServiceParameters.currentLocationParameterKey: location, WebServiceParameters.placesAppIdParameterKey: WebService.placesAppId, WebServiceParameters.placesAppCodeParameterKey: WebService.placesAppCode, WebServiceParameters.resultSizeParameterKey: WebService.searchSizeLimit]
        let headers: HTTPHeaders = [:]
        
        AF.request(requestURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .responseString { response in
                
                let statusCode = response.response?.statusCode
                XCTAssertEqual(statusCode, 200)
            }
    }
    
    func testValidCallToPlacesAPIHTTPStatusCode200WithoutLibrary() {
        var url =
            URLComponents(string: WebService.baseURL + WebService.nearbyURL)
        
        let mapViewModel = MapViewModel()
        let searchText = mapViewModel.predictedCommonSearches.randomElement()
        let location = "42.356403,-71.058857"
        
        url?.queryItems = [
            URLQueryItem(name: WebServiceParameters.placesAppIdParameterKey, value: WebService.placesAppId),
            URLQueryItem(name: WebServiceParameters.placesAppCodeParameterKey, value: WebService.placesAppCode),
            URLQueryItem(name: WebServiceParameters.searchTextParameterKey, value: searchText),
            URLQueryItem(name: WebServiceParameters.currentLocationParameterKey, value: location)
        ]
        let promise = expectation(description: "Status code: 200")
        
        let request = URLRequest(url: (url?.url)!)
        
        let dataTask = sut.dataTask(with: request) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        // 3
        wait(for: [promise], timeout: 5)
    }
    
}
