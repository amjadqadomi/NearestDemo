//
//  CoreDataManager.swift
//  NearestDemo
//
//  Created by Amjad on 2/25/21.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    /// storeType defines if we are using the memory for storage or the persistent documents
    /// the NSInMemoryStoreType will be used for unit testing so the testing data would not persist and affect the flow
    
    private var storeType: String = NSSQLiteStoreType
    
    lazy var persistentContainer: NSPersistentContainer! = {
        let persistentContainer = NSPersistentContainer(name: "Model")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = storeType
        
        return persistentContainer
    }()
    
    ///singlton instance of CoreDataManager
    static let shared = CoreDataManager()
    
    ///sets up the core data manager with the correct store type
    /// - Parameters:
    /// - storeType: `String` store type on which the data will be written, most common values are  NSSQLiteStoreType, NSInMemoryStoreType.
    /// - completion: `() -> Void`the completion handler that should be called once the store is set up.

    func setup(storeType: String = NSSQLiteStoreType, completion: (() -> Void)?) {
        self.storeType = storeType
        
        loadPersistentStore {
            completion?()
        }
    }
    
    ///loads the persistent store
    /// - Parameters:
    /// - completion: `() -> Void`the completion handler that should be called once the store is loaded
    private func loadPersistentStore(completion: @escaping () -> Void) {
        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("was unable to load store \(error!)")
            }
            
            completion()
        }
    }
    
    
    ///saves places to core data
    /// - Parameters:
    /// - places: `[PlaceDataLocalDBAdapter]` the places that should be saved to core data
    func savePlaces (places: [PlaceDataLocalDBAdapter]) {
        for place in places {
            savePlace(place: place)
        }
    }
    
    ///saves places to core data
    /// - Parameters:
    /// - places: `[PlaceDataLocalDBAdapter]` the places that should be saved to core data
    /// - Returns:`PlaceDataEntity?` the saved place in core data
    @discardableResult
    func savePlace(place: PlaceDataLocalDBAdapter) -> PlaceDataEntity? {
        let managedObjectContext = persistentContainer.viewContext
        let placeDataEntity = PlaceDataEntity(context: managedObjectContext)
        placeDataEntity.title = place.title
        placeDataEntity.id = place.id
        placeDataEntity.averageRating = place.averageRating
        placeDataEntity.openingHours = place.openingHours
        placeDataEntity.phoneNumber = place.phoneNumber
        placeDataEntity.longitude = place.longitude
        placeDataEntity.latitude = place.latitude
        placeDataEntity.distance = Int32(place.distance)
        placeDataEntity.alternativeNames = place.alternativeNames
        do {
            try managedObjectContext.save()
            return placeDataEntity
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    ///get latest saved places from core data
    /// - Returns:`[PlaceDataEntity]` the saved places in core data
    func getLatestPlaces() -> [PlaceDataEntity] {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PlaceDataEntity> = PlaceDataEntity.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchRequest.predicate = nil
        // Create Fetched Results Controller
        let  fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            return fetchedObjects
        }
        return []
    }
    
    ///deletes all places from core data
    func deleteAllPlaces() {
        let managedObjectContext = persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaceDataEntity")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try managedObjectContext.execute(request)
            
        } catch let error as NSError {
            print("Could not delete records  \(error)")
        }
        
    }
    
    ///get a saved place from core data
    /// - Parameters:
    /// - places: `PlaceDataLocalDBAdapter` the places that should be deleted from core data
    func deletePlace(place : PlaceDataEntity){
        let managedObjectContext = persistentContainer.viewContext
        managedObjectContext.delete(place)
        do {
            try managedObjectContext.save()
        } catch {
        }
    }
}
