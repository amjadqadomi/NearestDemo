//
//  TestCoreData.swift
//  NearestDemoTests
//
//  Created by Amjad on 2/26/21.
//

import XCTest
import CoreData

@testable import NearestDemo
class TestCoreData: XCTestCase {
    var coreDataManager = CoreDataManager()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCoreDataManagerNotNill() {
        XCTAssertNotNil(coreDataManager)
    }
    
    func testCoreDataContainerNotNil() {
        XCTAssertNotNil(coreDataManager.persistentContainer)
    }
    
    func testCreationAndDeletionOfPlaceRecords() {
        coreDataManager.setup(storeType: NSInMemoryStoreType) {
            let placeData1 = self.coreDataManager.savePlace(place: PlaceDataLocalDBAdapter(longitude: -71.058857, latitude: 42.356403, distance: 1234, title: "title1", averageRating: 2.3, id: "jjhunoasbd123", phoneNumber: "1234576892", openingHours: "2-3 everyday", alternativeNames: nil))
            XCTAssertNotNil(placeData1)
            
            let placeData2 = self.coreDataManager.savePlace(place: PlaceDataLocalDBAdapter(longitude: -41.058857, latitude: 32.356403, distance: 500, title: "title2", averageRating: 5.0, id: "quwyeqwiuekjh", phoneNumber: "81273", openingHours: "24/7", alternativeNames: PlaceAlternativeNamesLocalDBAdapter(alternativeNames: [PlaceAlternativeNameLocalDBAdapter(name:"test name 1", language:"En"), PlaceAlternativeNameLocalDBAdapter(name:"تجربة", language:"ar"), PlaceAlternativeNameLocalDBAdapter(name:"ES", language:"Hola")])))
            XCTAssertNotNil(placeData2)
            
            let placeData3 = self.coreDataManager.savePlace(place: PlaceDataLocalDBAdapter(longitude: -71.058857, latitude: 42.356403, distance: 350, title: "title3", averageRating: 3.3, id: "jjhunoasbd123", phoneNumber: "2135165", openingHours: "2-3 everyday", alternativeNames: nil))
            XCTAssertNotNil(placeData3)
            
            let results = self.coreDataManager.getPlace()
            XCTAssertEqual(results.count, 3)
            
            XCTAssertGreaterThan(results.count, 0, "no records in persistent store")
            let place = results[0]
            let numberOfPlaces = results.count
            
            self.coreDataManager.deletePlace(place: place)
            XCTAssertEqual(self.coreDataManager.getPlace().count, numberOfPlaces-1)
        }
    }

}

