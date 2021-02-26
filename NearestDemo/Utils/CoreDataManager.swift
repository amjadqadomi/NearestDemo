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
    enum StorageType {
      case persistent, inMemory
    }
    private var storeType: String = NSSQLiteStoreType

        lazy var persistentContainer: NSPersistentContainer! = {
            let persistentContainer = NSPersistentContainer(name: "Model")
            let description = persistentContainer.persistentStoreDescriptions.first
            description?.type = storeType

            return persistentContainer
        }()

        static let shared = CoreDataManager()

        func setup(storeType: String = NSSQLiteStoreType, completion: (() -> Void)?) {
            self.storeType = storeType

            loadPersistentStore {
                completion?()
            }
        }

        private func loadPersistentStore(completion: @escaping () -> Void) {
            persistentContainer.loadPersistentStores { description, error in
                guard error == nil else {
                    fatalError("was unable to load store \(error!)")
                }

                completion()
            }
        }
    
    
     func savePlaces (places: [PlaceDataLocalDBAdapter]) {
        for place in places {
            savePlace(place: place)
        }
    }
    
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
    
    func getPlace() -> [PlaceDataEntity] {
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
    
    func deletePlace(place : PlaceDataEntity){
        let managedObjectContext = persistentContainer.viewContext
        managedObjectContext.delete(place)
        do {
            try managedObjectContext.save()
        } catch {
        }
    }
}
