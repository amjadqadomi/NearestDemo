//
//  CoreDataUtils.swift
//  NearestDemo
//
//  Created by Amjad on 2/25/21.
//

import Foundation
import UIKit
import CoreData

class CoreDataUtils {
    class func getManajedObjectContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    class func saveMapItems (items: [PlaceDataLocalDBAdapter]) {
        let managedObjectContext = CoreDataUtils.getManajedObjectContext()
        for item in items {
            let placeDataEntity = PlaceDataEntity(context: managedObjectContext)
            placeDataEntity.title = item.title
            placeDataEntity.id = item.id
            placeDataEntity.averageRating = item.averageRating
            placeDataEntity.openingHours = item.openingHours
            placeDataEntity.phoneNumber = item.phoneNumber
            placeDataEntity.longitude = item.longitude
            placeDataEntity.latitude = item.latitude
            placeDataEntity.distance = Int32(item.distance)
            placeDataEntity.alternativeNames = item.alternativeNames
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    class func getMapItems() -> [PlaceDataEntity] {
        let fetchRequest: NSFetchRequest<PlaceDataEntity> = PlaceDataEntity.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchRequest.predicate = nil
        // Create Fetched Results Controller
        let  fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataUtils.getManajedObjectContext(), sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects as? [PlaceDataEntity] {
            return fetchedObjects
        }
        return []
    }
    
    class func deleteAllMapItems() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PlaceDataEntity")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)

        do {
            try CoreDataUtils.getManajedObjectContext().execute(request)

        } catch let error as NSError {
            print("Could not delete perceptions  \(error)")
        }

    }
}
