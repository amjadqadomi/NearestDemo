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
    class func saveMapItems (items: [StorableMapItemObject]) {
        let managedObjectContext = CoreDataUtils.getManajedObjectContext()
        for item in items {
            let t = StorableMapItem(context: managedObjectContext)
            t.title = item.title
            t.id = item.id
            t.averageRating = item.averageRating ?? -1
            t.isOpen = item.isOpen ?? false
            t.longitude = item.longitude
            t.latitude = item.latitude
            t.alternativeNames = item.alternativeNames
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    class func getMapItems() {
        let fetchRequest: NSFetchRequest<StorableMapItem> = StorableMapItem.fetchRequest()
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
        
        if let fetchedObjects = fetchedResultsController.fetchedObjects as? [StorableMapItem] {
            for ff in fetchedObjects {
                print(ff.alternativeNames?.alternativeNames?.last?.language)
            }
        }
    }
    
    class func deleteAllMapItems() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "StorableMapItem")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)

        do {
            try CoreDataUtils.getManajedObjectContext().execute(request)

        } catch let error as NSError {
            print("Could not delete perceptions  \(error)")
        }

    }
}
