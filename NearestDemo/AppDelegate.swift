//
//  AppDelegate.swift
//  NearstDemo
//
//  Created by Amjad on 2/24/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "Model")
          container.loadPersistentStores { description, error in
              if let error = error {
                  fatalError("Unable to load persistent stores: \(error)")
              }
          }
          return container
      }()
}

